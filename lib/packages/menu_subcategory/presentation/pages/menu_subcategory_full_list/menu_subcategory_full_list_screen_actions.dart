import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import '../menu_subcategory_update_dialog/menu_subcategory_update_dialog.dart';

class MenuSubcategoryFullListScreenActions {
  static Future<void> handleAddSubcategory(
    BuildContext context,
    bool mounted, {
    int? categoryId,
    VoidCallback? onRefreshCategories,
  }) async {
    final String path = categoryId != null
        ? '${core.AppRoutePath.menuSubCategoryFullListRoute}/${core.AppRoutePath.addNewMenuSubCategoryScreenRoute}?categoryId=$categoryId'
        : '${core.AppRoutePath.menuSubCategoryFullListRoute}/${core.AppRoutePath.addNewMenuSubCategoryScreenRoute}';
    await context.push(path);
    if (!context.mounted) return;
    context.read<MenuSubcategoryBloc>().add(const LoadMenuSubcategories());
    onRefreshCategories?.call();
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
                          context.tr(
                            shared.LocaleKeys.commonSuccess,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Success',
                      descriptions:
                          context.tr(
                            shared.LocaleKeys.menuSubCategoryUpdateSuccessfully,
                            track:
                                shared.TrackConstants.menuSubCategoryPageTrack,
                          ) ??
                          (context.tr(
                                shared.LocaleKeys.crudSuccessUpdate,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Sub-category updated successfully.'),
                      titleIcon: Lottie.asset(
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Assets.lottie.doneLightBrownColor
                            : Assets.lottie.doneBrownColor,
                        repeat: false,
                      ),
                    );
                  }
                },
                onError: (error) {
                  core.PlatformUtils.debugLog(
                    MenuSubcategoryFullListScreenActions,
                    'MenuSubcategoryUpdateDialog:onError: $error',
                  );
                  if (context.mounted) {
                    Navigator.pop(context); // Pop loading dialog
                    shared.DialogUtils.showAutoDismissDialog(
                      context: context,
                      title:
                          context.tr(
                            shared.LocaleKeys.commonError,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Error',
                      descriptions:
                          context.tr(
                            shared.LocaleKeys.crudErrorUpdate,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Failed to update the record.',
                      titleIcon: Lottie.asset(
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Assets.lottie.errorLightLoaderIcon
                            : Assets.lottie.errorDarkLoaderIcon,
                        repeat: false,
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

  static void handleToggleSubcategory(
    BuildContext context,
    MenuSubcategory subCategory,
    bool isEnable,
  ) {
    final updated = subCategory.copyWith(isActive: isEnable);
    context.read<MenuSubcategoryBloc>().add(
      UpdateMenuSubcategory(
        updated,
        onSuccess: () {
          if (context.mounted) {
            shared.DialogUtils.showAutoDismissDialog(
              context: context,
              title:
                  context.tr(
                    shared.LocaleKeys.commonSuccess,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Success',
              descriptions: isEnable
                  ? 'Your selected sub-category has been activated.'
                  : 'Your selected sub-category has been deactivated.',
              titleIcon: Lottie.asset(
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? Assets.lottie.doneLightBrownColor
                    : Assets.lottie.doneBrownColor,
                repeat: false,
              ),
            );
          }
        },
        onError: (error) {
          core.PlatformUtils.debugLog(
            MenuSubcategoryFullListScreenActions,
            'handleToggleSubcategory:onError: $error',
          );
          if (context.mounted) {
            shared.DialogUtils.showAutoDismissDialog(
              context: context,
              title:
                  context.tr(
                    shared.LocaleKeys.commonError,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Error',
              descriptions:
                  context.tr(
                    shared
                        .LocaleKeys
                        .menuCategoryFullListFailedToUpdateSubCategoryMsg,
                    track: shared.TrackConstants.menuCategoryPageTrack,
                  ) ??
                  'Failed to update sub-category status.',
              titleIcon: Lottie.asset(
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? Assets.lottie.errorLightLoaderIcon
                    : Assets.lottie.errorDarkLoaderIcon,
                repeat: false,
              ),
            );
          }
        },
      ),
    );
  }

  static void handleDeleteSubcategory(
    BuildContext context,
    MenuSubcategory subCategory,
  ) {
    if (subCategory.id == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.tr(
                shared.LocaleKeys.menuCategoryFullListDeleteDialogTitle,
                track: shared.TrackConstants.menuCategoryPageTrack,
              ) ??
              'Are you sure?',
        ),
        content: Text(
          'Do you really want to delete sub-category "${subCategory.name}"? You will not be able to undo this action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonCancel,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Cancel',
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MenuSubcategoryBloc>().add(
                DeleteMenuSubcategory(
                  subCategory.id!,
                  onSuccess: () {
                    if (context.mounted) {
                      shared.DialogUtils.showAutoDismissDialog(
                        context: context,
                        title:
                            context.tr(
                              shared.LocaleKeys.commonSuccess,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Success',
                        descriptions:
                            context.tr(
                              shared
                                  .LocaleKeys
                                  .menuSubCategoryDeletedSuccessfully,
                              track: shared
                                  .TrackConstants
                                  .menuSubCategoryPageTrack,
                            ) ??
                            (context.tr(
                                  shared.LocaleKeys.crudSuccessDelete,
                                  track: shared.TrackConstants.commonTrack,
                                ) ??
                                'Sub-category deleted successfully.'),
                        showDuration: const Duration(seconds: 3),
                        titleIcon: Lottie.asset(
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Assets.lottie.doneLightBrownColor
                              : Assets.lottie.doneBrownColor,
                          repeat: false,
                        ),
                      );
                    }
                  },
                  onError: (error) {
                    core.PlatformUtils.debugLog(
                      MenuSubcategoryFullListScreenActions,
                      'handleDeleteSubcategory:onError: $error',
                    );
                    if (context.mounted) {
                      shared.DialogUtils.showAutoDismissDialog(
                        context: context,
                        title:
                            context.tr(
                              shared.LocaleKeys.commonError,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Error',
                        descriptions: error.isNotEmpty
                            ? error
                            : (context.tr(
                                    shared.LocaleKeys.commonErrorMsg,
                                    track: shared.TrackConstants.commonTrack,
                                  ) ??
                                  'Something when wrong. Please try again.'),
                        titleIcon: Lottie.asset(
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.light
                              ? Assets.lottie.errorLightLoaderIcon
                              : Assets.lottie.errorDarkLoaderIcon,
                          repeat: false,
                        ),
                      );
                    }
                  },
                ),
              );
            },
            child: Text(
              context.tr(
                    shared.LocaleKeys.commonDelete,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Delete',
            ),
          ),
        ],
      ),
    );
  }
}
