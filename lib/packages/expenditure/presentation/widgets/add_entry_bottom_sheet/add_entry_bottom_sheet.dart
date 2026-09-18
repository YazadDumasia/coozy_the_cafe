import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/invoice_management/domain/usecases/get_payment_modes_usecase.dart';
import 'package:coozy_the_cafe/packages/checkout/checkout.dart';
import '../../../domain/entities/expenditure_entity.dart';

class AddEntryBottomSheet extends StatefulWidget {
  final String categoryName;
  final String type; // 'EXPENSE' or 'INCOME'
  final int? categoryId;

  const AddEntryBottomSheet({
    super.key,
    required this.categoryName,
    required this.type,
    this.categoryId,
  });

  @override
  State<AddEntryBottomSheet> createState() => _AddEntryBottomSheetState();
}

class _AddEntryBottomSheetState extends State<AddEntryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _partyFocusNode = FocusNode();
  final FocusNode _notesFocusNode = FocusNode();

  static const List<PaymentMethod> _defaultPaymentMethods = [
    PaymentMethod(
      id: 'cash',
      name: 'Cash',
      icon: Icons.payments,
      isEnabled: true,
    ),
    PaymentMethod(
      id: 'debit_card',
      name: 'Debit Card',
      icon: Icons.credit_card,
      isEnabled: true,
    ),
    PaymentMethod(
      id: 'credit_card',
      name: 'Credit Card',
      icon: Icons.credit_card,
      isEnabled: true,
    ),
    PaymentMethod(
      id: 'credit',
      name: 'Credit',
      icon: Icons.account_balance_wallet,
      isEnabled: true,
    ),
    PaymentMethod(id: 'upi', name: 'UPI', icon: Icons.qr_code, isEnabled: true),
    PaymentMethod(
      id: 'bitcoin',
      name: 'Bitcoin',
      icon: Icons.currency_bitcoin,
      isEnabled: true,
    ),
  ];

  late final ValueNotifier<List<PaymentMethod>> _methodsNotifier;
  late final ValueNotifier<PaymentMethod?> _selectedMethodNotifier;

  @override
  void initState() {
    super.initState();
    _methodsNotifier = ValueNotifier<List<PaymentMethod>>(
      List<PaymentMethod>.from(_defaultPaymentMethods),
    );
    _selectedMethodNotifier = ValueNotifier<PaymentMethod?>(
      _defaultPaymentMethods.first,
    );
    _loadPaymentModes();
  }

  IconData _iconForPaymentMode(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('cash')) return Icons.payments;
    if (lower.contains('debit') ||
        lower.contains('credit card') ||
        lower.contains('card')) {
      return Icons.credit_card;
    }
    if (lower.contains('upi') ||
        lower.contains('qr') ||
        lower.contains('gpay') ||
        lower.contains('phonepe') ||
        lower.contains('paytm')) {
      return Icons.qr_code;
    }
    if (lower.contains('credit') || lower.contains('wallet')) {
      return Icons.account_balance_wallet;
    }
    if (lower.contains('bitcoin') || lower.contains('crypto')) {
      return Icons.currency_bitcoin;
    }
    if (lower.contains('bank') ||
        lower.contains('net') ||
        lower.contains('neft') ||
        lower.contains('rtgs')) {
      return Icons.account_balance;
    }
    return Icons.payment;
  }

  Future<void> _loadPaymentModes() async {
    final useCase = GetIt.instance<GetPaymentModesUseCase>();
    final result = await useCase();
    if (!mounted) return;

    result.fold((_) {}, (modes) {
      if (!mounted) return;
      final merged = List<PaymentMethod>.from(_defaultPaymentMethods);
      for (final mode in modes) {
        if (!merged.any(
          (m) => m.name.toLowerCase() == mode.paymentMethodName.toLowerCase(),
        )) {
          merged.add(
            PaymentMethod(
              id: 'db_${mode.id}',
              name: mode.paymentMethodName,
              icon: _iconForPaymentMode(mode.paymentMethodName),
              isEnabled: true,
            ),
          );
        }
      }
      _methodsNotifier.value = merged;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _partyController.dispose();
    _notesController.dispose();
    _amountFocusNode.dispose();
    _partyFocusNode.dispose();
    _notesFocusNode.dispose();
    _methodsNotifier.dispose();
    _selectedMethodNotifier.dispose();
    super.dispose();
  }

  void _openAddPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            child: AddPaymentMethodDialog(
              onPaymentMethodAdded: (newMethod) {
                final currentList = List<PaymentMethod>.from(
                  _methodsNotifier.value,
                );
                final exists = currentList.any(
                  (m) =>
                      m.name.trim().toLowerCase() ==
                      newMethod.name.trim().toLowerCase(),
                );
                if (!exists) {
                  currentList.add(newMethod);
                  _methodsNotifier.value = currentList;
                }
                _selectedMethodNotifier.value = newMethod;
              },
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final party = _partyController.text.trim();
      final notes = _notesController.text.trim();
      final selectedMethod = _selectedMethodNotifier.value;

      final entry = ExpenditureEntity(
        type: widget.type,
        categoryId: widget.categoryId,
        categoryName: widget.categoryName,
        amount: amount,
        partyName: party.isNotEmpty ? party : null,
        date: DateTime.now().toIso8601String(),
        paymentMethod: selectedMethod?.name ?? 'Cash',
        notes: notes.isNotEmpty ? notes : null,
      );

      Navigator.of(context).pop(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpense = widget.type == 'EXPENSE';

    return SafeArea(
      top: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bottom sheet drag handle indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isExpense
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.green.withValues(alpha: 0.15),
                    child: Text(
                      widget.categoryName.isNotEmpty
                          ? widget.categoryName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isExpense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isExpense
                              ? (context.tr(
                                      shared.LocaleKeys.expenditureNewExpense,
                                      track: shared
                                          .TrackConstants
                                          .expenditurePageTrack,
                                    ) ??
                                    'New Expense Record')
                              : (context.tr(
                                      shared.LocaleKeys.expenditureNewIncome,
                                      track: shared
                                          .TrackConstants
                                          .expenditurePageTrack,
                                    ) ??
                                    'New Income Record'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Scrollable Form Content
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Amount Field
                        ValueListenableBuilder<String>(
                          valueListenable:
                              core.CurrencyFormatter.activeSymbolNotifier,
                          builder: (context, symbol, _) {
                            final rawLabel =
                                context.tr(
                                  shared.LocaleKeys.expenditureAmountLabel,
                                  track: shared
                                      .TrackConstants
                                      .expenditurePageTrack,
                                ) ??
                                'Amount';
                            final amountLabel = rawLabel
                                .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
                                .trim();

                            return TextFormField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              autofocus: true,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_partyFocusNode),
                              decoration: InputDecoration(
                                labelText: '$amountLabel ($symbol)',
                                hintText:
                                    context.tr(
                                      shared.LocaleKeys.expenditureAmountHint,
                                      track: shared
                                          .TrackConstants
                                          .expenditurePageTrack,
                                    ) ??
                                    'e.g. 250',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Center(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Text(
                                      symbol,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return context.tr(
                                        shared
                                            .LocaleKeys
                                            .expenditureAmountRequired,
                                        track: shared
                                            .TrackConstants
                                            .expenditurePageTrack,
                                      ) ??
                                      'Please enter amount';
                                }
                                final num = double.tryParse(val.trim());
                                if (num == null || num <= 0) {
                                  return context.tr(
                                        shared
                                            .LocaleKeys
                                            .expenditureAmountValid,
                                        track: shared
                                            .TrackConstants
                                            .expenditurePageTrack,
                                      ) ??
                                      'Please enter a valid amount';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Party / Vendor / Person Name
                        TextFormField(
                          controller: _partyController,
                          focusNode: _partyFocusNode,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => FocusScope.of(
                            context,
                          ).requestFocus(_notesFocusNode),
                          decoration: InputDecoration(
                            labelText: isExpense
                                ? (context.tr(
                                        shared.LocaleKeys.expenditurePaidTo,
                                        track: shared
                                            .TrackConstants
                                            .expenditurePageTrack,
                                      ) ??
                                      'Paid To (Person / Vendor)')
                                : (context.tr(
                                        shared
                                            .LocaleKeys
                                            .expenditureReceivedFrom,
                                        track: shared
                                            .TrackConstants
                                            .expenditurePageTrack,
                                      ) ??
                                      'Received From'),
                            prefixIcon: const Icon(Icons.person_outline),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Payment Mode (Checkout-style grid + custom add) ────────
                        Text(
                          context.tr(
                                shared.LocaleKeys.expenditurePaymentMode,
                                track:
                                    shared.TrackConstants.expenditurePageTrack,
                              ) ??
                              'Payment Mode',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ValueListenableBuilder<List<PaymentMethod>>(
                          valueListenable: _methodsNotifier,
                          builder: (context, methods, _) {
                            return ValueListenableBuilder<PaymentMethod?>(
                              valueListenable: _selectedMethodNotifier,
                              builder: (context, selectedMethod, _) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisExtent: 58,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount: methods.length + 1,
                                  itemBuilder: (context, index) {
                                    // "+ Add New" Tile
                                    if (index == methods.length) {
                                      return InkWell(
                                        onTap: () =>
                                            _openAddPaymentMethodDialog(
                                              context,
                                            ),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.35),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: colorScheme.outlineVariant,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_circle_outline,
                                                color: colorScheme.primary,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  context.tr(
                                                        shared
                                                            .LocaleKeys
                                                            .checkoutAddNew,
                                                        track: shared
                                                            .TrackConstants
                                                            .checkoutPageTrack,
                                                      ) ??
                                                      '+ Add New',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.primary,
                                                    fontSize: 13,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    final method = methods[index];
                                    final isSelected =
                                        selectedMethod?.id == method.id;

                                    return InkWell(
                                      onTap: () {
                                        _selectedMethodNotifier.value = method;
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primaryContainer
                                              : colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.outlineVariant,
                                            width: isSelected ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              method.icon,
                                              size: 22,
                                              color: isSelected
                                                  ? colorScheme.primary
                                                  : colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                method.name,
                                                style: TextStyle(
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? colorScheme
                                                            .onPrimaryContainer
                                                      : colorScheme.onSurface,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isSelected)
                                              Icon(
                                                Icons.check_circle,
                                                color: colorScheme.primary,
                                                size: 18,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        // ─────────────────────────────────────────────────────────────
                        const SizedBox(height: 16),

                        // Notes / Remarks
                        TextFormField(
                          controller: _notesController,
                          focusNode: _notesFocusNode,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          minLines: 3,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText:
                                context.tr(
                                  shared.LocaleKeys.expenditureNotesLabel,
                                  track: shared
                                      .TrackConstants
                                      .expenditurePageTrack,
                                ) ??
                                'Notes / Remarks (Optional)',
                            hintText:
                                context.tr(
                                  shared.LocaleKeys.expenditureNotesHint,
                                  track: shared
                                      .TrackConstants
                                      .expenditurePageTrack,
                                ) ??
                                'Additional details...',
                            contentPadding: const EdgeInsets.all(16),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isExpense
                                ? Colors.red
                                : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isExpense
                                ? (context.tr(
                                        shared
                                            .LocaleKeys
                                            .expenditureSaveExpense,
                                        track: shared
                                            .TrackConstants
                                            .expenditurePageTrack,
                                      ) ??
                                      'SAVE EXPENSE')
                                : (context.tr(
                                        shared.LocaleKeys.expenditureSaveIncome,
                                        track: shared
                                            .TrackConstants
                                            .expenditurePageTrack,
                                      ) ??
                                      'SAVE INCOME'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
