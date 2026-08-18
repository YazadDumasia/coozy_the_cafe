import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
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
          descriptions:
              context.tr(
                shared.LocaleKeys.pleaseSelectOrCreateACategoryMsg,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Please select or create a category.',
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
                    shared.LocaleKeys.menuSubCategoryAddedSuccessfully,
                    track: shared.TrackConstants.menuSubCategoryPageTrack,
                  ) ??
                  (context.tr(
                        shared.LocaleKeys.crudSuccessAdd,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Sub-category added successfully.'),
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
            AddNewMenuSubcategoryScreenActions,
            'saveSubcategories:onError: $error',
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
