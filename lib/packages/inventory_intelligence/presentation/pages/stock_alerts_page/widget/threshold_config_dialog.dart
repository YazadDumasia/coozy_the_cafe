import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class ThresholdConfigDialog extends StatefulWidget {
  final int inventoryId;
  final String itemName;
  final double currentMinThreshold;
  final double currentReorderQuantity;
  final bool currentAutoReorder;
  final void Function(
    double minThreshold,
    double reorderQuantity,
    bool autoReorder,
  )
  onSave;

  const ThresholdConfigDialog({
    super.key,
    required this.inventoryId,
    required this.itemName,
    required this.currentMinThreshold,
    required this.currentReorderQuantity,
    required this.currentAutoReorder,
    required this.onSave,
  });

  @override
  State<ThresholdConfigDialog> createState() => _ThresholdConfigDialogState();
}

class _ThresholdConfigDialogState extends State<ThresholdConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _minThresholdController;
  late final TextEditingController _reorderQtyController;
  late final FocusNode _minThresholdFocus;
  late final FocusNode _reorderQtyFocus;
  late final ValueNotifier<bool> _autoReorderNotifier;

  @override
  void initState() {
    super.initState();
    _minThresholdController = TextEditingController(
      text: widget.currentMinThreshold.toString(),
    );
    _reorderQtyController = TextEditingController(
      text: widget.currentReorderQuantity.toString(),
    );
    _minThresholdFocus = FocusNode();
    _reorderQtyFocus = FocusNode();
    _autoReorderNotifier = ValueNotifier<bool>(widget.currentAutoReorder);
  }

  @override
  void dispose() {
    _minThresholdController.dispose();
    _reorderQtyController.dispose();
    _minThresholdFocus.dispose();
    _reorderQtyFocus.dispose();
    _autoReorderNotifier.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final minThreshold =
          double.tryParse(_minThresholdController.text) ??
          widget.currentMinThreshold;
      final reorderQty =
          double.tryParse(_reorderQtyController.text) ??
          widget.currentReorderQuantity;
      widget.onSave(minThreshold, reorderQty, _autoReorderNotifier.value);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isDesktop ? 500 : 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Configure Safety Stock',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Item: ${widget.itemName}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Min Threshold input
                TextFormField(
                  controller: _minThresholdController,
                  focusNode: _minThresholdFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Minimum Safety Threshold Qty',
                    helperText: 'Alert triggers when stock drops at or below this level',
                    prefixIcon: Icon(Icons.warning_amber_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter minimum threshold';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed < 0) {
                      return 'Enter a valid non-negative number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Suggested Reorder Quantity
                TextFormField(
                  controller: _reorderQtyController,
                  focusNode: _reorderQtyFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Suggested Reorder Quantity',
                    helperText: 'Quantity populated when generating 1-click purchase order',
                    prefixIcon: Icon(Icons.add_shopping_cart_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter reorder quantity';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a positive quantity greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Auto-Reorder switch
                ValueListenableBuilder<bool>(
                  valueListenable: _autoReorderNotifier,
                  builder: (context, autoReorder, child) {
                    return SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto-Reorder Eligibility'),
                      subtitle: const Text('Include in 1-click batch reorders'),
                      value: autoReorder,
                      onChanged: (val) {
                        _autoReorderNotifier.value = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _submit,
                      child: const Text('Save Threshold'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
