import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_record.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/purchase_list_bloc.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/purchase_list_event.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/widgets/add_purchase/purchase_form_bottom_sheet.dart';

class PurchaseListScreenActions {
  static PurchaseListBloc _getPurchaseBloc(BuildContext context) {
    try {
      return context.read<PurchaseListBloc>();
    } catch (_) {
      return GetIt.instance<PurchaseListBloc>();
    }
  }

  static Future<void> showPurchaseForm({
    required BuildContext context,
    required InventoryItem item,
    PurchaseRecord? existingRecord,
    VoidCallback? onSuccess,
  }) async {
    final result = await showModalBottomSheet<PurchaseRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) =>
          PurchaseFormBottomSheet(item: item, existingRecord: existingRecord),
    );

    if (result != null) {
      if (!context.mounted) return;
      shared.DialogUtils.showLoadingDialog(context);
      final purchaseBloc = _getPurchaseBloc(context);
      if (existingRecord == null) {
        purchaseBloc.add(
          AddPurchaseRecordFromList(
            result,
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
                        shared.LocaleKeys.purchaseRecordAddedSuccessfully,
                        track: shared.TrackConstants.purchasePageTrack,
                      ) ??
                      'Purchase record added successfully.',
                  titleIcon: Lottie.asset(
                    MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Assets.lottie.doneLightBrownColor
                        : Assets.lottie.doneBrownColor,
                    repeat: false,
                  ),
                );
                onSuccess?.call();
              }
            },
            onError: (error) {
              core.PlatformUtils.debugLog(
                PurchaseListScreenActions,
                'AddPurchaseRecord:onError: $error',
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
      } else {
        purchaseBloc.add(
          UpdatePurchaseRecord(
            result,
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
                        shared.LocaleKeys.purchaseRecordUpdatedSuccessfully,
                        track: shared.TrackConstants.purchasePageTrack,
                      ) ??
                      'Purchase record updated successfully.',
                  titleIcon: Lottie.asset(
                    MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? Assets.lottie.doneLightBrownColor
                        : Assets.lottie.doneBrownColor,
                    repeat: false,
                  ),
                );
                onSuccess?.call();
              }
            },
            onError: (error) {
              core.PlatformUtils.debugLog(
                PurchaseListScreenActions,
                'UpdatePurchaseRecord:onError: $error',
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
      }
    }
  }

  static Future<void> onAddPurchaseTap(BuildContext context) async {
    final selectedItem = await context.push<InventoryItem>(
      '${core.AppRoutePath.inventoryListScreenRoute}/${core.AppRoutePath.inventoryPickerPageRoute}',
    );
    if (!context.mounted) return;
    if (selectedItem != null) {
      showPurchaseForm(context: context, item: selectedItem);
    }
  }

  static Future<void> onDeletePurchaseTap({
    required BuildContext context,
    required PurchaseRecord record,
  }) async {
    shared.DialogUtils.showConfirmationDialog(
      context: context,
      title:
          context.tr(
            shared.LocaleKeys.purchaseDeleteRecord,
            track: shared.TrackConstants.purchasePageTrack,
          ) ??
          'Delete Purchase?',
      content:
          context.tr(
            shared.LocaleKeys.purchaseThisWillRevertTheInventoryStockUpd,
          ) ??
          'Deleting this purchase will restore the inventory stock to its previous quantity. This action cannot be undone.',
      cancelText:
          context.tr(
            shared.LocaleKeys.commonCancel,
            track: shared.TrackConstants.commonTrack,
          ) ??
          'Cancel',
      confirmText:
          context.tr(
            shared.LocaleKeys.commonDelete,
            track: shared.TrackConstants.commonTrack,
          ) ??
          'Delete',
      titleIcon: Icon(
        Icons.info_outline,
        size: 50,
        color: Theme.of(context).primaryColor,
      ),
      onCancel: () => Navigator.pop(context),
      onConfirm: () async {
        Navigator.pop(context);
        shared.DialogUtils.showLoadingDialog(context);
        if (record.id != null) {
          _getPurchaseBloc(context).add(
            DeletePurchaseRecord(
              record.id!,
              onSuccess: () {
                if (context.mounted) {
                  Navigator.pop(context);
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
                          shared.LocaleKeys.purchaseRecordDeletedSuccessfully,
                          track: shared.TrackConstants.purchasePageTrack,
                        ) ??
                        'Purchase record deleted successfully.',
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
                  PurchaseListScreenActions,
                  'DeletePurchaseRecord:onError: $error',
                );
                if (context.mounted) {
                  Navigator.pop(context);
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
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
