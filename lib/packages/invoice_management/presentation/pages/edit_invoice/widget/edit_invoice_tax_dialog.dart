import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

class EditInvoiceTaxDialog extends StatefulWidget {
  final double currentSubtotal;
  final double initialTaxPercentage;
  final double initialTaxCost;
  final void Function(double percentage, double cost) onApply;

  const EditInvoiceTaxDialog({
    super.key,
    required this.currentSubtotal,
    required this.initialTaxPercentage,
    required this.initialTaxCost,
    required this.onApply,
  });

  @override
  State<EditInvoiceTaxDialog> createState() => _EditInvoiceTaxDialogState();
}

class _EditInvoiceTaxDialogState extends State<EditInvoiceTaxDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _percentController;
  late final TextEditingController _amountController;
  late final FocusNode _percentFocusNode;
  late final FocusNode _amountFocusNode;

  bool _isUpdatingFromPercent = false;
  bool _isUpdatingFromAmount = false;

  @override
  void initState() {
    super.initState();
    _percentController = TextEditingController(
      text: widget.initialTaxPercentage > 0
          ? widget.initialTaxPercentage.toString()
          : '',
    );
    _amountController = TextEditingController(
      text: widget.initialTaxCost > 0
          ? widget.initialTaxCost.toStringAsFixed(2)
          : '',
    );
    _percentFocusNode = FocusNode();
    _amountFocusNode = FocusNode();

    _percentController.addListener(_onPercentChanged);
    _amountController.addListener(_onAmountChanged);
  }

  void _onPercentChanged() {
    if (_isUpdatingFromAmount) return;
    _isUpdatingFromPercent = true;
    final pct = double.tryParse(_percentController.text);
    if (pct != null && widget.currentSubtotal > 0) {
      final amt = (widget.currentSubtotal * (pct / 100.0));
      _amountController.text = amt.toStringAsFixed(2);
    }
    _isUpdatingFromPercent = false;
  }

  void _onAmountChanged() {
    if (_isUpdatingFromPercent) return;
    _isUpdatingFromAmount = true;
    final amt = double.tryParse(_amountController.text);
    if (amt != null && widget.currentSubtotal > 0) {
      final pct = (amt / widget.currentSubtotal) * 100.0;
      _percentController.text = pct.toStringAsFixed(2);
    }
    _isUpdatingFromAmount = false;
  }

  @override
  void dispose() {
    _percentController.removeListener(_onPercentChanged);
    _amountController.removeListener(_onAmountChanged);
    _percentController.dispose();
    _amountController.dispose();
    _percentFocusNode.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Adjust Tax',
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
              TextFormField(
                controller: _percentController,
                focusNode: _percentFocusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tax Percentage (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                  hintText: 'e.g. 5, 12, 18',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Tax Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                  hintText: 'e.g. 25.00',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [5, 12, 18].map((rate) {
                  return ActionChip(
                    label: Text('$rate%'),
                    onPressed: () {
                      _percentController.text = rate.toString();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onApply(0.0, 0.0);
            Navigator.of(context).pop();
          },
          child: Text(
            'Remove Tax',
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
            final pct = double.tryParse(_percentController.text) ?? 0.0;
            final amt = double.tryParse(_amountController.text) ?? 0.0;
            widget.onApply(pct, amt);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
