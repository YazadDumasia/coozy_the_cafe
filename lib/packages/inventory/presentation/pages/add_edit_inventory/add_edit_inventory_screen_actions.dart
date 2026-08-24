import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventroy_bloc/inventory_bloc.dart';

class AddEditInventoryScreenActions {
  static void saveItem({
    required BuildContext context,
    required InventoryItem? existingItem,
    required String name,
    required String shortDescription,
    required String purchaseUnit,
    required double currentStock,
    required bool isEnabled,
  }) {
    final newItem = InventoryItem(
      id: existingItem?.id,
      hashId: existingItem?.hashId ?? const Uuid().v4(),
      name: name,
      shortDescription: shortDescription,
      purchaseUnit: purchaseUnit,
      currentStock: currentStock,
      isEnabled: isEnabled,
      createdDate:
          existingItem?.createdDate ?? DateTime.now().toIso8601String(),
      modifiedDate: DateTime.now().toIso8601String(),
    );

    final isCreating = existingItem == null;

    if (isCreating) {
      context.read<InventoryBloc>().add(
        AddInventoryItem(
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
                      shared
                          .LocaleKeys
                          .inventoryAddEditDailogCreateSuccessfully,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    (context.tr(
                          shared.LocaleKeys.crudSuccessAdd,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Inventory item created successfully.'),
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
              AddEditInventoryScreenActions,
              'AddInventoryItem:onError: $error',
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
    } else {
      context.read<InventoryBloc>().add(
        UpdateInventoryItem(
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
                      shared
                          .LocaleKeys
                          .inventoryAddEditDailogUpdateSuccessfully,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    (context.tr(
                          shared.LocaleKeys.crudSuccessUpdate,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Inventory item updated successfully.'),
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
              AddEditInventoryScreenActions,
              'UpdateInventoryItem:onError: $error',
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
}
