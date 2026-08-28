import 'package:equatable/equatable.dart';

class AppliedTaxDetail extends Equatable {
  final String name;
  final double ratePercent;
  final double taxableSubtotal;
  final double calculatedAmount;

  const AppliedTaxDetail({
    required this.name,
    required this.ratePercent,
    required this.taxableSubtotal,
    required this.calculatedAmount,
  });

  @override
  List<Object?> get props => [name, ratePercent, taxableSubtotal, calculatedAmount];
}

class AppliedDiscountDetail extends Equatable {
  final String name;
  final double value;
  final bool isPercentage;
  final double calculatedAmount;

  const AppliedDiscountDetail({
    required this.name,
    required this.value,
    required this.isPercentage,
    required this.calculatedAmount,
  });

  @override
  List<Object?> get props => [name, value, isPercentage, calculatedAmount];
}

class AppliedChargeDetail extends Equatable {
  final String name;
  final double value;
  final bool isPercentage;
  final double calculatedAmount;

  const AppliedChargeDetail({
    required this.name,
    required this.value,
    required this.isPercentage,
    required this.calculatedAmount,
  });

  @override
  List<Object?> get props => [name, value, isPercentage, calculatedAmount];
}

class CheckoutSummary extends Equatable {
  final double subtotal;
  final double taxableBase;
  final double totalTaxes;
  final double totalDiscounts;
  final double totalOtherCharges;
  final double roundingAmount;
  final double grandTotal;

  final List<AppliedTaxDetail> taxDetails;
  final List<AppliedDiscountDetail> discountDetails;
  final List<AppliedChargeDetail> chargeDetails;

  const CheckoutSummary({
    required this.subtotal,
    required this.taxableBase,
    required this.totalTaxes,
    required this.totalDiscounts,
    required this.totalOtherCharges,
    required this.roundingAmount,
    required this.grandTotal,
    required this.taxDetails,
    required this.discountDetails,
    required this.chargeDetails,
  });

  factory CheckoutSummary.empty() => const CheckoutSummary(
        subtotal: 0.0,
        taxableBase: 0.0,
        totalTaxes: 0.0,
        totalDiscounts: 0.0,
        totalOtherCharges: 0.0,
        roundingAmount: 0.0,
        grandTotal: 0.0,
        taxDetails: [],
        discountDetails: [],
        chargeDetails: [],
      );

  @override
  List<Object?> get props => [
        subtotal,
        taxableBase,
        totalTaxes,
        totalDiscounts,
        totalOtherCharges,
        roundingAmount,
        grandTotal,
        taxDetails,
        discountDetails,
        chargeDetails,
      ];
}
