import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/waiter_order_placement.dart';
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';
import 'edit_invoice_screen_actions.dart';
import 'widget/add_invoice_item_dialog.dart';
import 'widget/edit_invoice_item_dialog.dart';

class EditInvoiceScreen extends StatefulWidget {
  final InvoiceDetailsEntity details;

  const EditInvoiceScreen({super.key, required this.details});

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _nameController;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _nameFocusNode;

  late final ValueNotifier<InvoiceEntity> _invoiceNotifier;
  late final ValueNotifier<List<InvoiceItemEntity>> _itemsNotifier;
  late final ValueNotifier<String> _paymentMethodNotifier;
  late final ValueNotifier<bool> _isSavingNotifier;

  late final ValueNotifier<List<shared.Tax>> _appliedTaxesNotifier;
  late final ValueNotifier<List<shared.Discount>> _appliedDiscountsNotifier;
  late final ValueNotifier<List<shared.ExtraCharge>> _appliedChargesNotifier;
  late final ValueNotifier<bool> _isRoundOffEnabledNotifier;
  late final ValueNotifier<shared.BillSummary> _summaryNotifier;

  @override
  void initState() {
    super.initState();
    final invoice = widget.details.invoice;
    _invoiceNotifier = ValueNotifier<InvoiceEntity>(invoice);
    _itemsNotifier =
        ValueNotifier<List<InvoiceItemEntity>>(List.from(widget.details.items));

    String initialPaymentMethod = 'UPI';
    if (invoice.paymentMethodName != null &&
        invoice.paymentMethodName!.isNotEmpty) {
      initialPaymentMethod = invoice.paymentMethodName!;
    }
    _paymentMethodNotifier = ValueNotifier<String>(initialPaymentMethod);
    _isSavingNotifier = ValueNotifier<bool>(false);

    _phoneController = TextEditingController(text: invoice.phoneNumber ?? '');
    _nameController = TextEditingController(text: invoice.customerName ?? '');
    _phoneFocusNode = FocusNode();
    _nameFocusNode = FocusNode();

    // Parse existing paymentMethodDetails JSON if available to restore applied taxes, discounts, charges, round-off
    List<shared.Tax> initialTaxes = [];
    List<shared.Discount> initialDiscounts = [];
    List<shared.ExtraCharge> initialCharges = [];
    bool initialRoundOff = false;

    if (invoice.paymentMethodDetails != null &&
        invoice.paymentMethodDetails!.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(invoice.paymentMethodDetails!);
        if (decoded is Map<String, dynamic>) {
          if (decoded['taxDetails'] is List) {
            for (final t in decoded['taxDetails']) {
              if (t is Map<String, dynamic>) {
                final rate = (t['ratePercent'] as num?)?.toDouble() ?? 0.0;
                final name = t['name']?.toString() ?? 'Tax';
                initialTaxes.add(shared.Tax(
                  id: 'tax_${initialTaxes.length}_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  ratePercent: rate,
                ));
              }
            }
          }
          if (decoded['discountDetails'] is List) {
            for (final d in decoded['discountDetails']) {
              if (d is Map<String, dynamic>) {
                final val = (d['amount'] as num?)?.toDouble() ?? 0.0;
                final name = d['name']?.toString() ?? 'Discount';
                initialDiscounts.add(shared.Discount(
                  id: 'disc_${initialDiscounts.length}_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  value: val,
                  isPercentage: false,
                ));
              }
            }
          }
          if (decoded['chargeDetails'] is List) {
            for (final c in decoded['chargeDetails']) {
              if (c is Map<String, dynamic>) {
                final val = (c['amount'] as num?)?.toDouble() ?? 0.0;
                final name = c['name']?.toString() ?? 'Charge';
                initialCharges.add(shared.ExtraCharge(
                  id: 'chg_${initialCharges.length}_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  value: val,
                  isPercentage: false,
                ));
              }
            }
          }
          if (decoded['roundingAmount'] != null &&
              ((decoded['roundingAmount'] as num).toDouble()).abs() > 0.0001) {
            initialRoundOff = true;
          }
        }
      } catch (_) {}
    }

    // Fallbacks if breakdown was not in paymentMethodDetails
    if (initialTaxes.isEmpty && invoice.taxPercentage > 0) {
      initialTaxes.add(shared.Tax(
        id: 'tax_legacy_1',
        name: 'Tax (${invoice.taxPercentage.toStringAsFixed(1)}%)',
        ratePercent: invoice.taxPercentage,
      ));
    }
    if (initialDiscounts.isEmpty && invoice.discountAmount > 0) {
      initialDiscounts.add(shared.Discount(
        id: 'disc_legacy_1',
        name: 'Discount',
        value: invoice.discountAmount,
        isPercentage: false,
      ));
    }

