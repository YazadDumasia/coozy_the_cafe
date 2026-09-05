import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/database/coozy_database.dart' as db;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../../domain/entities/customer_details.dart';
import '../../../utils/responsive_modal.dart';
import 'add_payment_method_dialog.dart';
import 'card_or_other_payment_view.dart';
import 'cash_payment_view.dart';
import 'payment_settings_modal.dart';
import 'payment_success_view.dart';

enum _PaymentStep { details, cash, other, success }

class PaymentSheetModal extends StatefulWidget {
  const PaymentSheetModal({super.key});

  @override
  State<PaymentSheetModal> createState() => _PaymentSheetModalState();
}

class _PaymentSheetModalState extends State<PaymentSheetModal> {
  late final TextEditingController _mobileController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  late final FocusNode _mobileFocusNode;
  late final FocusNode _nameFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _addressFocusNode;

  bool _isExpanderOpen = false;
  _PaymentStep _activeStep = _PaymentStep.details;
  List<db.Customer> _customerSuggestions = [];

  @override
  void initState() {
    super.initState();
    final initialCustomer = context.read<CheckoutBloc>().state.customerDetails;
    _mobileController = TextEditingController(
      text: initialCustomer.mobileNumber,
    );
    _nameController = TextEditingController(text: initialCustomer.name);
    _emailController = TextEditingController(text: initialCustomer.email);
    _addressController = TextEditingController(text: initialCustomer.address);

    _mobileFocusNode = FocusNode();
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _addressFocusNode = FocusNode();

    _loadCustomerSuggestions();
  }

  Future<void> _loadCustomerSuggestions() async {
    try {
      final customersDao = core.sl<db.CustomersDao>();
      final list = await customersDao.searchCustomers(limit: 100);
      if (list != null && mounted) {
        setState(() {
          _customerSuggestions = list;
        });
      }
    } catch (_) {}
  }

  Iterable<db.Customer> _searchCustomerSuggestions(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const Iterable<db.Customer>.empty();
    return _customerSuggestions.where((db.Customer customer) {
      final name = (customer.name ?? '').toLowerCase();
      final phone = (customer.phoneNumber ?? '').toLowerCase();
      return name.contains(q) || phone.contains(q);
    });
  }

  void _selectCustomer(db.Customer selection) {
    if (selection.phoneNumber != null && selection.phoneNumber!.isNotEmpty) {
      _mobileController.text = selection.phoneNumber!;
      _mobileController.selection = TextSelection.collapsed(
        offset: _mobileController.text.length,
      );
    }
    if (selection.name != null && selection.name!.isNotEmpty) {
      _nameController.text = selection.name!;
      _nameController.selection = TextSelection.collapsed(
        offset: _nameController.text.length,
      );
    }
    _updateCustomer();
  }

  String _formatCustomerPhone(db.Customer customer) {
    final phone = customer.phoneNumber ?? '';
    final iso = customer.isoCode;
    if (iso != null && iso.isNotEmpty) {
      return '$phone ($iso)';
    }
    return phone;
  }

