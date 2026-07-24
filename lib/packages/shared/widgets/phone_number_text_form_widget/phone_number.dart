import '../country_pickers/countries.dart';
import '../country_pickers/country.dart';

class NumberTooLongException implements Exception {}

class NumberTooShortException implements Exception {}

class InvalidCharactersException implements Exception {}

class PhoneNumber {
  PhoneNumber({
    required this.countryISOCode,
    required this.countryCode,
    required this.number,
  });

  factory PhoneNumber.fromCompleteNumber({required String completeNumber}) {
    if (completeNumber == '') {
      return PhoneNumber(countryISOCode: '', countryCode: '', number: '');
    }

    try {
      final Country country = getCountry(completeNumber);
      String number;
      if (completeNumber.startsWith('+')) {
        number = completeNumber.substring(
          1 + country.phoneCode.length + country.regionCode.length,
        );
      } else {
        number = completeNumber.substring(
          country.phoneCode.length + country.regionCode.length,
        );
      }
      return PhoneNumber(
        countryISOCode: country.phoneCode,
        countryCode: country.phoneCode + country.regionCode,
        number: number,
      );
    } on InvalidCharactersException {
      rethrow;
      // ignore: unused_catch_clause
    } on Exception catch (e) {
      return PhoneNumber(countryISOCode: '', countryCode: '', number: '');
    }
  }
  String countryISOCode;
  String countryCode;
  String number;

  bool isValidNumber() {
    final Country country = getCountry(completeNumber);
    if (number.length < country.minLength) {
      throw NumberTooShortException();
    }

    if (number.length > country.maxLength) {
      throw NumberTooLongException();
    }
    return true;
  }

  String get completeNumber {
    return countryCode + number;
  }

  static Country getCountry(String phoneNumber) {
    if (phoneNumber == '') {
      throw NumberTooShortException();
    }

    final RegExp validPhoneNumber = RegExp(r'^[+0-9\-\s]*[0-9]*$');

    if (!validPhoneNumber.hasMatch(phoneNumber)) {
      throw InvalidCharactersException();
    }

    if (phoneNumber.startsWith('+')) {
      return countryList.firstWhere(
        (country) => phoneNumber
            .substring(1)
            .startsWith(country.phoneCode + country.regionCode),
      );
    }
    return countryList.firstWhere(
      (country) =>
          phoneNumber.startsWith(country.phoneCode + country.regionCode),
    );
  }

  @override
  String toString() =>
      'PhoneNumber(countryISOCode: $countryISOCode, countryCode: $countryCode, number: $number)';
}
