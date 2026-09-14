import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import '../../models/tax_model/tax_model.dart';

class AddTaxDialog extends StatefulWidget {
  final String? initialName;
  final double? initialRate;
  final bool? initialIsDefaultAdd;
  final Function(Tax) onTaxAdded;

  const AddTaxDialog({
    super.key,
    this.initialName,
    this.initialRate,
    this.initialIsDefaultAdd,
    required this.onTaxAdded,
  });

  @override
  State<AddTaxDialog> createState() => _AddTaxDialogState();
}

class _AddTaxDialogState extends State<AddTaxDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _rateController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _rateFocusNode;
  late final ValueNotifier<bool> _isDefaultAddNotifier;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _rateController = TextEditingController(
      text: widget.initialRate != null
          ? (widget.initialRate! % 1 == 0
              ? widget.initialRate!.toInt().toString()
              : widget.initialRate!.toString())
          : '',
    );
    _isDefaultAddNotifier = ValueNotifier<bool>(widget.initialIsDefaultAdd ?? false);
    _nameFocusNode = FocusNode();
    _rateFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateController.dispose();
    _nameFocusNode.dispose();
    _rateFocusNode.dispose();
    _isDefaultAddNotifier.dispose();
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
        isDefaultAdd: _isDefaultAddNotifier.value,
      );
      widget.onTaxAdded(tax);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    shared.LocaleKeys.checkoutAddTax,
                    track: shared.TrackConstants.checkoutPageTrack,
                  ) ??
                  'Add Tax Value',
              style: theme.textTheme.titleLarge?.copyWith(
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
                prefixIcon: Icon(Icons.receipt_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter tax name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateController,
              focusNode: _rateFocusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Tax Rate in %',
                border: OutlineInputBorder(),
                suffixText: '%',
                prefixIcon: Icon(Icons.percent),
              ),
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter tax percentage';
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter valid percentage';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<bool>(
              valueListenable: _isDefaultAddNotifier,
              builder: (context, isDefaultAdd, _) {
                return CheckboxListTile(
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutDefaultAddToBill,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Always add this Tax in cart',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: isDefaultAdd,
                  onChanged: (val) {
                    _isDefaultAddNotifier.value = val ?? false;
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: _submit,
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutAddTax,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Add Tax',
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
