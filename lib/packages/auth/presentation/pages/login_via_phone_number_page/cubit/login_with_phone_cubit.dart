import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

part 'login_with_phone_state.dart';

class LoginWithPhoneCubit extends Cubit<LoginWithPhoneState> {
  LoginWithPhoneCubit() : super(LoginWithPhoneInitial()) {
    fetchInitialInfo();
  }

  Future<void> fetchInitialInfo() async {
    emit(LoginWithPhoneLoadingState());

    final InternetStatus connectionStatus =
        await InternetConnection().internetStatus;
    if (connectionStatus == InternetStatus.connected) {
      if (core.PlatformUtils.isMobileApp() == true) {
        try {
          final List<Locale> systemLocales =
              PlatformDispatcher.instance.locales;
          final String? isoCountryCode = systemLocales.first.countryCode;
          core.PlatformUtils.debugLog(
            LoginWithPhoneCubit,
            'isoCountryCode:${isoCountryCode!}',
          );
          _phoneNumberIosCodeController.add(
            CountryPickerUtils.getCountryByIsoCode(isoCountryCode),
          );
          emit(LoginWithPhoneLoadedState());
        } catch (e) {
          core.PlatformUtils.debugLog(
            LoginWithPhoneCubit,
            'updateCountryIosCode:getIsMobileApp:Error:${e.toString()}',
          );
          final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
          _phoneNumberIosCodeController.add(data);
          // await Future.delayed(const Duration(seconds: 3));
          emit(LoginWithPhoneLoadedState());
        }
      } else {
        getPublicIp();
        emit(LoginWithPhoneLoadedState());
      }
    } else {
      emit(LoginWithPhoneNoInternetState());
    }
  }

  final BehaviorSubject<Country?> _phoneNumberIosCodeController =
      BehaviorSubject<Country?>();
  final BehaviorSubject<String> _phoneNumberController =
      BehaviorSubject<String>();
  final BehaviorSubject<bool> _buttonLoading = BehaviorSubject<bool>();

  Stream<bool> get buttonLoadingStream => _buttonLoading.stream;

  ValueStream<String> get phoneNumberController => _phoneNumberController.stream;

  ValueStream<Country?> get phoneNumberIosCodeController =>
      _phoneNumberIosCodeController.stream;

  void dispose(BuildContext context) {
    updateButtonLoading(false);
    updateCountryIosCode(null);
    updatePhoneNumber('', context);
  }

  void updateButtonLoading(bool? isloading) {
    _buttonLoading.sink.add(isloading!);
  }

  void updatePhoneNumber(String phNumber, BuildContext context) {
    if (phNumber.isEmpty) {
      _phoneNumberController.addError(
        context.tr('common_common_phoneNumber_validator_error_msg',
            ) ??
            'Please enter a valid phone number.',
      );
    } else {
      _phoneNumberController.sink.add(phNumber);
    }
  }

  Future<void> updateCountryIosCode(Country? country) async {
    if (country == null) {
      if (core.PlatformUtils.isMobileApp() == true) {
        try {
          final List<Locale> systemLocales =
              PlatformDispatcher.instance.locales;
          final String? isoCountryCode = systemLocales.first.countryCode;
          core.PlatformUtils.debugLog(
            LoginWithPhoneCubit,
            'isoCountryCode:${isoCountryCode!}',
          );
          _phoneNumberIosCodeController.sink.add(
            CountryPickerUtils.getCountryByIsoCode(isoCountryCode),
          );
        } catch (e) {
          core.PlatformUtils.debugLog(
            LoginWithPhoneCubit,
            'updateCountryIosCode:getIsMobileApp:Error:${e.toString()}',
          );
          final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
          _phoneNumberIosCodeController.sink.add(data);
        }
      } else {
        getPublicIp();
      }
    } else {
      _phoneNumberIosCodeController.add(country);
    }
  }

  Future<void> getPublicIp() async {
    final String? ipv4 = await getPublicIp4();
    if (ipv4 != null) {
      final String? countryCode = await getIpInfo(ipv4);
      core.PlatformUtils.debugLog(
        LoginWithPhoneCubit,
        ':getPublicIp:IPV4:country_code:$countryCode',
      );
      if (countryCode != null && countryCode.isNotEmpty) {
        final Country data = CountryPickerUtils.getCountryByIsoCode(
          countryCode,
        );
        _phoneNumberIosCodeController.sink.add(data);
      }
    } else {
      final String? ipv6 = await getPublicIp6();
      if (ipv6 != null) {
        final String? countryCode = await getIpInfo(ipv6);
        core.PlatformUtils.debugLog(
          LoginWithPhoneCubit,
          ':getPublicIp:IPV6:country_code:$countryCode',
        );
        if (countryCode != null && countryCode.isNotEmpty) {
          final Country data = CountryPickerUtils.getCountryByIsoCode(
            countryCode,
          );
          _phoneNumberIosCodeController.sink.add(data);
        }
      } else {
        // print("No Ip Founded");
        final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
        _phoneNumberIosCodeController.sink.add(data);
      }
    }
  }

