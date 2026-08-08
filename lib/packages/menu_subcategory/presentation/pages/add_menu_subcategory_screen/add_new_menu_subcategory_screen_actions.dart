import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/add_menu_subcategory_cubit/add_new_menu_subcategory_cubit.dart';

class AddNewMenuSubcategoryScreenActions {
  static void handleSaveSubcategories(
    BuildContext context,
    GlobalKey<FormState> formKey,
    AddNewMenuSubcategoryCubit cubit,
  ) {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      if (!cubit.isCreatingNewCategory && cubit.selectedCategory == null) {
        shared.DialogUtils.showAutoDismissDialog(
          context: context,
          title:
              context.tr(
                shared.LocaleKeys.commonError,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Error',
          descriptions: 'Please select or create a category.',
          titleIcon: const Icon(Icons.error, color: Colors.red, size: 50),
        );
        return;
      }

      shared.DialogUtils.showLoadingDialog(context);
      cubit.saveSubcategories(
        onSuccess: () {
          if (context.mounted) {
            Navigator.pop(context); // Pop loading dialog
            Navigator.pop(context); // Pop screen
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
                    shared.LocaleKeys.crudSuccessAdd,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Record added successfully.',
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
                        'An error occurred.'),
              titleIcon: const Icon(Icons.error, color: Colors.red, size: 50),
            );
          }
        },
      );
    }
  }

  static void handleAddSubCategory(
    AddNewMenuSubcategoryCubit cubit,
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
