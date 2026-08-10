import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_event.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';

class AddEditMenuItemScreenActions {
  static void handleAddCategory(BuildContext context, bool mounted) async {
    await context.read<MenuCategoryFullListCubit>().loadData();
  }

  static void handleSaveItem({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required MenuItem? existingItem,
    required String name,
    required String description,
    required String? foodType,
    required int? categoryId,
    required int? subcategoryId,
    required bool isTodayAvailable,
    required String costPriceText,
    required String sellingPriceText,
    required String? purchaseUnit,
    required String quantityText,
    required Duration selectedDuration,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    formKey.currentState!.save();

    final newItem = MenuItem(
      id: existingItem?.id,
      hashId: existingItem?.hashId ?? const Uuid().v4(),
      name: name,
      description: description,
      foodType: foodType ?? '',
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      isSimpleVariation: true,
      isTodayAvailable: isTodayAvailable,
      costPrice: double.tryParse(costPriceText),
      sellingPrice: double.tryParse(sellingPriceText),
      purchaseUnit: purchaseUnit,
      quantity: purchaseUnit == 'Unit' ? '1' : quantityText,
      duration: selectedDuration.inSeconds,
      creationDate:
          existingItem?.creationDate ?? DateTime.now().toIso8601String(),
      modificationDate: DateTime.now().toIso8601String(),
    );

    if (existingItem == null) {
      context.read<MenuItemBloc>().add(
        AddMenuItem(
          newItem,
          onSuccess: () {
            context.pop();
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
                      shared.LocaleKeys.crudSuccessAdd,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Record added successfully.',
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
              AddEditMenuItemScreenActions,
              'AddMenuItem:onError: $error',
            );
            context.pop();
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
                          'An error occurred.'),
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
    } else {
      context.read<MenuItemBloc>().add(
        UpdateMenuItem(
          newItem,
          onSuccess: () {
            context.pop();
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
                      shared.LocaleKeys.crudSuccessUpdate,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Record updated successfully.',
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
              AddEditMenuItemScreenActions,
              'UpdateMenuItem:onError: $error',
            );
            context.pop();
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
                          'An error occurred.'),
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
}
