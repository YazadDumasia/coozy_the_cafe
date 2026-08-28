part of 'checkout_bloc.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

final class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted();
}

final class CheckoutFetchStarted extends CheckoutEvent {
  final String orderId;
  const CheckoutFetchStarted(this.orderId);

  @override
  List<Object?> get props => [orderId];
}


final class CheckoutItemAdded extends CheckoutEvent {
  final CartItem item;
  const CheckoutItemAdded(this.item);

  @override
  List<Object?> get props => [item];
}

final class CheckoutItemUpdated extends CheckoutEvent {
  final CartItem item;
  const CheckoutItemUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

final class CheckoutItemRemoved extends CheckoutEvent {
  final String itemId;
  const CheckoutItemRemoved(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

final class CheckoutTaxAdded extends CheckoutEvent {
  final Tax tax;
  const CheckoutTaxAdded(this.tax);

  @override
  List<Object?> get props => [tax];
}

final class CheckoutTaxRemoved extends CheckoutEvent {
  final String taxId;
  const CheckoutTaxRemoved(this.taxId);

  @override
  List<Object?> get props => [taxId];
}

final class CheckoutDiscountAdded extends CheckoutEvent {
  final Discount discount;
  const CheckoutDiscountAdded(this.discount);

  @override
  List<Object?> get props => [discount];
}

final class CheckoutDiscountRemoved extends CheckoutEvent {
  final String discountId;
  const CheckoutDiscountRemoved(this.discountId);

  @override
  List<Object?> get props => [discountId];
}

final class CheckoutOtherChargeAdded extends CheckoutEvent {
  final ExtraCharge extraCharge;
  const CheckoutOtherChargeAdded(this.extraCharge);

  @override
  List<Object?> get props => [extraCharge];
}

final class CheckoutOtherChargeRemoved extends CheckoutEvent {
  final String chargeId;
  const CheckoutOtherChargeRemoved(this.chargeId);

  @override
  List<Object?> get props => [chargeId];
}

final class CheckoutRoundOffToggled extends CheckoutEvent {
  const CheckoutRoundOffToggled();
}

final class CheckoutCleared extends CheckoutEvent {
  const CheckoutCleared();
}

final class CheckoutCustomerDetailsUpdated extends CheckoutEvent {
  final CustomerDetails customerDetails;
  const CheckoutCustomerDetailsUpdated(this.customerDetails);

  @override
  List<Object?> get props => [customerDetails];
}

final class CheckoutPaymentMethodAdded extends CheckoutEvent {
  final PaymentMethod method;
  const CheckoutPaymentMethodAdded(this.method);

  @override
  List<Object?> get props => [method];
}

final class CheckoutPaymentMethodToggled extends CheckoutEvent {
  final String methodId;
  const CheckoutPaymentMethodToggled(this.methodId);

  @override
  List<Object?> get props => [methodId];
}

final class CheckoutPaymentSelected extends CheckoutEvent {
  final PaymentMethod method;
  const CheckoutPaymentSelected(this.method);

  @override
  List<Object?> get props => [method];
}