  Future<String?> getPublicIp4() async {
    String? ipv4;
    try {
      final http.Response responseV4 = await http.get(
        Uri.parse('https://api.ipify.org?format=json'),
      );
      if (responseV4.statusCode == 200) {
        final data = jsonDecode(responseV4.body);
        ipv4 = data['ip'] as String;
        // print('Public IPv4 address: $ipv4');
      }
      // else if (responseV4.statusCode == 429) {
      //   await getPublicIp4();
      // }
      else {
        ipv4 = null;
        // print('Failed to get public IPv4 address');
      }
    } on SocketException {
      await getPublicIp4();
    } catch (e) {
      ipv4 = null;
      // print('Failed to get public IPv4 address');
      // print(e);
    }
    return ipv4;
  }

  Future<String?> getPublicIp6() async {
    String? ipv6;
    try {
      final http.Response responseV6 = await http.get(
        Uri.parse('https://api64.ipify.org/?format=json'),
      );
      if (responseV6.statusCode == 200) {
        final data = jsonDecode(responseV6.body);
        ipv6 = data['ip'] as String;
        // print('Public IPv6 address: $ipv6');
      }
      // else if (responseV6.statusCode == 429) {
      //   await getPublicIp6();
      // }
      else {
        ipv6 = null;
        // print('Failed to get public IPv6 address');
      }
    } on SocketException {
      await getPublicIp6();
    } catch (e) {
      ipv6 = null;
      // print('Failed to get public IPv6 address');
      // print(e);
    }
    return ipv6;
  }

  Future<String?> getIpInfo(String ipAddress) async {
    final String url = 'https://api.incolumitas.com/?q=$ipAddress';

    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // // final country = data['country_name'] as String;
        // final countryCodeIso3 = data['country_code_iso3'] as String;
        // // final region = data['region'] as String;
        // // final city = data['city'] as String;
        // // final latitude = data['latitude'] as double;
        // // final longitude = data['longitude'] as double;
        // // final timezone = data['timezone'] as String;
        // // final isp = data['org'] as String;
        // //
        // // print('Country: $country');
        // // print('Region: $region');
        // // print('City: $city');
        // // print('Latitude: $latitude');
        // // print('Longitude: $longitude');
        // // print('Time zone: $timezone');
        // // print('ISP: $isp');
        // return countryCodeIso3;

        // Extract company information
        final String companyName = data['company']['name'] as String;
        final String companyDomain = data['company']['domain'] as String;

        // Extract location information
        final String locationCountry = data['location']['country'] as String;
        final String locationCity = data['location']['city'] as String;
        final double locationLatitude = data['location']['latitude'] as double;
        final double locationLongitude =
            data['location']['longitude'] as double;
        final String locationTimezone = data['location']['timezone'] as String;
        final String currencyCode = data['location']['currency_code'] as String;
        final String callingCode = data['location']['calling_code'] as String;
        final String countryCode = data['location']['country_code '] as String;

        // Print extracted information
        core.PlatformUtils.debugLog(LoginWithPhoneCubit, 'Company Name: $companyName');
        core.PlatformUtils.debugLog(
          LoginWithPhoneCubit,
          'Company Domain: $companyDomain',
        );
        core.PlatformUtils.debugLog(
          LoginWithPhoneCubit,
          'Location Country: $locationCountry',
        );
        core.PlatformUtils.debugLog(LoginWithPhoneCubit, 'Location City: $locationCity');
        core.PlatformUtils.debugLog(LoginWithPhoneCubit, 'Latitude: $locationLatitude');
        core.PlatformUtils.debugLog(
          LoginWithPhoneCubit,
          'Longitude: $locationLongitude',
        );
        core.PlatformUtils.debugLog(LoginWithPhoneCubit, 'Timezone: $locationTimezone');
        core.PlatformUtils.debugLog(
          LoginWithPhoneCubit,
          'Location currency_code: $currencyCode',
        );
        core.PlatformUtils.debugLog(
          LoginWithPhoneCubit,
          'Location calling_code: $callingCode',
        );
        core.PlatformUtils.debugLog(
          LoginWithPhoneCubit,
          'Location country_code_2_letter: $countryCode',
        );

        return countryCode;
      } else {
        core.PlatformUtils.debugLog(LoginWithPhoneCubit, 'Failed to get IP info');
        return null;
      }
    } on SocketException {
      await getIpInfo(ipAddress);
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<void> close() {
    _phoneNumberIosCodeController.close();
    _buttonLoading.close();
    return super.close();
  }
}
