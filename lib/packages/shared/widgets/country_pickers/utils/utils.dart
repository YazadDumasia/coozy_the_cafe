import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart' as asts;

import '../countries.dart';
import '../country.dart';
import 'package:flutter/widgets.dart';

class CountryPickerUtils {
  static Country getSampleModel() {
    return Country(
      isoCode: 'AF',
      phoneCode: '93',
      name: 'Afghanistan',
      iso3Code: 'AFG',
      minLength: 9,
      maxLength: 9,
    );
  }

  static List<Country>? getALLList() {
    final List<Country> sortedList = countryList;
    sortedList.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return sortedList;
  }

  static Country getCountryByIso3Code(String iso3Code) {
    try {
      return countryList.firstWhere(
        (country) => country.iso3Code.toLowerCase() == iso3Code.toLowerCase(),
      );
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported iso 3 code!',
      );
    }
  }

  static Country getCountryByIsoCode(String isoCode) {
    try {
      return countryList.firstWhere(
        (country) => country.isoCode.toLowerCase() == isoCode.toLowerCase(),
      );
    } catch (error) {
      throw Exception('The initialValue provided is not a supported iso code!');
    }
  }

  static Country getCountryByName(String name) {
    try {
      return countryList.firstWhere(
        (country) => country.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (error) {
      throw Exception('The initialValue provided is not a supported name!');
    }
  }

  static final Map<String, String> _flagPathCache = {
    for (var asset in asts.Assets.images.flags.values)
      asset.path.split('_').last.split('.').first.toLowerCase(): asset.path,
  };

  static String getFlagImageAssetPath(String isoCode) {
    final code = isoCode.toLowerCase();
    return _flagPathCache[code] ?? 'assets/images/flags/flag_$code.png';
  }

  static Widget getDefaultFlagImage(Country country) {
    return Image.asset(
      CountryPickerUtils.getFlagImageAssetPath(country.isoCode),
      height: 20.0,
      width: 30.0,
      fit: BoxFit.fill,
    );
  }

  static Country getCountryByPhoneCode(String phoneCode) {
    try {
      return countryList.firstWhere(
        (country) => country.phoneCode.toLowerCase() == phoneCode.toLowerCase(),
      );
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported phone code!',
      );
    }
  }

  static List<Country>? getAllCountriesByMinLength(int minLength) {
    try {
      return countryList
          .where((country) => country.minLength == minLength)
          .toList();
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported phone code!',
      );
    }
  }

  static List<Country>? getAllCountriesByMaxLength(int maxLength) {
    try {
      return countryList
          .where((country) => country.maxLength == maxLength)
          .toList();
    } catch (error) {
      throw Exception(
        'The initialValue provided is not a supported phone code!',
      );
    }
  }
}
