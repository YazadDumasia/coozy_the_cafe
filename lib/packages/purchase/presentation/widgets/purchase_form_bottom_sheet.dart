import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_record.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class PurchaseFormBottomSheet extends StatefulWidget {
  final InventoryItem item;
  final PurchaseRecord? existingRecord;

  const PurchaseFormBottomSheet({
    super.key,
    required this.item,
    this.existingRecord,
  });

  @override
  State<PurchaseFormBottomSheet> createState() =>
      _PurchaseFormBottomSheetState();
}

class _PurchaseFormBottomSheetState extends State<PurchaseFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late final ValueNotifier<DateTime> _selectedDateNotifier;
  final ValueNotifier<bool> _isIncrementNotifier = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    final record = widget.existingRecord;

    double initialQty = record?.purchaseQty ?? 0.0;
    if (initialQty < 0) {
      _isIncrementNotifier.value = false;
      initialQty = initialQty.abs();
    }

    _qtyController = TextEditingController(
      text: record != null ? initialQty.toString() : '',
    );
    _priceController = TextEditingController(
      text: record != null ? record.purchasePrice?.toString() : '',
    );

    _selectedDateNotifier = ValueNotifier(
      record != null && record.purchaseDateTime != null
          ? DateTime.tryParse(record.purchaseDateTime!) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _selectedDateNotifier.dispose();
    _isIncrementNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateNotifier.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 150)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _selectedDateNotifier.value = date;
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final rawQty = double.parse(_qtyController.text);
      final qty = _isIncrementNotifier.value ? rawQty : -rawQty;
      final price = double.parse(_priceController.text);

      final record = PurchaseRecord(
        id: widget.existingRecord?.id,
        hashId: widget.existingRecord?.hashId ?? const Uuid().v4(),
        inventoryId: widget.item.id!,
        name:
            widget.item.name ??
            context.tr(
              shared.LocaleKeys.commonUnknown,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Unknown',
        purchaseUnit: widget.item.purchaseUnit ?? 'units',
        purchaseQty: qty,
        purchasePrice: price,
        purchaseDateTime: _selectedDateNotifier.value.toIso8601String(),
        createdDate:
            widget.existingRecord?.createdDate ??
            DateTime.now().toIso8601String(),
        modifiedDate: DateTime.now().toIso8601String(),
      );

      Navigator.pop(context, record);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingRecord == null
                  ? context.tr(
                          shared.LocaleKeys.purchaseAddStock,
                          track: shared.TrackConstants.purchasePageTrack,
                          params: {"item_name": widget.item.name ?? ""},
                        ) ??
                        'Add Stock: ${widget.item.name}'
                  : context.tr(
                          shared.LocaleKeys.purchaseEditStock,
                          track: shared.TrackConstants.purchasePageTrack,
                          params: {"item_name": widget.item.name ?? ""},
                        ) ??
                        'Edit Stock: ${widget.item.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isIncrementNotifier,
              builder: (context, isIncrement, child) {
                return SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text(
                        context.tr(
                              shared.LocaleKeys.purchaseIncrement,
                              track: shared.TrackConstants.purchasePageTrack,
                            ) ??
                            'Increment',
                      ),
                      icon: Icon(Icons.add),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text(
                        context.tr(
                              shared.LocaleKeys.purchaseDecrement,
                              track: shared.TrackConstants.purchasePageTrack,
                            ) ??
                            'Decrement',
                      ),
                      icon: Icon(Icons.remove),
                    ),
                  ],
                  selected: {isIncrement},
                  onSelectionChanged: (Set<bool> newSelection) {
                    _isIncrementNotifier.value = newSelection.first;
                  },
                );
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _qtyController,
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.purchaseQuantityLabelText,
                      track: shared.TrackConstants.purchasePageTrack,
                    ) ??
                    'Quantity',
                hintText:
                    context.tr(
                      shared.LocaleKeys.purchaseQuantityHintText,
                      track: shared.TrackConstants.purchasePageTrack,
                      params: {
                        "purchase_unit": widget.item.purchaseUnit ?? 'units',
                      },
                    ) ??
                    'Quantity (${widget.item.purchaseUnit ?? 'units'})',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return context.tr(
                        shared.LocaleKeys.commonRequired,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Required';
                }

                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText:
                    context.tr(
                      shared.LocaleKeys.purchaseTotalPrice,
                      track: shared.TrackConstants.purchasePageTrack,
                    ) ??
                    'Total Price',
                hintText:
                    context.tr(
                      shared.LocaleKeys.purchaseTotalPrice,
                      track: shared.TrackConstants.purchasePageTrack,
                    ) ??
                    'Total Price',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return context.tr(
                        shared.LocaleKeys.commonRequired,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Required';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                context.tr(
                      shared.LocaleKeys.purchaseDate,
                      track: shared.TrackConstants.purchasePageTrack,
                    ) ??
                    'Date',
              ),
              subtitle: Text(
                core.DateUtil.localFormatDateTime(
                      _selectedDateNotifier.value,
                      core.DateUtil.dateFormat9,
                    ) ??
                    '',
              ),
              trailing: Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              onTap: _pickDate,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonSave,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Save',
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
