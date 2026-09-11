import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

class AddInvoiceItemDialog extends StatefulWidget {
  final void Function(String itemName, int quantity, double unitPrice) onAdd;

  const AddInvoiceItemDialog({super.key, required this.onAdd});

  @override
  State<AddInvoiceItemDialog> createState() => _AddInvoiceItemDialogState();
}

class _AddInvoiceItemDialogState extends State<AddInvoiceItemDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _qtyFocusNode;
  late final FocusNode _priceFocusNode;

  late final ValueNotifier<double> _totalNotifier;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _qtyController = TextEditingController(text: '1');
    _priceController = TextEditingController(text: '0.00');
    _nameFocusNode = FocusNode();
    _qtyFocusNode = FocusNode();
    _priceFocusNode = FocusNode();

    _totalNotifier = ValueNotifier<double>(0.0);

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
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _nameFocusNode.dispose();
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
      title: Text(
        'Add Invoice Item',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              final name = _nameController.text.trim();
              final q = int.tryParse(_qtyController.text) ?? 1;
              final p = double.tryParse(_priceController.text) ?? 0.0;
              widget.onAdd(name, q, p);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
