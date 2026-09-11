import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

class EditInvoiceDiscountDialog extends StatefulWidget {
  final double currentSubtotal;
  final int initialDiscountType;
  final double initialDiscountAmount;
  final void Function(int discountType, double discountAmount) onApply;

  const EditInvoiceDiscountDialog({
    super.key,
    required this.currentSubtotal,
    required this.initialDiscountType,
    required this.initialDiscountAmount,
    required this.onApply,
  });

  @override
  State<EditInvoiceDiscountDialog> createState() =>
      _EditInvoiceDiscountDialogState();
}

class _EditInvoiceDiscountDialogState extends State<EditInvoiceDiscountDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late final FocusNode _valueFocusNode;
  late final ValueNotifier<int> _typeNotifier;
  late final ValueNotifier<double> _previewNotifier;

  @override
  void initState() {
    super.initState();
    _typeNotifier = ValueNotifier<int>(widget.initialDiscountType);
    _valueController = TextEditingController(
      text: widget.initialDiscountAmount > 0
          ? widget.initialDiscountAmount.toString()
          : '',
    );
    _valueFocusNode = FocusNode();
    _previewNotifier = ValueNotifier<double>(widget.initialDiscountAmount);

    _valueController.addListener(_updatePreview);
    _typeNotifier.addListener(_updatePreview);
  }

  void _updatePreview() {
    final val = double.tryParse(_valueController.text) ?? 0.0;
    if (_typeNotifier.value == 0) {
      // Percentage
      _previewNotifier.value = (widget.currentSubtotal * (val / 100.0))
          .clamp(0.0, widget.currentSubtotal);
    } else {
      // Fixed Amount
      _previewNotifier.value = val.clamp(0.0, widget.currentSubtotal);
    }
  }

  @override
  void dispose() {
    _valueController.removeListener(_updatePreview);
    _typeNotifier.removeListener(_updatePreview);
    _valueController.dispose();
    _valueFocusNode.dispose();
    _typeNotifier.dispose();
    _previewNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Apply Discount',
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
              Text(
                'Current Subtotal: ${core.CurrencyFormatter.format(value: widget.currentSubtotal)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<int>(
                valueListenable: _typeNotifier,
                builder: (context, type, _) {
                  return SegmentedButton<int>(
                    segments: const [
                      ButtonSegment<int>(
                        value: 0,
                        label: Text('Percentage (%)'),
                        icon: Icon(Icons.percent),
                      ),
                      ButtonSegment<int>(
                        value: 1,
                        label: Text('Fixed (₹)'),
                        icon: Icon(Icons.currency_rupee),
                      ),
                    ],
                    selected: {type},
                    onSelectionChanged: (set) {
                      _typeNotifier.value = set.first;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<int>(
                valueListenable: _typeNotifier,
                builder: (context, type, _) {
                  return TextFormField(
                    controller: _valueController,
                    focusNode: _valueFocusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText:
                          type == 0 ? 'Discount Percentage (%)' : 'Discount Amount',
                      border: const OutlineInputBorder(),
                      prefixIcon:
                          Icon(type == 0 ? Icons.percent : Icons.currency_rupee),
                      hintText: type == 0 ? 'e.g. 10' : 'e.g. 50.00',
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<double>(
                valueListenable: _previewNotifier,
                builder: (context, preview, _) {
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
                          'Calculated Discount',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '- ${core.CurrencyFormatter.format(value: preview)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.error,
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
          onPressed: () {
            widget.onApply(0, 0.0);
            Navigator.of(context).pop();
          },
          child: Text(
            'Remove Discount',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
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
            final discAmt = _previewNotifier.value;
            widget.onApply(_typeNotifier.value, discAmt);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
