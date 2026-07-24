import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/add_menu_sub_categories_bloc/add_menu_categories_cubit.dart';

class AddNewMenuCategoryScreenActions {
  static void handleSaveCategory(
    BuildContext context,
    GlobalKey<FormState> formKey,
    AddMenuCategoryCubit cubit,
  ) {
    if (formKey.currentState?.validate() ?? false) {
      cubit.saveCategory(
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
                shared.LocaleKeys.crudSuccessAdd,
                track: shared.TrackConstants.commonTrack,
              ) ?? 'Record added successfully.',
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
      );
    }
  }

  static void handleAddSubCategory(
    AddMenuCategoryCubit cubit,
    ScrollController? scrollController,
  ) {
    cubit.addSubCategory('');
    if (scrollController != null && scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }
}
