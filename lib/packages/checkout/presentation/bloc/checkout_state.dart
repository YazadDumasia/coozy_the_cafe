part of 'checkout_bloc.dart';

class CheckoutState extends Equatable {
  final String? orderId;
  final bool isLoading;
  final String? errorMessage;
  final List<CartItem> cartItems;
  final List<Tax> appliedTaxes;
  final List<Discount> appliedDiscounts;
  final List<ExtraCharge> appliedOtherCharges;
  final List<PaymentMethod> availablePaymentMethods;
  final PaymentMethod? selectedPaymentMethod;
  final CustomerDetails customerDetails;
  final bool isRoundOffEnabled;
  final CheckoutSummary summary;

  const CheckoutState({
    this.orderId,
    this.isLoading = false,
    this.errorMessage,
    required this.cartItems,
    required this.appliedTaxes,
    required this.appliedDiscounts,
    required this.appliedOtherCharges,
    required this.availablePaymentMethods,
    this.selectedPaymentMethod,
    required this.customerDetails,
    required this.isRoundOffEnabled,
    required this.summary,
  });

  factory CheckoutState.initial() {

    final defaultMethods = [
      const PaymentMethod(id: 'cash', name: 'Cash', icon: Icons.payments, isEnabled: true),
      const PaymentMethod(id: 'debit_card', name: 'Debit Card', icon: Icons.credit_card, isEnabled: true),
      const PaymentMethod(id: 'credit_card', name: 'Credit Card', icon: Icons.credit_score, isEnabled: true),
      const PaymentMethod(id: 'credit', name: 'Credit', icon: Icons.account_balance_wallet, isEnabled: true),
      const PaymentMethod(id: 'upi', name: 'UPI', icon: Icons.qr_code, isEnabled: true),

      const PaymentMethod(id: 'bitcoin', name: 'Bitcoin', icon: Icons.currency_bitcoin, isEnabled: true),
    ];

    return CheckoutState(
      cartItems: const [],
      appliedTaxes: const [],
      appliedDiscounts: const [],
      appliedOtherCharges: const [],
      availablePaymentMethods: defaultMethods,
      selectedPaymentMethod: defaultMethods.first,
      customerDetails: const CustomerDetails(),
      isRoundOffEnabled: false,
      summary: CheckoutSummary.empty(),
    );
  }

  int get totalItemCount => cartItems.length;

  int get totalUnitCount {
    int total = 0;
    for (final item in cartItems) {
      total += item.quantity;
    }
    return total;
  }

  CheckoutState copyWith({
    String? orderId,
    bool? isLoading,
    String? errorMessage,
    List<CartItem>? cartItems,
    List<Tax>? appliedTaxes,
    List<Discount>? appliedDiscounts,
    List<ExtraCharge>? appliedOtherCharges,
    List<PaymentMethod>? availablePaymentMethods,
    PaymentMethod? selectedPaymentMethod,
    CustomerDetails? customerDetails,
    bool? isRoundOffEnabled,
    CheckoutSummary? summary,
  }) {
    return CheckoutState(
      orderId: orderId ?? this.orderId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      cartItems: cartItems ?? this.cartItems,
      appliedTaxes: appliedTaxes ?? this.appliedTaxes,
      appliedDiscounts: appliedDiscounts ?? this.appliedDiscounts,
      appliedOtherCharges: appliedOtherCharges ?? this.appliedOtherCharges,
      availablePaymentMethods: availablePaymentMethods ?? this.availablePaymentMethods,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      customerDetails: customerDetails ?? this.customerDetails,
      isRoundOffEnabled: isRoundOffEnabled ?? this.isRoundOffEnabled,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        isLoading,
        errorMessage,
        cartItems,
        appliedTaxes,
        appliedDiscounts,
        appliedOtherCharges,
        availablePaymentMethods,
        selectedPaymentMethod,
        customerDetails,
        isRoundOffEnabled,
        summary,
      ];
}