    _appliedTaxesNotifier = ValueNotifier<List<shared.Tax>>(initialTaxes);
    _appliedDiscountsNotifier =
        ValueNotifier<List<shared.Discount>>(initialDiscounts);
    _appliedChargesNotifier =
        ValueNotifier<List<shared.ExtraCharge>>(initialCharges);
    _isRoundOffEnabledNotifier = ValueNotifier<bool>(initialRoundOff);
    _summaryNotifier = ValueNotifier<shared.BillSummary>(shared.BillSummary.empty());

    _recalculateTotals();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _phoneFocusNode.dispose();
    _nameFocusNode.dispose();
    _invoiceNotifier.dispose();
    _itemsNotifier.dispose();
    _paymentMethodNotifier.dispose();
    _isSavingNotifier.dispose();
    _appliedTaxesNotifier.dispose();
    _appliedDiscountsNotifier.dispose();
    _appliedChargesNotifier.dispose();
    _isRoundOffEnabledNotifier.dispose();
    _summaryNotifier.dispose();
    super.dispose();
  }

  void _recalculateTotals() {
    final items = _itemsNotifier.value;
    double subtotal = 0.0;
    for (final item in items) {
      subtotal += item.totalPrice;
    }

    final summary = const shared.BillCalculator().calculate(
      subtotal: subtotal,
      appliedTaxes: _appliedTaxesNotifier.value,
      appliedDiscounts: _appliedDiscountsNotifier.value,
      appliedOtherCharges: _appliedChargesNotifier.value,
      isRoundOffEnabled: _isRoundOffEnabledNotifier.value,
    );
    _summaryNotifier.value = summary;

    final breakdownJson = jsonEncode({
      'taxDetails': summary.taxDetails
          .map((t) => {
                'name': t.name,
                'ratePercent': t.ratePercent,
                'amount': t.calculatedAmount,
              })
          .toList(),
      'discountDetails': summary.discountDetails
          .map((d) => {
                'name': d.name,
                'amount': d.calculatedAmount,
              })
          .toList(),
      'chargeDetails': summary.chargeDetails
          .map((c) => {
                'name': c.name,
                'amount': c.calculatedAmount,
              })
          .toList(),
      'roundingAmount': summary.roundingAmount,
    });

    final currentInvoice = _invoiceNotifier.value;
    final primaryTaxRate = _appliedTaxesNotifier.value.isNotEmpty
        ? _appliedTaxesNotifier.value.first.ratePercent
        : 0.0;

    _invoiceNotifier.value = currentInvoice.copyWith(
      totalCost: summary.subtotal,
      taxableAmount: summary.taxableBase,
      discountAmount: summary.totalDiscounts,
      taxPercentage: primaryTaxRate,
      taxCost: summary.totalTaxes,
      netPaymentAmount: summary.grandTotal,
      recordAmountPaid: summary.grandTotal,
      paymentMethodDetails: breakdownJson,
    );
  }

  void _onEditItem(InvoiceItemEntity item, int index) {
    shared.showResponsiveModal(
      context: context,
      child: EditInvoiceItemDialog(
        itemName: item.itemName,
        initialQuantity: item.quantity,
        initialUnitPrice: item.unitPrice,
        onSave: (q, p) {
          final updated = List<InvoiceItemEntity>.from(_itemsNotifier.value);
          updated[index] = item.copyWith(
            quantity: q,
            unitPrice: p,
            totalPrice: q * p,
          );
          _itemsNotifier.value = updated;
          _recalculateTotals();
        },
        onDelete: () {
          final updated = List<InvoiceItemEntity>.from(_itemsNotifier.value);
          updated.removeAt(index);
          _itemsNotifier.value = updated;
          _recalculateTotals();
        },
      ),
    );
  }

  Future<void> _onAddItem() async {
    final result = await context.push(
      WaiterOrderPlacementRoutes.menuItemPickerRoute,
      extra: {
        'isPickerOnly': true,
        'orderId': _invoiceNotifier.value.orderId,
      },
    );

    if (result is List<OrderCartItem> && result.isNotEmpty && mounted) {
      final currentItems = List<InvoiceItemEntity>.from(_itemsNotifier.value);
      for (final cartItem in result) {
        final existingIndex = currentItems.indexWhere(
          (item) =>
              (item.itemId != null && item.itemId == cartItem.menuItemId) ||
              item.itemName.toLowerCase() == cartItem.displayName.toLowerCase(),
        );

        if (existingIndex != -1) {
          final existing = currentItems[existingIndex];
          final newQty = existing.quantity + cartItem.quantity;
          currentItems[existingIndex] = existing.copyWith(
            quantity: newQty,
            totalPrice: newQty * existing.unitPrice,
          );
        } else {
          currentItems.add(
            InvoiceItemEntity(
              id: DateTime.now().millisecondsSinceEpoch + currentItems.length,
              invoiceId: _invoiceNotifier.value.id,
              itemId: cartItem.menuItemId,
              itemName: cartItem.displayName,
              quantity: cartItem.quantity,
              unitPrice: cartItem.price,
              totalPrice: cartItem.totalPrice,
            ),
          );
        }
      }
      _itemsNotifier.value = currentItems;
      _recalculateTotals();
    }
  }

  void _onAddCustomItem() {
    shared.showResponsiveModal(
      context: context,
      child: AddInvoiceItemDialog(
        onAdd: (name, q, p) {
          final newItem = InvoiceItemEntity(
            id: DateTime.now().millisecondsSinceEpoch,
            invoiceId: _invoiceNotifier.value.id,
            itemName: name,
            quantity: q,
            unitPrice: p,
            totalPrice: q * p,
          );
          final updated = List<InvoiceItemEntity>.from(_itemsNotifier.value)
            ..add(newItem);
          _itemsNotifier.value = updated;
          _recalculateTotals();
        },
      ),
    );
  }

  void _onAdjustTax() {
    shared.showResponsiveModal(
      context: context,
      child: shared.SelectTaxDialog(
        appliedTaxes: _appliedTaxesNotifier.value,
        onTaxAdded: (tax) {
          final updated = List<shared.Tax>.from(_appliedTaxesNotifier.value)..add(tax);
          _appliedTaxesNotifier.value = updated;
          _recalculateTotals();
        },
      ),
    );
  }

  void _onAdjustDiscount() {
    shared.showResponsiveModal(
      context: context,
      child: shared.SelectDiscountDialog(
        appliedDiscounts: _appliedDiscountsNotifier.value,
        onDiscountAdded: (discount) {
          final updated =
              List<shared.Discount>.from(_appliedDiscountsNotifier.value)..add(discount);
          _appliedDiscountsNotifier.value = updated;
          _recalculateTotals();
        },
      ),
    );
  }

  void _onAdjustCharges() {
    shared.showResponsiveModal(
      context: context,
      child: shared.SelectChargeDialog(
        appliedOtherCharges: _appliedChargesNotifier.value,
        onChargeAdded: (charge) {
          final updated =
              List<shared.ExtraCharge>.from(_appliedChargesNotifier.value)..add(charge);
          _appliedChargesNotifier.value = updated;
          _recalculateTotals();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            context.tr(
                  shared.LocaleKeys.invoiceEditTitle,
                  track: shared.TrackConstants.invoicePageTrack,
                ) ??
                'EDIT RECEIPT',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: ValueListenableBuilder<bool>(
                valueListenable: _isSavingNotifier,
                builder: (context, isSaving, _) {
                  return ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isSaving
                        ? null
                        : () {
                            _isSavingNotifier.value = true;
                            final updatedInvoice =
                                _invoiceNotifier.value.copyWith(
                              phoneNumber: _phoneController.text.trim(),
                              customerName: _nameController.text.trim(),
                              paymentMethodName: _paymentMethodNotifier.value,
                            );
                            EditInvoiceScreenActions.onSave(
                              context,
                              invoice: updatedInvoice,
                              items: _itemsNotifier.value,
                            );
                          },
                    icon: isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.invoiceActionSave,
                            track: shared.TrackConstants.invoicePageTrack,
                          ) ??
                          'SAVE',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: BlocListener<InvoiceManagementBloc, InvoiceManagementState>(
          listener: (context, state) {
            if (state is InvoiceUpdatedSuccessState) {
              _isSavingNotifier.value = false;
              if (context.canPop()) {
                context.pop(true);
              } else {
                context.go(
                  core.AppRoutePath.invoiceDetailRoute(
                    _invoiceNotifier.value.hashId.isNotEmpty
                        ? _invoiceNotifier.value.hashId
                        : _invoiceNotifier.value.id,
                  ),
                );
              }
            } else if (state is InvoiceManagementLoadedState &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              _isSavingNotifier.value = false;
              shared.SnackBarUtils.showError(
                context,
                message: state.errorMessage!,
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Items editable list card
                ValueListenableBuilder<List<InvoiceItemEntity>>(
                  valueListenable: _itemsNotifier,
                  builder: (context, items, _) {
                    if (items.isEmpty) {
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No items in this invoice. Tap ADD ITEM to add.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemCount: items.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: colorScheme.outlineVariant,
                        ),
                        itemBuilder: (context, idx) {
                          final item = items[idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemName,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.quantity} x ${core.CurrencyFormatter.format(value: item.unitPrice)}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  core.CurrencyFormatter.format(
                                    value: item.totalPrice,
                                  ),
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: colorScheme.primary,
                                  ),
                                  tooltip: 'Edit Item',
                                  onPressed: () => _onEditItem(item, idx),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Add Item buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _onAddItem,
                        icon: const Icon(Icons.restaurant_menu),
                        label: Text(
                          context.tr(
                                shared.LocaleKeys.invoiceAddItem,
                                track: shared.TrackConstants.invoicePageTrack,
                              ) ??
                              'ADD ITEM',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _onAddCustomItem,
                      icon: const Icon(Icons.add),
                      label: const Text('CUSTOM'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Shared Subtotal & Breakdown Summary Card matching Checkout page
                ValueListenableBuilder<shared.BillSummary>(
                  valueListenable: _summaryNotifier,
                  builder: (context, summary, _) {
                    return ValueListenableBuilder<List<InvoiceItemEntity>>(
                      valueListenable: _itemsNotifier,
                      builder: (context, items, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _isRoundOffEnabledNotifier,
                          builder: (context, isRoundOffEnabled, _) {
                            final totalUnits =
                                items.fold(0, (sum, i) => sum + i.quantity);
                            final totalItems = items.length;

                            return shared.SubtotalSummaryCard(
                              subtotal: summary.subtotal,
                              taxDetails: summary.taxDetails,
                              discountDetails: summary.discountDetails,
                              chargeDetails: summary.chargeDetails,
                              grandTotal: summary.grandTotal,
                              totalItemCount: totalItems,
                              totalUnitCount: totalUnits,
                              isRoundOffEnabled: isRoundOffEnabled,
                              roundingAmount: summary.roundingAmount,
                              showClearButton: false,
                              onRoundOffToggled: () {
                                _isRoundOffEnabledNotifier.value =
                                    !_isRoundOffEnabledNotifier.value;
                                _recalculateTotals();
                              },
                              onAddTax: _onAdjustTax,
                              onAddDiscount: _onAdjustDiscount,
                              onAddOtherCharges: _onAdjustCharges,
                              onRemoveTax: (taxDetail) {
                                final updated = _appliedTaxesNotifier.value
                                    .where((t) => t.name != taxDetail.name)
                                    .toList();
                                _appliedTaxesNotifier.value = updated;
                                _recalculateTotals();
                              },
                              onRemoveDiscount: (discountDetail) {
                                final updated = _appliedDiscountsNotifier.value
                                    .where((d) => d.name != discountDetail.name)
                                    .toList();
                                _appliedDiscountsNotifier.value = updated;
                                _recalculateTotals();
                              },
                              onRemoveCharge: (chargeDetail) {
                                final updated = _appliedChargesNotifier.value
                                    .where((c) => c.name != chargeDetail.name)
                                    .toList();
                                _appliedChargesNotifier.value = updated;
                                _recalculateTotals();
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Payment mode dropdown
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.payments_outlined,
                            color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BlocBuilder<InvoiceManagementBloc,
                              InvoiceManagementState>(
                            builder: (context, state) {
                              final availableModes = <String>{
                                'UPI',
                                'Cash',
                                'Card',
                              };
                              if (state is InvoiceManagementLoadedState) {
                                for (final mode in state.paymentModes) {
                                  if (mode.paymentMethodName.isNotEmpty) {
                                    availableModes
                                        .add(mode.paymentMethodName);
                                  }
                                }
                              }

                              return ValueListenableBuilder<String>(
                                valueListenable: _paymentMethodNotifier,
                                builder: (context, selectedMethod, _) {
                                  final currentVal =
                                      availableModes.contains(selectedMethod)
                                          ? selectedMethod
                                          : availableModes.first;

                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: currentVal,
                                      isExpanded: true,
                                      items: availableModes
                                          .map(
                                            (m) => DropdownMenuItem(
                                              value: m,
                                              child: Text(m),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          _paymentMethodNotifier.value = val;
                                        }
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Customer details title
                Center(
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.invoiceCustomerDetailsTitle,
                          track: shared.TrackConstants.invoicePageTrack,
                        ) ??
                        'CUSTOMER DETAILS (OPTIONAL)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Customer detail inputs
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: context.tr(
                                  shared.LocaleKeys.invoiceCustomerPhoneHint,
                                  track: shared.TrackConstants.invoicePageTrack,
                                ) ??
                                'Mobile Number',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: context.tr(
                                  shared.LocaleKeys.invoiceCustomerNameHint,
                                  track: shared.TrackConstants.invoicePageTrack,
                                ) ??
                                'Customer name',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}
