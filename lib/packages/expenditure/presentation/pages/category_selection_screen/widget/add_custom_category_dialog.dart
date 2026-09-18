import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AddCustomCategoryDialog extends StatefulWidget {
  final String type; // 'EXPENSE' or 'INCOME'

  const AddCustomCategoryDialog({super.key, required this.type});

  @override
  State<AddCustomCategoryDialog> createState() =>
      _AddCustomCategoryDialogState();
}

class _AddCustomCategoryDialogState extends State<AddCustomCategoryDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.type == 'EXPENSE';
    final typeText = isExpense
        ? (context.tr(
                shared.LocaleKeys.expenditureExpense,
                track: shared.TrackConstants.expenditurePageTrack,
              ) ??
              'Expense')
        : (context.tr(
                shared.LocaleKeys.expenditureIncome,
                track: shared.TrackConstants.expenditurePageTrack,
              ) ??
              'Income');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.tr(
              shared.LocaleKeys.expenditureAddCustomCategory,
              params: {'type': typeText},
              track: shared.TrackConstants.expenditurePageTrack,
            ) ??
            'Add Custom $typeText Category',
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          decoration: InputDecoration(
            labelText:
                context.tr(
                  shared.LocaleKeys.expenditureCategoryNameLabel,
                  track: shared.TrackConstants.expenditurePageTrack,
                ) ??
                'Category Name',
            hintText: isExpense
                ? (context.tr(
                        shared.LocaleKeys.expenditureCategoryHintExpense,
                        track: shared.TrackConstants.expenditurePageTrack,
                      ) ??
                      'e.g. Electricity, Maintenance')
                : (context.tr(
                        shared.LocaleKeys.expenditureCategoryHintIncome,
                        track: shared.TrackConstants.expenditurePageTrack,
                      ) ??
                      'e.g. Consulting, Freelance'),
            border: const OutlineInputBorder(),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return context.tr(
                    shared.LocaleKeys.expenditureCategoryNameRequired,
                    track: shared.TrackConstants.expenditurePageTrack,
                  ) ??
                  'Please enter category name';
            }
            return null;
          },
        ),
      ),
      actions: [
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
        ElevatedButton(
          onPressed: _submit,
          child: Text(
            context.tr(
                  shared.LocaleKeys.expenditureAdd,
                  track: shared.TrackConstants.expenditurePageTrack,
                ) ??
                (context.tr(
                      shared.LocaleKeys.commonAdd,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Add'),
          ),
        ),
      ],
    );
  }
}
