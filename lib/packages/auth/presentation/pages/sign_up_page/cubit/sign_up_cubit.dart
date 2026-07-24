import 'dart:async';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:coozy_the_cafe/packages/auth/domain/services/sign_up_validation_service.dart';
import 'package:coozy_the_cafe/packages/auth/domain/usecases/get_country_code_usecase.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final GetCountryCodeUseCase getCountryCodeUseCase;
  final SignUpValidationService validationService;
  final core.NetworkInfo networkInfo;

  SignUpCubit({
    required this.getCountryCodeUseCase,
    required this.validationService,
    required this.networkInfo,
  }) : super(SignUpInitial()) {
    fetchInitialInfo();
  }

  Future<void> fetchInitialInfo() async {
    final bool isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      emit(SignUpNoInternetState());
      return;
    }

    emit(SignUpLoadingState());
    if (core.PlatformUtils.isMobileApp() == true) {
      try {
        final List<Locale> systemLocales =
            WidgetsBinding.instance.platformDispatcher.locales;
        final String? isoCountryCode = systemLocales.first.countryCode;
        core.PlatformUtils.debugLog(
          SignUpCubit,
          'isoCountryCode:${isoCountryCode!}',
        );
        _phoneNumberIosCodeController.add(
          shared.CountryPickerUtils.getCountryByIsoCode(isoCountryCode),
        );
      } catch (e) {
        core.PlatformUtils.debugLog(
          SignUpCubit,
          'updateCountryIosCode:getIsMobileApp:Error:${e.toString()}',
        );
        final shared.Country data =
            shared.CountryPickerUtils.getCountryByIso3Code('IND');
        _phoneNumberIosCodeController.add(data);
      }
    } else {
      await _getCountryFromIp();
    }

    emit(SignUpLoadedState());
  }

  // define controllers
  final BehaviorSubject<String> _firstNameController =
      BehaviorSubject<String>();
  final BehaviorSubject<String> _lastNameController = BehaviorSubject<String>();
  final BehaviorSubject<String> _userNameController = BehaviorSubject<String>();
  final BehaviorSubject<bool?> _isUserNameAvailable = BehaviorSubject<bool?>();
  final BehaviorSubject<String> _emailController = BehaviorSubject<String>();
  final BehaviorSubject<shared.Country?> _phoneNumberIosCodeController =
      BehaviorSubject<shared.Country?>();
  final BehaviorSubject<String> _phoneNumberController =
      BehaviorSubject<String>();
  final BehaviorSubject<String> _genderController = BehaviorSubject<String>();
  final BehaviorSubject<String> _dobController = BehaviorSubject<String>();

  final BehaviorSubject<String> _passwordController = BehaviorSubject<String>();
  final BehaviorSubject<bool> _passwordObscureTextController =
      BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<String> _confirmPasswordController =
      BehaviorSubject<String>();
  final BehaviorSubject<bool> _confirmPasswordObscureTextController =
      BehaviorSubject<bool>.seeded(true);

  final BehaviorSubject<bool> _isPasswordOneNumCase =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _isPasswordOneUpperCase =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _isPasswordOneLowerCase =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _isPasswordOneSpecialChar =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _isPasswordSizeRequire =
      BehaviorSubject<bool>.seeded(false);

  final BehaviorSubject<bool> _buttonLoading = BehaviorSubject<bool>.seeded(
    false,
  );

  void dispose() {
    updateDob('');
    checkPassword('');
    updatePhoneNumber('');
    updateConfirmPassword('');
    updateGender(' ');
    updatePasswordObscureText(false);
    updateConfirmPasswordObscureText(false);
    updateButtonLoading(false);
  }

  @override
  Future<void> close() {
    _firstNameController.close();
    _lastNameController.close();
    _userNameController.close();
    _isUserNameAvailable.close();
    _emailController.close();
    _phoneNumberIosCodeController.close();
    _phoneNumberController.close();
    _genderController.close();
    _dobController.close();
    _passwordController.close();
    _passwordObscureTextController.close();
    _confirmPasswordController.close();
    _confirmPasswordObscureTextController.close();
    _isPasswordOneNumCase.close();
    _isPasswordOneUpperCase.close();
    _isPasswordOneLowerCase.close();
    _isPasswordOneSpecialChar.close();
    _isPasswordSizeRequire.close();
    _buttonLoading.close();
    return super.close();
  }

  Stream<String> get passwordController => _passwordController.stream;
  Stream<bool> get isPasswordOneNumCase => _isPasswordOneNumCase.stream;
  Stream<bool> get isPasswordOneUpperCase => _isPasswordOneUpperCase.stream;
  Stream<bool> get isPasswordOneLowerCase => _isPasswordOneLowerCase.stream;
  Stream<bool> get isPasswordOneSpecialChar => _isPasswordOneSpecialChar.stream;
  Stream<bool> get isPasswordSizeRequire => _isPasswordSizeRequire.stream;

  Stream<bool> get allPasswordRequirementsMet => Rx.combineLatest5(
    isPasswordSizeRequire,
    isPasswordOneLowerCase,
    isPasswordOneUpperCase,
    isPasswordOneNumCase,
    isPasswordOneSpecialChar,
    (a, b, c, d, e) => a && b && c && d && e,
  );

  Stream<String> get confirmPasswordController =>
      _confirmPasswordController.stream;
  Stream<String> get firstNameController => _firstNameController.stream;
  Stream<String> get lastNameController => _lastNameController.stream;
  Stream<String> get userNameController => _userNameController.stream;
  Stream<bool?> get isUserNameAvailableStream => _isUserNameAvailable.stream;
  Stream<String> get emailController => _emailController.stream;
  ValueStream<shared.Country?> get phoneNumberIosCodeController =>
      _phoneNumberIosCodeController.stream;
  Stream<String> get phoneNumberController => _phoneNumberController.stream;
  ValueStream<String> get genderController => _genderController.stream;
  Stream<String?> get dobController => _dobController.stream;
  Stream<bool> get passwordObscureTextController =>
      _passwordObscureTextController.stream;
  Stream<bool> get confirmPasswordObscureTextController =>
      _confirmPasswordObscureTextController.stream;
  Stream<bool> get buttonLoadingStream => _buttonLoading.stream;

  void updateGender(String gender) {
    if (gender != ' ') {
      _genderController.sink.add(gender);
    } else {
      _genderController.sink.addError('Please select your gender.');
    }
  }

  void updateUserName(String userName) {
    if (userName.isEmpty) {
      _userNameController.addError('Please enter a user name.');
      _isUserNameAvailable.sink.add(null);
    } else {
      _userNameController.sink.add(userName);
      _checkUserNameAvailability(userName);
    }
  }

  void _checkUserNameAvailability(String userName) {
    if (userName.isEmpty) {
      _isUserNameAvailable.sink.add(null);
      return;
    }
    // Simulate checking username availability.
    // Replace with real API validation if available.
    if (userName.length >= 4) {
      _isUserNameAvailable.sink.add(true);
    } else if (userName.isEmpty) {
      _isUserNameAvailable.sink.add(null);
    } else {
      _isUserNameAvailable.sink.add(false);
    }
  }

  Future<void> updateCountryIosCode(shared.Country? country) async {
    if (country == null) {
      if (core.PlatformUtils.isMobileApp() == true) {
        try {
          final List<Locale> systemLocales =
              WidgetsBinding.instance.platformDispatcher.locales;
          final String? isoCountryCode = systemLocales.first.countryCode;
          core.PlatformUtils.debugLog(
            SignUpCubit,
            'isoCountryCode:${isoCountryCode!}',
          );
          _phoneNumberIosCodeController.add(
            shared.CountryPickerUtils.getCountryByIsoCode(isoCountryCode),
          );
        } catch (e) {
          core.PlatformUtils.debugLog(
            SignUpCubit,
            'updateCountryIosCode:getIsMobileApp:Error:${e.toString()}',
          );
          final shared.Country data =
              shared.CountryPickerUtils.getCountryByIso3Code('IND');
          _phoneNumberIosCodeController.add(data);
        }
      } else {
        await _getCountryFromIp();
      }
    } else {
      _phoneNumberIosCodeController.sink.add(country);
    }
  }

  void updateDob(String pick) {
    _dobController.sink.add(pick);
  }

  void updatePasswordObscureText(bool data) {
    _passwordObscureTextController.sink.add(!data);
  }

  void updateConfirmPasswordObscureText(bool data) {
    _confirmPasswordObscureTextController.sink.add(!data);
  }

  void updatePassword(String password) {
    if (validationService.validatePasswordFull(password)) {
      _passwordController.sink.add(password);
    } else {
      _passwordController.sink.addError('Please fill password properly.');
    }
  }

  void checkPassword(String password) {
    if (password.isEmpty) {
      _passwordController.addError('Please enter a valid email');
      _isPasswordOneLowerCase.sink.add(false);
      _isPasswordOneUpperCase.sink.add(false);
      _isPasswordOneNumCase.sink.add(false);
      _isPasswordOneSpecialChar.sink.add(false);
      _isPasswordSizeRequire.sink.add(false);
    } else {
      _isPasswordOneLowerCase.sink.add(
        validationService.hasLowerCase(password),
      );
      _isPasswordOneUpperCase.sink.add(
        validationService.hasUpperCase(password),
      );
      _isPasswordOneNumCase.sink.add(validationService.hasNumeric(password));
      _isPasswordOneSpecialChar.sink.add(
        validationService.hasSpecialChar(password),
      );
      _isPasswordSizeRequire.sink.add(validationService.hasMinLength(password));
    }
  }

  Future<void> updateConfirmPassword(String? confirmPassword) async {
    if (confirmPassword != null && confirmPassword.isNotEmpty) {
      String password = '';
      try {
        password = _passwordController.valueOrNull ?? '';
      } catch (e) {
        password = '';
      }
      if (validationService.validateConfirmPassword(
        password,
        confirmPassword,
      )) {
        _confirmPasswordController.sink.add(confirmPassword);
      } else {
        _confirmPasswordController.sink.addError('Password does not match.');
      }
    } else {
      _confirmPasswordController.sink.addError(
        'Please fill password properly.',
      );
    }
  }

  void updateButtonLoading(bool? isloading) {
    _buttonLoading.sink.add(isloading ?? false);
  }

  void updatePhoneNumber(String phNumber) {
    if (phNumber.isEmpty) {
      _phoneNumberController.addError('Please enter a valid phone number.');
    } else {
      _phoneNumberController.sink.add(phNumber);
    }
  }

  Future<void> _getCountryFromIp() async {
    try {
      final countryCode = await getCountryCodeUseCase();
      if (countryCode != null && countryCode.isNotEmpty) {
        final shared.Country data =
            shared.CountryPickerUtils.getCountryByIsoCode(countryCode);
        _phoneNumberIosCodeController.sink.add(data);
      } else {
        final shared.Country data =
            shared.CountryPickerUtils.getCountryByIsoCode('IND');
        _phoneNumberIosCodeController.sink.add(data);
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        SignUpCubit,
        'Failed to get IP country fallback to IND: $e',
      );
      final shared.Country data = shared.CountryPickerUtils.getCountryByIsoCode(
        'IND',
      );
      _phoneNumberIosCodeController.sink.add(data);
    }
  }

  Future<void> submitSignUp({
    required Map<String, dynamic> body,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    updateButtonLoading(true);
    try {
      // Simulate API call/delay
      await Future.delayed(const Duration(seconds: 2));
      updateButtonLoading(false);
      onSuccess?.call();
    } catch (e) {
      updateButtonLoading(false);
      onError?.call(e.toString());
    }
  }
}
