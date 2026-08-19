import 'dart:ui';

import 'package:coozy_the_cafe/packages/auth/domain/repositories/ip_location_repository.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rxdart/rxdart.dart';

part 'login_with_phone_state.dart';

class LoginWithPhoneCubit extends Cubit<LoginWithPhoneState> {
  final IpLocationRepository ipLocationRepository;

  LoginWithPhoneCubit({IpLocationRepository? ipLocationRepository})
    : ipLocationRepository =
          ipLocationRepository ?? core.sl<IpLocationRepository>(),
      super(LoginWithPhoneInitial()) {
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
        await _getContryCodeviaPublicIp();
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

  ValueStream<String> get phoneNumberController =>
      _phoneNumberController.stream;

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
        context.tr('common_common_phoneNumber_validator_error_msg') ??
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
        await _getContryCodeviaPublicIp();
      }
    } else {
      _phoneNumberIosCodeController.add(country);
    }
  }

  Future<void> _getContryCodeviaPublicIp() async {
    try {
      final String? countryCode = await ipLocationRepository
          .getCountryIsoCode3FromIp();
      core.PlatformUtils.debugLog(
        LoginWithPhoneCubit,
        ':getPublicIp:countryCode:$countryCode',
      );
      if (countryCode != null && countryCode.isNotEmpty) {
        final Country data = CountryPickerUtils.getCountryByIso3Code(
          countryCode,
        );
        _phoneNumberIosCodeController.sink.add(data);
        return;
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        LoginWithPhoneCubit,
        ':getPublicIp:Error:${e.toString()}',
      );
    }

    final Country data = CountryPickerUtils.getCountryByIso3Code('IND');
    _phoneNumberIosCodeController.sink.add(data);
  }

  @override
  Future<void> close() {
    _phoneNumberIosCodeController.close();
    _buttonLoading.close();
    return super.close();
  }
}
