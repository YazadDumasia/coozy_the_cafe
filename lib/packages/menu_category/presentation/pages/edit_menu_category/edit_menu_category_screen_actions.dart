import 'package:flutter/material.dart';
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
                title: context.tr(
                  shared.LocaleKeys.commonSuccess,
                  track: shared.TrackConstants.commonTrack,
                ) ?? 'Success',
                descriptions: context.tr(
                  shared.LocaleKeys.crudSuccessUpdate,
                  track: shared.TrackConstants.commonTrack,
                ) ?? 'Record updated successfully.',
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
              shared.DialogUtils.showAutoDismissDialog(
                context: context,
                title: context.tr(
                  shared.LocaleKeys.commonError,
                  track: shared.TrackConstants.commonTrack,
                ) ?? 'Error',
                descriptions: error.isNotEmpty
                    ? error
                    : (context.tr(
                        shared.LocaleKeys.commonErrorMsg,
                        track: shared.TrackConstants.commonTrack,
                      ) ?? 'An error occurred.'),
                titleIcon: const Icon(Icons.error, color: Colors.red, size: 50),
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
