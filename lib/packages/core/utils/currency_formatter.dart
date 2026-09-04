import 'package:intl/intl.dart';
import 'package:world_countries/world_countries.dart';

/// Enum to specify currency symbol placement position
enum CurrencySymbolPosition {
  /// Symbol placed at the front (e.g. $1,234.56)
  prefix,

  /// Symbol placed at the back (e.g. 1,234.56 €)
  suffix,
}

class CurrencyFormatter {
  static String primarySymbol = '\$';
  static String? secondarySymbol;
  static bool enableDualDisplay = false;

  /// Updates global active currency symbols (typically loaded from SharedPreferences).
  static void updateSymbols({
    required String primary,
    String? secondary,
    bool enableSecondary = false,
  }) {
    primarySymbol = primary;
    secondarySymbol = secondary;
    enableDualDisplay = enableSecondary && (secondary != null && secondary.isNotEmpty);
  }

  /// Formats a numeric [value] (num, double, int, or String representation of a number)
  /// with money formatting (comma separation for thousands, decimal precision) and currency symbol placement.
  ///
  /// Parameters:
  /// - [value]: The numeric value to format (e.g., `1234567.89` or `"1234567.89"`).
  /// - [currencyCode]: ISO 4217 currency code (e.g., `'USD'`, `'EUR'`, `'INR'`, `'JPY'`).
  /// - [symbol]: Optional custom symbol (e.g. `'$'`, `'€'`, `'₹'`). If omitted, resolves automatically.
  /// - [position]: `CurrencySymbolPosition.prefix` (default) or `CurrencySymbolPosition.suffix`.
  /// - [decimalDigits]: Number of decimal places. If omitted, defaults to 2 (or 4 for very small amounts < 0.01).
  /// - [locale]: Optional locale code for number pattern (e.g. `'en_US'`, `'de_DE'`).
  /// - [withSecondary]: If true and secondary currency is enabled, appends secondary formatted amount e.g. `$ 100.00 (€ 100.00)`.
  /// - [secondaryRate]: Exchange rate ratio for secondary currency conversion if applicable.
  static String format({
    required dynamic value,
    String? currencyCode,
    String? symbol,
    CurrencySymbolPosition position = CurrencySymbolPosition.prefix,
    int? decimalDigits,
    String? locale,
    bool showSecondaryIfEnabled = false,
    double secondaryRate = 1.0,
  }) {
    // Parse numeric value safely
    final double numericValue = _parseNumericValue(value);

    // Resolve Fiat Currency details using world_countries
    FiatCurrency? fiat;
    if (currencyCode != null && currencyCode.isNotEmpty) {
      try {
        fiat = FiatCurrency.maybeFromCode(currencyCode.toUpperCase());
      } catch (_) {
        fiat = null;
      }
    }

    // Resolve symbol:
    // 1. Explicit symbol parameter if provided
    // 2. FiatCurrency symbol from currencyCode if provided
    // 3. Fallback to active primarySymbol
    String resolvedSymbol = symbol ?? fiat?.symbol ?? '';
    if (resolvedSymbol.isEmpty && (currencyCode == null || currencyCode.isEmpty)) {
      resolvedSymbol = primarySymbol;
    } else if (resolvedSymbol.isEmpty && currencyCode != null) {
      resolvedSymbol = currencyCode.toUpperCase();
    }

    // Determine decimal digits
    final int decimals = decimalDigits ??
        (numericValue != 0 && numericValue.abs() < 0.01 ? 4 : 2);

    // Create NumberFormat without embedded symbol first
    final NumberFormat numberFormatter = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimals,
    );

    final String formattedNumber = numberFormatter.format(numericValue);

    String primaryResult;
    switch (position) {
      case CurrencySymbolPosition.prefix:
        primaryResult = '$resolvedSymbol $formattedNumber';
        break;
      case CurrencySymbolPosition.suffix:
        primaryResult = '$formattedNumber $resolvedSymbol';
        break;
    }

    if (showSecondaryIfEnabled && enableDualDisplay && secondarySymbol != null && secondarySymbol!.isNotEmpty) {
      final double secValue = numericValue * secondaryRate;
      final String secFormattedNumber = numberFormatter.format(secValue);
      final String secResult = position == CurrencySymbolPosition.prefix
          ? '$secondarySymbol $secFormattedNumber'
          : '$secFormattedNumber $secondarySymbol';
      return '$primaryResult ($secResult)';
    }

    return primaryResult;
  }

  static double _parseNumericValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    }
    return 0.0;
  }
}