  Widget _buildCustomerOptionsView(
    BuildContext context,
    AutocompleteOnSelected<db.Customer> onSelected,
    Iterable<db.Customer> options,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final db.Customer option = options.elementAt(index);
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  option.name ?? 'Unknown Customer',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _formatCustomerPhone(option),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                onTap: () => onSelected(option),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openCustomerSearchModal(BuildContext context) {
    showResponsiveModal(
      context: context,
      title: 'Search Customer',
      child: CustomerSearchDialog(
        customers: _customerSuggestions,
        onCustomerSelected: (customer) {
          _selectCustomer(customer);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();

    _mobileFocusNode.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _updateCustomer() {
    context.read<CheckoutBloc>().add(
      CheckoutCustomerDetailsUpdated(
        CustomerDetails(
          mobileNumber: _mobileController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
        ),
      ),
    );
  }

  void _openPaymentSettings(BuildContext context) {
    showResponsiveModal(
      context: context,
      title: 'Payment Settings',
      child: PaymentSettingsModal(
        onOpenAddNew: () {
          showResponsiveModal(
            context: context,
            title: 'Add Payment Mode',
            child: AddPaymentMethodDialog(
              onPaymentMethodAdded: (newMethod) {
                context.read<CheckoutBloc>().add(
                  CheckoutPaymentMethodAdded(newMethod),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final enabledMethods = state.availablePaymentMethods
            .where((m) => m.isEnabled)
            .toList();
        final selectedMethod = state.selectedPaymentMethod;

        if (_activeStep == _PaymentStep.success) {
          return PaymentSuccessView(
            grandTotal: state.summary.grandTotal,
            itemCount: state.totalItemCount,
            receiptId: state.orderId != null
                ? 'EN-${state.orderId}'
                : 'EN-11196',
            onGetReceipt: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              final invoiceId = state.orderId ?? 1;
              context.push(
                core.AppRoutePath.invoiceDetailRoute(
                  invoiceId,
                  fromCheckout: true,
                ),
              );
            },
            onNewSale: () {
              context.read<CheckoutBloc>().add(const CheckoutCleared());
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              context.go(core.AppRoutePath.homeRoute);
            },
          );
        }

        if (_activeStep == _PaymentStep.cash) {
          return CashPaymentView(
            grandTotal: state.summary.grandTotal,
            onBack: () {
              setState(() {
                _activeStep = _PaymentStep.details;
              });
            },
            onPaymentConfirmed:
                ({required cashReceived, required changeAmount, note}) {
                  context.read<CheckoutBloc>().add(
                    CheckoutPaymentConfirmed(
                      note: note,
                      cashReceived: cashReceived,
                      changeAmount: changeAmount,
                    ),
                  );
                  setState(() {
                    _activeStep = _PaymentStep.success;
                  });
                },
          );
        }

        if (_activeStep == _PaymentStep.other && selectedMethod != null) {
          return CardOrOtherPaymentView(
            paymentModeName: selectedMethod.name,
            grandTotal: state.summary.grandTotal,
            onBack: () {
              setState(() {
                _activeStep = _PaymentStep.details;
              });
            },
            onPaymentConfirmed: (note) {
              context.read<CheckoutBloc>().add(
                CheckoutPaymentConfirmed(note: note),
              );
              setState(() {
                _activeStep = _PaymentStep.success;
              });
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                context.tr(
                      shared.LocaleKeys.checkoutCustomerDetailsOptional,
                      track: shared.TrackConstants.checkoutPageTrack,
                    ) ??
                    'CUSTOMER DETAILS (OPTIONAL)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Customer Mobile Number
              RawAutocomplete<db.Customer>(
                textEditingController: _mobileController,
                focusNode: _mobileFocusNode,
                displayStringForOption: (db.Customer option) =>
                    option.phoneNumber ?? '',
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _searchCustomerSuggestions(textEditingValue.text);
                },
                onSelected: _selectCustomer,
                optionsViewBuilder: (context, onSelected, options) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: _buildCustomerOptionsView(
                      context,
                      onSelected,
                      options,
                    ),
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => _updateCustomer(),
                        decoration: InputDecoration(
                          labelText:
                              context.tr(
                                shared.LocaleKeys.commonPhoneNumberLabel,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Mobile Number',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            child: Text(
                              '+91',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _openCustomerSearchModal(context),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                      );
                    },
              ),
              const SizedBox(height: 12),

              // Customer Name
              RawAutocomplete<db.Customer>(
                textEditingController: _nameController,
                focusNode: _nameFocusNode,
                displayStringForOption: (db.Customer option) =>
                    option.name ?? '',
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return _searchCustomerSuggestions(textEditingValue.text);
                },
                onSelected: _selectCustomer,
                optionsViewBuilder: (context, onSelected, options) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: _buildCustomerOptionsView(
                      context,
                      onSelected,
                      options,
                    ),
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (_) => _updateCustomer(),
                        decoration: InputDecoration(
                          labelText:
                              context.tr(
                                shared.LocaleKeys.commonName,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Customer Name',
                          border: const OutlineInputBorder(),
                        ),
                      );
                    },
              ),
              const SizedBox(height: 8),

              // Expander Arrow Toggle
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanderOpen = !_isExpanderOpen;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanderOpen
                            ? 'Hide Additional Details'
                            : 'Add Email & Address',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        _isExpanderOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Fields: Email & Address
              if (_isExpanderOpen) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _updateCustomer(),
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.commonEmailLabel,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Email Address',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  focusNode: _addressFocusNode,
                  maxLines: 2,
                  onChanged: (_) => _updateCustomer(),
                  decoration: const InputDecoration(
                    labelText: 'Customer Address',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Select Payment Mode Header
              Text(
                context.tr(
                      shared.LocaleKeys.checkoutSelectPaymentMode,
                      track: shared.TrackConstants.checkoutPageTrack,
                    ) ??
                    'SELECT PAYMENT MODE',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Responsive 2-column Grid of Payment Modes
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 70,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: enabledMethods.length + 1,
                itemBuilder: (context, index) {
                  // Special "+ Add New" Tile at the end
                  if (index == enabledMethods.length) {
                    return InkWell(
                      onTap: () => _openPaymentSettings(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.checkoutAddNew,
                                    track:
                                        shared.TrackConstants.checkoutPageTrack,
                                  ) ??
                                  '+ Add New',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final method = enabledMethods[index];
                  final isSelected = selectedMethod?.id == method.id;

                  return InkWell(
                    onTap: () {
                      context.read<CheckoutBloc>().add(
                        CheckoutPaymentSelected(method),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            method.icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
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
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Final Confirm Payment Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final method = selectedMethod;
                  if (method == null) return;

                  if (method.name.toLowerCase().contains('cash')) {
                    setState(() {
                      _activeStep = _PaymentStep.cash;
                    });
                  } else {
                    setState(() {
                      _activeStep = _PaymentStep.other;
                    });
                  }
                },
                child: Text(
                  context.tr(
                        shared.LocaleKeys.checkoutConfirmPayment,
                        track: shared.TrackConstants.checkoutPageTrack,
                        params: {
                          'amount': core.CurrencyFormatter.format(
                            value: state.summary.grandTotal,
                          ),
                        },
                      ) ??
                      'CONFIRM PAYMENT (${core.CurrencyFormatter.format(value: state.summary.grandTotal)})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomerSearchDialog extends StatefulWidget {
  final List<db.Customer> customers;
  final ValueChanged<db.Customer> onCustomerSelected;

  const CustomerSearchDialog({
    super.key,
    required this.customers,
    required this.onCustomerSelected,
  });

  @override
  State<CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<CustomerSearchDialog> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late List<db.Customer> _filteredList;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _filteredList = List.from(widget.customers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    final q = query.trim();
    try {
      final customersDao = core.sl<db.CustomersDao>();
      final results = await customersDao.searchCustomers(search: q, limit: 50);
      if (mounted) {
        setState(() {
          _filteredList = results ?? [];
        });
      }
    } catch (_) {
      final qLower = q.toLowerCase();
      if (mounted) {
        setState(() {
          _filteredList = widget.customers.where((c) {
            final name = (c.name ?? '').toLowerCase();
            final phone = (c.phoneNumber ?? '').toLowerCase();
            return name.contains(qLower) || phone.contains(qLower);
          }).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by name or mobile number...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: _filteredList.isEmpty
                ? Center(
                    child: Text(
                      'No customers found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemCount: _filteredList.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final customer = _filteredList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          customer.name ?? 'Unknown Customer',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(customer.phoneNumber ?? 'No Phone'),
                        onTap: () => widget.onCustomerSelected(customer),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
