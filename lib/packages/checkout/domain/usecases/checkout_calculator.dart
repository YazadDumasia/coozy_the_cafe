import '../entities/cart_item.dart';
import '../entities/checkout_summary.dart';
import '../entities/discount.dart';
import '../entities/extra_charge.dart';
import '../entities/tax.dart';

class CheckoutCalculator {
  const CheckoutCalculator();

  CheckoutSummary calculate({
    required List<CartItem> cartItems,
    required List<Tax> appliedTaxes,
    required List<Discount> appliedDiscounts,
    required List<ExtraCharge> appliedOtherCharges,
    required bool isRoundOffEnabled,
  }) {
    // 1. Subtotal = Sum(Item Selling Price × Quantity - Item Discounts)
    double subtotal = 0.0;
    for (final item in cartItems) {
      subtotal += item.lineTotal;
    }

    // 2. Order Level Discounts & Taxable Base = Subtotal - Sum(Order Level Discounts)
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

    // 3. Total Taxes = Sum(Taxable Base × (Tax Rate / 100))
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

    // 4. Total Other Fees = Sum(Fixed Charges + (Subtotal × Fee Percentage / 100))
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

    // 5. Grand Total = Taxable Base + Total Taxes + Total Other Fees (± Rounding if enabled)
    final double unroundedGrandTotal = taxableBase + totalTaxes + totalOtherCharges;
    double finalGrandTotal = unroundedGrandTotal;
    double roundingAmount = 0.0;

    if (isRoundOffEnabled) {
      finalGrandTotal = unroundedGrandTotal.roundToDouble();
      roundingAmount = finalGrandTotal - unroundedGrandTotal;
    }

    return CheckoutSummary(
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
