import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyExchangeApiService {
  static const String _primaryCdnUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1';
  static const String _fallbackUrl =
      'https://latest.currency-api.pages.dev/v1';

  static const String _cacheKeyRatesPrefix = 'cache_exchange_rates_';
  static const String _cacheKeyLastUpdatePrefix = 'cache_exchange_last_update_';
  static const String _cacheKeyCurrenciesList = 'cache_exchange_currencies_list';

  /// Fetches available currency list from CDN or fallback, with caching.
  Future<Map<String, String>> fetchCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKeyCurrenciesList);

    try {
      final response = await http
          .get(Uri.parse('$_primaryCdnUrl/currencies.json'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final result = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        await prefs.setString(_cacheKeyCurrenciesList, json.encode(result));
        return result;
      }
    } catch (e) {
      debugPrint('Primary CDN currencies error: $e. Trying fallback...');
    }

    try {
      final response = await http
          .get(Uri.parse('$_fallbackUrl/currencies.json'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final result = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        await prefs.setString(_cacheKeyCurrenciesList, json.encode(result));
        return result;
      }
    } catch (e) {
      debugPrint('Fallback currencies error: $e');
    }

    if (cached != null && cached.isNotEmpty) {
      final decoded = json.decode(cached) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
    }

    return {
      'usd': 'US Dollar',
      'eur': 'Euro',
      'gbp': 'British Pound',
      'inr': 'Indian Rupee',
      'jpy': 'Japanese Yen',
      'aud': 'Australian Dollar',
      'cad': 'Canadian Dollar',
      'chf': 'Swiss Franc',
      'cny': 'Chinese Yuan',
      'aed': 'UAE Dirham',
      'sar': 'Saudi Riyal',
    };
  }

  /// Fetches rates for a given base currency.
  /// If data was updated within 24 hours, uses cache.
  /// Warm data is automatically updated once per day (24 hours expiry).
  Future<({Map<String, double> rates, String date, bool isOffline})> fetchRates(
    String baseCurrency, {
    bool forceRefresh = false,
  }) async {
    final base = baseCurrency.toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    final cacheRatesKey = '$_cacheKeyRatesPrefix$base';
    final cacheUpdateKey = '$_cacheKeyLastUpdatePrefix$base';

    final lastUpdateMillis = prefs.getInt(cacheUpdateKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final is24HoursPassed = (now - lastUpdateMillis) > (24 * 60 * 60 * 1000);

    final cachedRatesJson = prefs.getString(cacheRatesKey);

    if (!forceRefresh && !is24HoursPassed && cachedRatesJson != null) {
      try {
        final decoded = json.decode(cachedRatesJson) as Map<String, dynamic>;
        final ratesMap = <String, double>{};
        decoded['rates']?.forEach((k, v) {
          if (v is num) ratesMap[k.toString()] = v.toDouble();
        });
        final dateStr = decoded['date']?.toString() ?? 'Cached';
        return (rates: ratesMap, date: dateStr, isOffline: true);
      } catch (e) {
        debugPrint('Cache parsing failed: $e');
      }
    }

    // Attempt live network fetch
    for (final baseUrl in [_primaryCdnUrl, _fallbackUrl]) {
      try {
        final url = '$baseUrl/currencies/$base.json';
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body) as Map<String, dynamic>;
          final dateStr = decoded['date']?.toString() ?? DateTime.now().toIso8601String();
          final rawRates = decoded[base] as Map<String, dynamic>? ?? {};

          final ratesMap = <String, double>{};
          rawRates.forEach((k, v) {
            if (v is num) ratesMap[k.toString()] = v.toDouble();
          });

          // Save warm cache with timestamp
          final cachePayload = json.encode({
            'date': dateStr,
            'rates': ratesMap,
          });
          await prefs.setString(cacheRatesKey, cachePayload);
          await prefs.setInt(cacheUpdateKey, now);

          return (rates: ratesMap, date: dateStr, isOffline: false);
        }
      } catch (e) {
        debugPrint('Error fetching rates from $baseUrl: $e');
      }
    }

    // Fallback to offline cached data if available
    if (cachedRatesJson != null) {
      try {
        final decoded = json.decode(cachedRatesJson) as Map<String, dynamic>;
        final ratesMap = <String, double>{};
        decoded['rates']?.forEach((k, v) {
          if (v is num) ratesMap[k.toString()] = v.toDouble();
        });
        final dateStr = decoded['date']?.toString() ?? 'Cached';
        return (rates: ratesMap, date: dateStr, isOffline: true);
      } catch (e) {
        debugPrint('Cache parsing failed in offline fallback: $e');
      }
    }

    throw Exception(
      'Unable to load currency exchange rates. Please check your internet connection.',
    );
  }
}
