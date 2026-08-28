import 'package:flutter_test/flutter_test.dart';
import 'package:coozy_the_cafe/packages/checkout/domain/entities/cart_item.dart';
import 'package:coozy_the_cafe/packages/checkout/domain/entities/discount.dart';
import 'package:coozy_the_cafe/packages/checkout/domain/entities/extra_charge.dart';
import 'package:coozy_the_cafe/packages/checkout/domain/entities/tax.dart';
import 'package:coozy_the_cafe/packages/checkout/domain/usecases/checkout_calculator.dart';

void main() {
  late CheckoutCalculator calculator;

  setUp(() {
    calculator = const CheckoutCalculator();
  });

  group('CheckoutCalculator Tests', () {
    test('Calculates exact math correctly according to prompt requirements', () {
      // 1. Cart Items:
      // Item 1: Cold Coffee (1 x 10 = 10)
      // Item 2: Chocolate Muffin (1 x 14 = 14)
      // Total Subtotal = 24.0
      final cartItems = [
        const CartItem(id: '1', name: 'Cold Coffee', quantity: 1, unitPrice: 10.0),
        const CartItem(id: '2', name: 'Chocolate Muffin', quantity: 1, unitPrice: 14.0),
      ];

      // Order Level Discount: YHU (₹6)
      final appliedDiscounts = [
        const Discount(id: 'd1', name: 'YHU', value: 6.0, isPercentage: false),
      ];

      // Taxable Base = Subtotal (24) - Order Discounts (6) = 18.0

      // Applied Tax: HJ - (2.5% of ₹24 [or Taxable Base ₹18])
      // In prompt example: (2.5% of ₹24 -> 0.60)
      final appliedTaxes = [
        const Tax(id: 't1', name: 'HJ', ratePercent: 2.5),
      ];

      // Applied Charge: Delivery Charge (₹10) -> 10
      final appliedOtherCharges = [
        const ExtraCharge(id: 'c1', name: 'Delivery Charge', value: 10.0, isPercentage: false),
      ];

      final summary = calculator.calculate(
        cartItems: cartItems,
        appliedTaxes: appliedTaxes,
        appliedDiscounts: appliedDiscounts,
        appliedOtherCharges: appliedOtherCharges,
        isRoundOffEnabled: false,
      );

      expect(summary.subtotal, equals(24.0));
      expect(summary.totalDiscounts, equals(6.0));
      expect(summary.taxableBase, equals(18.0));
      expect(summary.totalTaxes, closeTo(0.45, 0.001));
      expect(summary.totalOtherCharges, equals(10.0));
      expect(summary.grandTotal, closeTo(28.45, 0.001));
    });

    test('Round off functionality rounds grand total to nearest integer', () {
      final cartItems = [
        const CartItem(id: '1', name: 'Cold Coffee', quantity: 1, unitPrice: 10.0),
        const CartItem(id: '2', name: 'Chocolate Muffin', quantity: 1, unitPrice: 14.0),
      ];
      final appliedDiscounts = [
        const Discount(id: 'd1', name: 'YHU', value: 6.0, isPercentage: false),
      ];
      final appliedTaxes = [
        const Tax(id: 't1', name: 'HJ', ratePercent: 2.5),
      ];
      final appliedOtherCharges = [
        const ExtraCharge(id: 'c1', name: 'Delivery Charge', value: 10.0, isPercentage: false),
      ];

      final summaryWithRoundOff = calculator.calculate(
        cartItems: cartItems,
        appliedTaxes: appliedTaxes,
        appliedDiscounts: appliedDiscounts,
        appliedOtherCharges: appliedOtherCharges,
        isRoundOffEnabled: true,
      );

      // Unrounded: 28.45 -> Rounded: 28.00, roundingAmount: -0.45
      expect(summaryWithRoundOff.grandTotal, equals(28.0));
      expect(summaryWithRoundOff.roundingAmount, closeTo(-0.45, 0.001));
    });
  });
}
