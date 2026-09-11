import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

class EditInvoiceItemDialog extends StatefulWidget {
  final String itemName;
  final int initialQuantity;
  final double initialUnitPrice;
  final void Function(int quantity, double unitPrice) onSave;
  final VoidCallback onDelete;

  const EditInvoiceItemDialog({
    super.key,
    required this.itemName,
    required this.initialQuantity,
    required this.initialUnitPrice,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditInvoiceItemDialog> createState() => _EditInvoiceItemDialogState();
}

class _EditInvoiceItemDialogState extends State<EditInvoiceItemDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;
  late final FocusNode _qtyFocusNode;
  late final FocusNode _priceFocusNode;

  late final ValueNotifier<double> _totalNotifier;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.initialQuantity.toString());
    _priceController =
        TextEditingController(text: widget.initialUnitPrice.toStringAsFixed(2));
    _qtyFocusNode = FocusNode();
    _priceFocusNode = FocusNode();

    _totalNotifier = ValueNotifier<double>(
      widget.initialQuantity * widget.initialUnitPrice,
    );

    _qtyController.addListener(_updateTotal);
    _priceController.addListener(_updateTotal);
  }

  void _updateTotal() {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    _totalNotifier.value = qty * price;
  }

  @override
  void dispose() {
    _qtyController.removeListener(_updateTotal);
    _priceController.removeListener(_updateTotal);
    _qtyController.dispose();
    _priceController.dispose();
    _qtyFocusNode.dispose();
    _priceFocusNode.dispose();
    _totalNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.itemName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: 'Delete Item',
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete();
            },
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _qtyController,
                focusNode: _qtyFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.numbers),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          final current = int.tryParse(_qtyController.text) ?? 1;
                          if (current > 1) {
                            _qtyController.text = (current - 1).toString();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          final current = int.tryParse(_qtyController.text) ?? 0;
                          _qtyController.text = (current + 1).toString();
                        },
                      ),
                    ],
                  ),
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                focusNode: _priceFocusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Unit Price',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Please enter a valid unit price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<double>(
                valueListenable: _totalNotifier,
                builder: (context, total, _) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Price',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          core.CurrencyFormatter.format(value: total),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final q = int.tryParse(_qtyController.text) ?? widget.initialQuantity;
              final p = double.tryParse(_priceController.text) ?? widget.initialUnitPrice;
              widget.onSave(q, p);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
