import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/edit_menu_category_bloc/edit_menu_category_bloc.dart';

class EditMenuCategoryScreenActions {
  static void handleSaveCategory(
    BuildContext context,
    GlobalKey<FormState> formKey,
    String categoryName,
    EditMenuCategoryBloc bloc,
  ) {
    if (formKey.currentState?.validate() ?? false) {
      bloc.add(
        SubmitSubCategoryEditMenuEvent(
          categoryName: categoryName,
          onSuccess: () {
            Navigator.pop(context);
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
                      shared.LocaleKeys.menuCategoryUpdatedSuccessfullyText,
                      track: shared.TrackConstants.menuCategoryPageTrack,
                    ) ??
                    (context.tr(
                          shared.LocaleKeys.crudSuccessUpdate,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Category updated successfully.'),
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
              EditMenuCategoryScreenActions,
              'handleSaveCategory:onError: $error',
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
  }

  static void handleAddSubCategory(
    BuildContext context,
    EditMenuCategoryBloc bloc,
  ) {
    bloc.add(OnAddNewSubCategoryEditMenuCategoryEvent());
  }

  static void handleDeleteSubCategory(
    BuildContext context,
    EditMenuCategoryBloc bloc,
    int index,
  ) {
    bloc.add(DeleteSubCategoryEditMenuEvent(index: index));
  }

  static void handleUpdateSubCategory(
    BuildContext context,
    EditMenuCategoryBloc bloc,
    int index,
    String value,
  ) {
    bloc.add(
      UpdateSubCategoryEditMenuCategoryEvent(index: index, value: value),
    );
  }
}
