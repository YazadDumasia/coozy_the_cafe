import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import '../../models/discount_model/discount_model.dart';

class AddDiscountDialog extends StatefulWidget {
  final String? initialName;
  final double? initialValue;
  final bool? initialIsPercentage;
  final bool? initialIsDefaultAdd;
  final Function(Discount) onDiscountAdded;

  const AddDiscountDialog({
    super.key,
    this.initialName,
    this.initialValue,
    this.initialIsPercentage,
    this.initialIsDefaultAdd,
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
  late final ValueNotifier<bool> _isPercentageNotifier;
  late final ValueNotifier<bool> _isDefaultAddNotifier;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _valueController = TextEditingController(
      text: widget.initialValue != null
          ? (widget.initialValue! % 1 == 0
              ? widget.initialValue!.toInt().toString()
              : widget.initialValue!.toString())
          : '',
    );
    _isPercentageNotifier =
        ValueNotifier<bool>(widget.initialIsPercentage ?? false);
    _isDefaultAddNotifier =
        ValueNotifier<bool>(widget.initialIsDefaultAdd ?? false);
    _nameFocusNode = FocusNode();
    _valueFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _nameFocusNode.dispose();
    _valueFocusNode.dispose();
    _isPercentageNotifier.dispose();
    _isDefaultAddNotifier.dispose();
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
        isPercentage: _isPercentageNotifier.value,
        isDefaultAdd: _isDefaultAddNotifier.value,
      );
      widget.onDiscountAdded(discount);
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
                    shared.LocaleKeys.checkoutAddDiscount,
                    track: shared.TrackConstants.checkoutPageTrack,
                  ) ??
                  'Add Discount Value',
              style: theme.textTheme.titleLarge?.copyWith(
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
                prefixIcon: Icon(Icons.discount_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter discount name' : null,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: _isPercentageNotifier,
              builder: (context, isPercentage, _) {
                return TextFormField(
                  controller: _valueController,
                  focusNode: _valueFocusNode,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isPercentage
                        ? 'Discount Value in %'
                        : 'Discount Value',
                    border: const OutlineInputBorder(),
                    prefixText: isPercentage
                        ? null
                        : '${core.CurrencyFormatter.primarySymbol} ',
                    suffixText: isPercentage ? '%' : null,
                    hintText: isPercentage ? '0%' : '0.00',
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter discount value';
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'Enter valid number';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                );
              },
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<bool>(
              valueListenable: _isPercentageNotifier,
              builder: (context, isPercentage, _) {
                return CheckboxListTile(
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutPercentageQuestion,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Percentage (%) ?',
                    style: theme.textTheme.bodyMedium,
                  ),
                  value: isPercentage,
                  onChanged: (val) {
                    _isPercentageNotifier.value = val ?? false;
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isDefaultAddNotifier,
              builder: (context, isDefaultAdd, _) {
                return CheckboxListTile(
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutDefaultAddToBill,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Always add this Discount in cart',
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
