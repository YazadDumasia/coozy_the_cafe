import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_record.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/item_purchase_bloc.dart';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/item_purchase_event.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AddPurchaseScreenActions {
  static void handleSubmitPurchase({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required InventoryItem item,
    required TextEditingController qtyController,
    required TextEditingController priceController,
  }) {
    if (formKey.currentState?.validate() ?? false) {
      final qty = double.parse(qtyController.text);
      final price = double.parse(priceController.text);

      final purchaseRecord = PurchaseRecord(
        name: item.name ?? 'Unknown',
        inventoryId: item.id!,
        purchaseDateTime: DateTime.now().toIso8601String(),
        purchaseQty: qty,
        purchaseUnit: item.purchaseUnit ?? 'units',
        purchasePrice: price,
        hashId: const Uuid().v4(),
        createdDate: DateTime.now().toIso8601String(),
        modifiedDate: DateTime.now().toIso8601String(),
      );

      shared.DialogUtils.showLoadingDialog(context);

      context.read<ItemPurchaseBloc>().add(
        AddPurchaseRecord(
          purchaseRecord,
          onSuccess: () {
            if (context.mounted) {
              Navigator.pop(context); // Pop loading dialog
              qtyController.clear();
              priceController.clear();
              FocusScope.of(context).unfocus();

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
                          .purchasePurchaseAddedSuccessfullyAndStockUp,
                      track: shared.TrackConstants.purchasePageTrack,
                    ) ??
                    'Purchase added successfully and stock updated!',
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
        ),
      );
    }
  }
}
