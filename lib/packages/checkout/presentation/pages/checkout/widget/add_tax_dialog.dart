import 'package:flutter/material.dart';
import '../../../../domain/entities/tax.dart';

class AddTaxDialog extends StatefulWidget {
  final Function(Tax) onTaxAdded;

  const AddTaxDialog({super.key, required this.onTaxAdded});

  @override
  State<AddTaxDialog> createState() => _AddTaxDialogState();
}

class _AddTaxDialogState extends State<AddTaxDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _rateFocusNode;
  bool _isDefaultAdd = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _rateController = TextEditingController();
    _nameFocusNode = FocusNode();
    _rateFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _nameFocusNode.dispose();
    _rateFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
      final tax = Tax(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        ratePercent: rate,
        isDefaultAdd: _isDefaultAdd,
      );
      widget.onTaxAdded(tax);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Tax Value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: const InputDecoration(
                labelText: 'Tax Name (GST / CGST+IGST / VAT)',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter tax name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateController,
              focusNode: _rateFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tax Value in %',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter tax percentage';
                if (double.tryParse(v.trim()) == null) return 'Enter valid number';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: const Text('Default Add to Bill'),
              value: _isDefaultAdd,
              onChanged: (val) {
                setState(() {
                  _isDefaultAdd = val ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Add Tax'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
