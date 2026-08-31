import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import '../../../../domain/entities/extra_charge.dart';

class AddOtherChargeDialog extends StatefulWidget {
  final String? initialName;
  final Function(ExtraCharge) onChargeAdded;

  const AddOtherChargeDialog({
    super.key,
    this.initialName,
    required this.onChargeAdded,
  });

  @override
  State<AddOtherChargeDialog> createState() => _AddOtherChargeDialogState();
}

class _AddOtherChargeDialogState extends State<AddOtherChargeDialog> {
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
      final charge = ExtraCharge(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        value: value,
        isPercentage: _isPercentage,
        isDefaultAdd: _isDefaultAdd,
      );
      widget.onChargeAdded(charge);
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
                    shared.LocaleKeys.checkoutAddOtherFee,
                    track: shared.TrackConstants.checkoutPageTrack,
                  ) ??
                  'Add Other Fee',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: InputDecoration(
                labelText: context.tr(
                      shared.LocaleKeys.checkoutOtherName,
                      track: shared.TrackConstants.checkoutPageTrack,
                    ) ??
                    'Other Name',
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => v == null || v.trim().isEmpty
                  ? (context.tr(
                        shared.LocaleKeys.checkoutEnterFeeName,
                        track: shared.TrackConstants.checkoutPageTrack,
                      ) ??
                      'Enter fee name')
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueController,
              focusNode: _valueFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _isPercentage
                    ? (context.tr(
                          shared.LocaleKeys.checkoutOtherValuePercent,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Other Value in %')
                    : (context.tr(
                          shared.LocaleKeys.checkoutOtherValue,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Other Value'),
                border: const OutlineInputBorder(),
                suffixText: _isPercentage ? '%' : null,
              ),
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return context.tr(
                        shared.LocaleKeys.checkoutEnterFeeValue,
                        track: shared.TrackConstants.checkoutPageTrack,
                      ) ??
                      'Enter fee value';
                }
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
                          shared.LocaleKeys.checkoutAddFee,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Add Fee',
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
