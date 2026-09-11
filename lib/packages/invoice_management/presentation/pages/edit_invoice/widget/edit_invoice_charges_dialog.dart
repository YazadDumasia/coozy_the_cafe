import 'package:flutter/material.dart';

class EditInvoiceChargesDialog extends StatefulWidget {
  final double initialCharges;
  final void Function(double charges) onApply;

  const EditInvoiceChargesDialog({
    super.key,
    required this.initialCharges,
    required this.onApply,
  });

  @override
  State<EditInvoiceChargesDialog> createState() =>
      _EditInvoiceChargesDialogState();
}

class _EditInvoiceChargesDialogState extends State<EditInvoiceChargesDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _chargesController;
  late final FocusNode _chargesFocusNode;

  @override
  void initState() {
    super.initState();
    _chargesController = TextEditingController(
      text: widget.initialCharges > 0
          ? widget.initialCharges.toStringAsFixed(2)
          : '',
    );
    _chargesFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _chargesController.dispose();
    _chargesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Other Charges',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _chargesController,
              focusNode: _chargesFocusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Additional Charges (e.g. Delivery / Service)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
                hintText: 'e.g. 20.00',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Please enter a valid amount';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onApply(0.0);
            Navigator.of(context).pop();
          },
          child: Text(
            'Clear Charges',
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
            if (_formKey.currentState?.validate() ?? false) {
              final amt = double.tryParse(_chargesController.text) ?? 0.0;
              widget.onApply(amt);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
