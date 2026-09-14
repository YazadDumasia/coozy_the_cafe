import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static bool enableSecondary = false;

  /// The currently active symbol — secondary when enabled, primary otherwise.
  /// Use this anywhere in the UI that needs to display the active currency symbol
  /// without formatting a value (e.g. column headers, labels).
  static String get activeSymbol =>
      (enableSecondary && secondarySymbol != null && secondarySymbol!.isNotEmpty)
          ? secondarySymbol!
          : primarySymbol;

  /// Notifier that fires whenever the active symbol changes.
  /// Widgets can listen to this to reactively update currency labels.
  static final ValueNotifier<String> activeSymbolNotifier =
      ValueNotifier<String>(primarySymbol);

  /// Initializes currency state from SharedPreferences (or device locale fallback).
  /// Call this in `main()` after initializing Flutter bindings.
  static Future<void> initFromPreferences([SharedPreferences? preferences]) async {
    try {
      final prefs = preferences ?? await SharedPreferences.getInstance();
      String? savedPrimary = prefs.getString('appCurrencySymbol');
      final savedSecondary = prefs.getString('appSecondaryCurrencySymbol');
      final isSecondaryEnabled = prefs.getBool('enableSecondaryCurrency') ?? false;

      if (savedPrimary == null || savedPrimary.isEmpty) {
        // Fallback: detect from device locale
        try {
          final locale = WidgetsBinding.instance.platformDispatcher.locale;
          final countryCode = locale.countryCode;
          if (countryCode != null && countryCode.isNotEmpty) {
            final country = WorldCountry.maybeFromCode(countryCode.toUpperCase());
            final symbol = country?.currencies?.firstOrNull?.symbol;
            if (symbol != null && symbol.isNotEmpty) {
              savedPrimary = symbol;
            }
          }
        } catch (_) {}
      }

      final resolvedPrimary = (savedPrimary != null && savedPrimary.isNotEmpty)
          ? savedPrimary
          : '₹';

      updateSymbols(
        primary: resolvedPrimary,
        secondary: savedSecondary,
        enableSecondary: isSecondaryEnabled,
      );
    } catch (_) {}
  }

  /// Updates the active currency state (typically called from Settings when the
  /// user changes their currency preference).
  static void updateSymbols({
    required String primary,
    String? secondary,
    bool enableSecondary = false,
  }) {
    primarySymbol = primary;
    secondarySymbol = secondary;
    CurrencyFormatter.enableSecondary =
        enableSecondary && (secondary != null && secondary.isNotEmpty);
    activeSymbolNotifier.value = activeSymbol;
  }

  /// Formats a numeric [value] with the appropriate currency symbol.
  ///
  /// **Symbol selection** (driven entirely by SharedPreferences — no flag needed):
  /// - If secondary currency is enabled → formats with the secondary symbol.
  /// - Otherwise → formats with the primary symbol.
  ///
  /// Parameters:
  /// - [value]: The numeric value to format (e.g. `1234.56` or `"1234.56"`).
  /// - [currencyCode]: ISO 4217 code (e.g. `'USD'`). Overrides automatic symbol selection.
  /// - [symbol]: Explicit symbol override. Takes priority over everything else.
  /// - [position]: `CurrencySymbolPosition.prefix` (default) or `suffix`.
  /// - [decimalDigits]: Decimal places. Defaults to 2 (or 4 for values < 0.01).
  /// - [locale]: Number pattern locale (e.g. `'en_US'`, `'de_DE'`).
  static String format({
    required dynamic value,
    String? currencyCode,
    String? symbol,
    CurrencySymbolPosition position = CurrencySymbolPosition.prefix,
    int? decimalDigits,
    String? locale,
  }) {
    final double numericValue = _parseNumericValue(value);

    // Resolve symbol priority:
    // 1. Explicit [symbol] parameter
    // 2. Symbol derived from [currencyCode]
    // 3. Active symbol from settings (secondary if enabled, primary otherwise)
    String resolvedSymbol;
    if (symbol != null && symbol.isNotEmpty) {
      resolvedSymbol = symbol;
    } else if (currencyCode != null && currencyCode.isNotEmpty) {
      try {
        final fiat = FiatCurrency.maybeFromCode(currencyCode.toUpperCase());
        resolvedSymbol = fiat?.symbol?.isNotEmpty == true
            ? fiat!.symbol!
            : currencyCode.toUpperCase();
      } catch (_) {
        resolvedSymbol = currencyCode.toUpperCase();
      }
    } else {
      // Use secondary symbol when enabled, primary otherwise
      resolvedSymbol = activeSymbol;
    }

    final int decimals =
        decimalDigits ?? (numericValue != 0 && numericValue.abs() < 0.01 ? 4 : 2);

    final NumberFormat numberFormatter = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: decimals,
    );

    final String formattedNumber = numberFormatter.format(numericValue);

    return switch (position) {
      CurrencySymbolPosition.prefix => '$resolvedSymbol $formattedNumber',
      CurrencySymbolPosition.suffix => '$formattedNumber $resolvedSymbol',
    };
  }

  static double _parseNumericValue(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    return 0.0;
  }
}
