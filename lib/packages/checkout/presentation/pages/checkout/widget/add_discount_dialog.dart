import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import '../../../../domain/entities/discount.dart';

class AddDiscountDialog extends StatefulWidget {
  final String? initialName;
  final Function(Discount) onDiscountAdded;

  const AddDiscountDialog({
    super.key,
    this.initialName,
    required this.onDiscountAdded,
  });

  @override
  State<AddDiscountDialog> createState() => _AddDiscountDialogState();
}

class _AddDiscountDialogState extends State<AddDiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _valueFocusNode;
  bool _isPercentage = false;
  bool _isDefaultAdd = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _valueController = TextEditingController();
    _nameFocusNode = FocusNode();
    _valueFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _nameFocusNode.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final value = double.tryParse(_valueController.text.trim()) ?? 0.0;
      final discount = Discount(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        value: value,
        isPercentage: _isPercentage,
        isDefaultAdd: _isDefaultAdd,
      );
      widget.onDiscountAdded(discount);
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
              context.tr(
                    shared.LocaleKeys.checkoutAddDiscount,
                    track: shared.TrackConstants.checkoutPageTrack,
                  ) ??
                  'Add Discount Value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: const InputDecoration(
                labelText: 'Discount Name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter discount name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueController,
              focusNode: _valueFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _isPercentage ? 'Discount Value in %' : 'Discount Value',
                border: const OutlineInputBorder(),
                suffixText: _isPercentage ? '%' : null,
              ),
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter discount value';
                if (double.tryParse(v.trim()) == null) return 'Enter valid number';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: Text(
                context.tr(
                      shared.LocaleKeys.checkoutPercentageQuestion,
                      track: shared.TrackConstants.checkoutPageTrack,
                    ) ??
                    'Percentage (%) ?',
              ),
              value: _isPercentage,
              onChanged: (val) {
                setState(() {
                  _isPercentage = val ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              title: Text(
                context.tr(
                      shared.LocaleKeys.checkoutDefaultAddToBill,
                      track: shared.TrackConstants.checkoutPageTrack,
                    ) ??
                    'Default Add to Bill',
              ),
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
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.commonCancel,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Cancel',
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutAddDiscount,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Add Discount',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
