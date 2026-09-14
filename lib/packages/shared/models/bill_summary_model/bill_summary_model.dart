import 'package:equatable/equatable.dart';
import '../discount_model/discount_model.dart';
import '../extra_charge_model/extra_charge_model.dart';
import '../tax_model/tax_model.dart';

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

class BillSummary extends Equatable {
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

  const BillSummary({
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

  factory BillSummary.empty() => const BillSummary(
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

class BillCalculator {
  const BillCalculator();

  BillSummary calculate({
    required double subtotal,
    required List<Tax> appliedTaxes,
    required List<Discount> appliedDiscounts,
    required List<ExtraCharge> appliedOtherCharges,
    required bool isRoundOffEnabled,
  }) {
    // 1. Order Level Discounts & Taxable Base = Subtotal - Sum(Order Level Discounts)
    double totalDiscounts = 0.0;
    final List<AppliedDiscountDetail> discountDetails = [];

    for (final discount in appliedDiscounts) {
      double amount = 0.0;
      if (discount.isPercentage) {
        amount = subtotal * (discount.value / 100.0);
      } else {
        amount = discount.value;
      }
      totalDiscounts += amount;
      discountDetails.add(
        AppliedDiscountDetail(
          name: discount.name,
          value: discount.value,
          isPercentage: discount.isPercentage,
          calculatedAmount: amount,
        ),
      );
    }

    double taxableBase = subtotal - totalDiscounts;
    if (taxableBase < 0) taxableBase = 0.0;

    // 2. Total Taxes = Sum(Taxable Base × (Tax Rate / 100))
    double totalTaxes = 0.0;
    final List<AppliedTaxDetail> taxDetails = [];

    for (final tax in appliedTaxes) {
      final taxAmount = taxableBase * (tax.ratePercent / 100.0);
      totalTaxes += taxAmount;
      taxDetails.add(
        AppliedTaxDetail(
          name: tax.name,
          ratePercent: tax.ratePercent,
          taxableSubtotal: taxableBase,
          calculatedAmount: taxAmount,
        ),
      );
    }

    // 3. Total Other Fees = Sum(Fixed Charges + (Subtotal × Fee Percentage / 100))
    double totalOtherCharges = 0.0;
    final List<AppliedChargeDetail> chargeDetails = [];

    for (final charge in appliedOtherCharges) {
      double amount = 0.0;
      if (charge.isPercentage) {
        amount = subtotal * (charge.value / 100.0);
      } else {
        amount = charge.value;
      }
      totalOtherCharges += amount;
      chargeDetails.add(
        AppliedChargeDetail(
          name: charge.name,
          value: charge.value,
          isPercentage: charge.isPercentage,
          calculatedAmount: amount,
        ),
      );
    }

    // 4. Grand Total = Taxable Base + Total Taxes + Total Other Fees (± Rounding if enabled)
    final double unroundedGrandTotal = taxableBase + totalTaxes + totalOtherCharges;
    double finalGrandTotal = unroundedGrandTotal;
    double roundingAmount = 0.0;

    if (isRoundOffEnabled) {
      finalGrandTotal = unroundedGrandTotal.roundToDouble();
      roundingAmount = finalGrandTotal - unroundedGrandTotal;
    }

    return BillSummary(
      subtotal: subtotal,
      taxableBase: taxableBase,
      totalTaxes: totalTaxes,
      totalDiscounts: totalDiscounts,
      totalOtherCharges: totalOtherCharges,
      roundingAmount: roundingAmount,
      grandTotal: finalGrandTotal,
      taxDetails: taxDetails,
      discountDetails: discountDetails,
      chargeDetails: chargeDetails,
    );
  }
}
