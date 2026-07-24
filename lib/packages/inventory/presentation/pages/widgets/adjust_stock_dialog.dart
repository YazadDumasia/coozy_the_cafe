import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../inventory/domain/entities/inventory_item.dart';
import '../../bloc/inventory_bloc.dart';
import '../../bloc/inventory_event.dart';

class AdjustStockDialog extends StatefulWidget {
  final InventoryItem item;

  const AdjustStockDialog({super.key, required this.item});

  @override
  State<AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends State<AdjustStockDialog> {
  final TextEditingController _amountController = TextEditingController();
  final ValueNotifier<bool> _isIncrementNotifier = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _amountController.dispose();
    _isIncrementNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.tr(
              shared.LocaleKeys.inventoryAdjustStockDailogTitle,
              track: shared.TrackConstants.inventoryPageTrack,
            ) ??
            'Adjust Stock',
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(
                      shared.LocaleKeys.inventoryAdjustStockDailogItemName,
                      track: shared.TrackConstants.inventoryPageTrack,
                      params: {"name": widget.item.name ?? ''},
                    ) ??
                    'Item: ${widget.item.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                context.tr(
                      shared.LocaleKeys.inventoryAdjustStockDailogCurrentStock,
                      track: shared.TrackConstants.inventoryPageTrack,
                      params: {
                        "currentStock":
                            widget.item.currentStock?.toStringAsFixed(2) ?? '',
                        "purchaseUnit": widget.item.purchaseUnit ?? '',
                      },
                    ) ??
                    'Current Stock: ${widget.item.currentStock?.toStringAsFixed(2)} ${widget.item.purchaseUnit}',
              ),
              SizedBox(height: 16),
              ListenableBuilder(
                listenable: Listenable.merge([
                  _isIncrementNotifier,
                  _amountController,
                ]),
                builder: (context, child) {
                  final amount =
                      double.tryParse(_amountController.text) ?? 0.00;
                  double newStock = widget.item.currentStock ?? 0.00;

                  if (_isIncrementNotifier.value) {
                    newStock += amount;
                  } else {
                    newStock -= amount;
                    if (newStock < 0) newStock = 0;
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(
                                context.tr(
                                      shared
                                          .LocaleKeys
                                          .inventoryAdjustStockDailogAddStock,
                                      track: shared
                                          .TrackConstants
                                          .inventoryPageTrack,
                                    ) ??
                                    'Add',
                              ),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(
                                context.tr(
                                      shared
                                          .LocaleKeys
                                          .inventoryAdjustStockDailogRemoveStock,
                                      track: shared
                                          .TrackConstants
                                          .inventoryPageTrack,
                                    ) ??
                                    'Remove',
                              ),
                            ),
                          ],
                          selected: {_isIncrementNotifier.value},
                          onSelectionChanged: (Set<bool> newSelection) {
                            _isIncrementNotifier.value = newSelection.first;
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText:
                              context.tr(
                                shared
                                    .LocaleKeys
                                    .inventoryAdjustStockDailogAdjustmentAmount,
                                track: shared.TrackConstants.inventoryPageTrack,
                              ) ??
                              'Adjustment Amount',
                          hintText: "0.00",
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        autofocus: true,
                      ),
                      SizedBox(height: 16),
                      Text(
                        context.tr(
                              shared
                                  .LocaleKeys
                                  .inventoryAdjustStockDailogNewStockPreview,
                              track: shared.TrackConstants.inventoryPageTrack,
                              params: {"newStock": newStock.toStringAsFixed(2)},
                            ) ??
                            'New Stock Preview: $newStock',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: newStock == widget.item.currentStock
                              ? Colors.grey
                              : Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.tr(
                  shared.LocaleKeys.commonCancel,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Cancel',
          ),
        ),
        ListenableBuilder(
          listenable: Listenable.merge([
            _isIncrementNotifier,
            _amountController,
          ]),
          builder: (context, child) {
            final amount = double.tryParse(_amountController.text) ?? 0;
            double newStock = widget.item.currentStock ?? 0;

            if (_isIncrementNotifier.value) {
              newStock += amount;
            } else {
              newStock -= amount;
              if (newStock < 0) newStock = 0;
            }

            return ElevatedButton(
              onPressed: () {
                if (newStock != widget.item.currentStock) {
                  final updatedItem = widget.item.copyWith(
                    currentStock: newStock,
                    modifiedDate: DateTime.now().toIso8601String(),
                  );
                  context.read<InventoryBloc>().add(
                    UpdateInventoryItem(updatedItem),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonSave,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Save',
              ),
            );
          },
        ),
      ],
    );
  }
}
