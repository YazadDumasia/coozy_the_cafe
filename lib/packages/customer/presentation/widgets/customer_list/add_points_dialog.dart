import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/usecases/customer_usecases.dart';

class AddPointsDialog extends StatefulWidget {
  const AddPointsDialog({super.key, required this.customer});

  final CustomerEntity customer;

  static Future<bool?> show(BuildContext context, CustomerEntity customer) {
    if (shared.ResponsiveLayout.isMobile(context)) {
      return showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => AddPointsDialog(customer: customer),
      );
    } else {
      final isDesktop = shared.ResponsiveLayout.isDesktop(context);
      return showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 480 : 420,
            ),
            child: SingleChildScrollView(
              child: AddPointsDialog(customer: customer),
            ),
          ),
        ),
      );
    }
  }

  @override
  State<AddPointsDialog> createState() => _AddPointsDialogState();
}

class _AddPointsDialogState extends State<AddPointsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _pointsController;
  late final TextEditingController _notesController;
  late final FocusNode _pointsFocusNode;
  late final FocusNode _notesFocusNode;
  final ValueNotifier<bool> _isSubmittingNotifier = ValueNotifier<bool>(false);

  final List<int> _quickPresets = const [25, 50, 100, 250, 500];

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController();
    _notesController = TextEditingController(text: 'Manual adjustment / Bonus');
    _pointsFocusNode = FocusNode();
    _notesFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _notesController.dispose();
    _pointsFocusNode.dispose();
    _notesFocusNode.dispose();
    _isSubmittingNotifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final points = int.tryParse(_pointsController.text.trim()) ?? 0;
    if (points <= 0) return;

    final customerId = widget.customer.id;
    if (customerId == null) return;

    _isSubmittingNotifier.value = true;
    try {
      final addLoyaltyPointsUseCase = GetIt.I<AddLoyaltyPointsUseCase>();
      await addLoyaltyPointsUseCase(
        customerId: customerId,
        points: points,
        billAmount: 0.0,
        notes: _notesController.text.trim().isEmpty
            ? 'Manual bonus'
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _isSubmittingNotifier.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add points: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.stars_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Loyalty Points',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.customer.name ?? 'Customer',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick presets
            Text(
              'Quick Select Points',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickPresets.map((pts) {
                return ActionChip(
                  label: Text('+$pts pts'),
                  avatar: const Icon(Icons.add, size: 14),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.12),
                  onPressed: () {
                    _pointsController.text = pts.toString();
                    _notesFocusNode.requestFocus();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Points input
            TextFormField(
              controller: _pointsController,
              focusNode: _pointsFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _notesFocusNode.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Points to Add *',
                hintText: 'e.g. 100',
                prefixIcon: const Icon(Icons.toll_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter points amount';
                }
                final pts = int.tryParse(value.trim());
                if (pts == null || pts <= 0) {
                  return 'Points must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Notes / Reason
            TextFormField(
              controller: _notesController,
              focusNode: _notesFocusNode,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Reason / Notes',
                hintText: 'e.g. Birthday gift, promotional bonus',
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isSubmittingNotifier,
                    builder: (context, isSubmitting, child) {
                      return ElevatedButton.icon(
                        onPressed: isSubmitting ? null : _submit,
                        icon: isSubmitting
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.add_task_rounded),
                        label: Text(isSubmitting ? 'Adding...' : 'Add Points'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
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
