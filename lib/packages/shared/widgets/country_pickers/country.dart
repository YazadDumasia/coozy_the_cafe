import 'package:intl/intl.dart';

class Country {
  Country({
    required this.isoCode,
    required this.iso3Code,
    required this.phoneCode,
    required this.name,
    required this.minLength,
    required this.maxLength,
    this.currencySymbol = '',
    this.regionCode = '',
  });

  factory Country.fromMap(Map<String, dynamic> map) {
    final iso3Code = map['iso3Code']!;
    final String currencySymbol = _getCurrencySymbolFromCode(iso3Code);

    return Country(
      name: map['name']!,
      isoCode: map['isoCode']!,
      iso3Code: iso3Code,
      currencySymbol: currencySymbol,
      phoneCode: map['phoneCode']!,
      minLength: map['minLength']!,
      maxLength: map['maxLength']!,
      regionCode: map['regionCode'] ?? '',
    );
  }
  final String name;
  final String isoCode;
  final String iso3Code;
  final String currencySymbol;
  final String phoneCode;
  final String regionCode;
  final int minLength;
  final int maxLength;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'isoCode': isoCode,
      'iso3Code': iso3Code,
      'currencySymbol': currencySymbol,
      'phoneCode': phoneCode,
      'regionCode': regionCode,
      'minLength': minLength,
      'maxLength': maxLength,
    }..removeWhere((key, Object? value) => value == null);
  }

  static String _getCurrencySymbolFromCode(String? iso3Code) {
    try {
      final NumberFormat format = NumberFormat.simpleCurrency(name: iso3Code);
      return format.currencySymbol;
    } catch (_) {
      return iso3Code ?? ''; // fallback if symbol can't be resolved
    }
  }

  String get fullCountryCode {
    return phoneCode + regionCode;
  }

  String get displayCC {
    if (regionCode != '') {
      return '$phoneCode $regionCode';
    }
    return phoneCode;
  }
}
