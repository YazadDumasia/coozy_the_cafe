import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_event.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/pages/menu_subcategory_update_dialog.dart';

class MenuSubcategoryFullListScreenActions {
  static Future<void> handleAddSubcategory(
    BuildContext context,
    bool mounted,
  ) async {
    await context.push(
      '${core.AppRoutePath.menuSubCategoryFullListRoute}/${core.AppRoutePath.addNewMenuSubCategoryScreenRoute}',
    );
    if (!context.mounted) return;
    context.read<MenuSubcategoryBloc>().add(LoadMenuSubcategories());
  }

  static Future<void> handleEditSubcategory(
    BuildContext context,
    MenuSubcategory subCategory,
  ) async {
    core.PlatformUtils.debugLog(
      MenuSubcategoryFullListScreenActions,
      'old SubCategory model:MenuAllSubCategoryUpdateDialog:${subCategory.toString()}',
    );
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return MenuSubcategoryUpdateDialog(
          currentSubCategory: subCategory,
          onUpdate: (newModel) async {
            core.PlatformUtils.debugLog(
              MenuSubcategoryFullListScreenActions,
              'new SubCategory model:MenuSubcategoryUpdateDialog:${newModel.toString()}',
            );
            shared.DialogUtils.showLoadingDialog(context);
            context.read<MenuSubcategoryBloc>().add(
              UpdateMenuSubcategory(
                newModel,
                onSuccess: () {
                  if (context.mounted) {
                    Navigator.pop(context); // Pop loading dialog
                    shared.DialogUtils.showAutoDismissDialog(
                      context: context,
                      title:
                          context.tr(shared.LocaleKeys.commonSuccess, track: shared.TrackConstants.commonTrack) ??
                          'Success',
                      descriptions:
                          context.tr(shared.LocaleKeys.crudSuccessUpdate, track: shared.TrackConstants.commonTrack) ??
                          'Record updated successfully.',
                      titleIcon: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 50,
                      ),
                    );
                  }
                },
                onError: (error) {
                  if (context.mounted) {
                    Navigator.pop(context); // Pop loading dialog
                    shared.DialogUtils.showAutoDismissDialog(
                      context: context,
                      title:
                          context.tr(shared.LocaleKeys.commonError, track: shared.TrackConstants.commonTrack) ?? 'Error',
                      descriptions:
                          context.tr(shared.LocaleKeys.crudErrorUpdate, track: shared.TrackConstants.commonTrack) ??
                          'Failed to update the record.',
                      titleIcon: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
