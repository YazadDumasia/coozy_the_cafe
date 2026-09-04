import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter tests', () {
    test('Formats amount with prefix symbol correctly', () {
      final result = CurrencyFormatter.format(
        value: 1234567.89,
        currencyCode: 'USD',
        position: CurrencySymbolPosition.prefix,
      );
      expect(result, '\$ 1,234,567.89');
    });

    test('Formats amount with suffix symbol correctly', () {
      final result = CurrencyFormatter.format(
        value: 1234567.89,
        currencyCode: 'EUR',
        position: CurrencySymbolPosition.suffix,
      );
      expect(result, '1,234,567.89 €');
    });

    test('Formats INR currency with prefix symbol correctly', () {
      final result = CurrencyFormatter.format(
        value: 98765.43,
        currencyCode: 'INR',
        position: CurrencySymbolPosition.prefix,
      );
      expect(result, '₹ 98,765.43');
    });

    test('Handles String inputs with existing commas', () {
      final result = CurrencyFormatter.format(
        value: '1,234.50',
        currencyCode: 'GBP',
        position: CurrencySymbolPosition.prefix,
      );
      expect(result, '£ 1,234.50');
    });
  });
}
