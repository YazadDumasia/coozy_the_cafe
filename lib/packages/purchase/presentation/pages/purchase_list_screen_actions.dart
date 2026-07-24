import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_record.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/purchase_list_bloc.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/purchase_list_event.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/widgets/purchase_form_bottom_sheet.dart';

class PurchaseListScreenActions {
  static Future<void> showPurchaseForm({
    required BuildContext context,
    required InventoryItem item,
    PurchaseRecord? existingRecord,
  }) async {
    final result = await showModalBottomSheet<PurchaseRecord>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
          PurchaseFormBottomSheet(item: item, existingRecord: existingRecord),
    );

    if (result != null) {
      if (!context.mounted) return;
      shared.DialogUtils.showLoadingDialog(context);
      if (existingRecord == null) {
        context.read<PurchaseListBloc>().add(
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
                        ) ?? 'An error occurred.'),
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
      } else {
        context.read<PurchaseListBloc>().add(
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
                        ) ?? 'An error occurred.'),
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
      }
    }
  }

  static Future<void> onAddPurchaseTap(BuildContext context) async {
    final selectedItem = await context.push<InventoryItem>(
      core.AppRoutePath.inventoryPickerPageRoute,
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
          context.read<PurchaseListBloc>().add(
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
                          ) ?? 'An error occurred.'),
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
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
