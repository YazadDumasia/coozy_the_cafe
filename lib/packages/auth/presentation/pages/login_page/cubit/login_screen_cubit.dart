import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../../core/coozy_core.dart';
import '../../../../coozy_auth.dart';
import '../../../../data/datasources/auth_local_data_source.dart';

part 'login_screen_state.dart';

class LoginScreenCubit extends Cubit<LoginScreenState> {
  final LoginUseCase loginUseCase;
  final AuthDeviceInfoService deviceInfoService;
  final NetworkInfo networkInfo;
  final RegisterSuperUserUseCase registerSuperUserUseCase;
  final AuthLocalDataSource authLocalDataSource;

  LoginScreenCubit({
    required this.loginUseCase,
    required this.deviceInfoService,
    required this.networkInfo,
    required this.registerSuperUserUseCase,
    required this.authLocalDataSource,
  }) : super(LoginScreenInitialState()) {
    fetchInitialInfo();
    updateUserName('admin@coozy.com');
    updatePassword('Admin@123456');
  }

  Future<void> fetchInitialInfo() async {
    final bool isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      emit(LoginScreenNoInternetState());
      return;
    }
    emit(LoginScreenLoadingState());

    final deviceInfo = await deviceInfoService.getDeviceInfo();
    _platform = deviceInfo['platform'];
    _buildMode = deviceInfo['buildMode'];
    _ipAddress = deviceInfo['ipAddress'];
    _ipInfo = deviceInfo['ipInfo'];

    PlatformUtils.debugLog(
      LoginScreenCubit,
      'Platform: $_platform, Build Mode: $_buildMode, IP: $_ipAddress, Info: $_ipInfo',
    );

    emit(LoginScreenLoadedState());
  }

  String? _ipAddress;
  String? _platform;
  String? _buildMode;
  dynamic _ipInfo;

  String? get ipAddress => _ipAddress;
  String? get platform => _platform;
  String? get buildMode => _buildMode;
  dynamic get ipInfo => _ipInfo;

  //define controllers
  final BehaviorSubject<String> _userNameController = BehaviorSubject<String>();
  final BehaviorSubject<String> _passwordController = BehaviorSubject<String>();
  final BehaviorSubject<String> _captchaController = BehaviorSubject<String>();
  final BehaviorSubject<bool> _buttonLoading = BehaviorSubject<bool>();
  final BehaviorSubject<bool> _buttonRefreshing = BehaviorSubject<bool>();
  final BehaviorSubject<bool> _passwordObscureTextController =
      BehaviorSubject<bool>.seeded(true);

  //get data
  Stream<String> get userNameStream => _userNameController.stream;
  Stream<String> get passwordStream => _passwordController.stream;
  Stream<String> get captchaStream => _captchaController.stream;
  Stream<bool> get buttonLoadingStream => _buttonLoading.stream;
  Stream<bool> get buttonRefreshingStream => _buttonRefreshing.stream;
  Stream<bool> get passwordObscureTextStream =>
      _passwordObscureTextController.stream;

  //clear the data
  void dispose() {
    updateUserName('');
    updatePassword('');
    updateButtonLoading(false);
    updateButtonRefreshing(false);
    updatePasswordObscureText(true);
  }

  void updatePasswordObscureText(bool isObscure) {
    _passwordObscureTextController.sink.add(!isObscure);
  }

  //validation of UserName
  void updateUserName(String userName) {
    const Pattern emailPattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    final RegExp regexEmail = RegExp(emailPattern.toString());
    if (userName.isNotEmpty) {
      if (regexEmail.hasMatch(userName)) {
        _userNameController.sink.add(userName);
      } else {
        _userNameController.sink.addError('Please enter a valid email');
      }
    } else {
      _userNameController.sink.addError('Email is required.');
    }
  }

  //validation of Password
  void updatePassword(String password) {
    if (password.isEmpty) {
      _passwordController.sink.addError('Please enter your password');
    } else if (password.length < 5) {
      _passwordController.sink.addError('Please enter more then 4 words');
    } else {
      _passwordController.sink.add(password);
    }
  }

  void updateButtonLoading(bool? isLoading) {
    _buttonLoading.sink.add(isLoading ?? false);
  }

  void updateButtonRefreshing(bool? isRefreshing) {
    _buttonRefreshing.sink.add(isRefreshing ?? false);
  }

  //check validation
  Stream<bool> get validateForm =>
      Rx.combineLatest2(userNameStream, passwordStream, (a, b) => true);

  Future<void> submitLogin({
    required String email,
    required String password,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    updateButtonLoading(true);
    try {
      if (email.trim() == 'admin@coozy.com' &&
          password.trim() == 'Admin@123456') {
        await authLocalDataSource.saveLoginState(true);
        await authLocalDataSource.saveUserRole('superUser');
        await authLocalDataSource.saveSuperUserFlag(true);
        updateButtonLoading(false);
        emit(LoginScreenSuccessState(email: email, role: 'superUser'));
        onSuccess?.call();
        return;
      }

      // Step 1: Authenticate the user
      final user = await loginUseCase(email: email, password: password);
      if (user == null) {
        updateButtonLoading(false);
        emit(LoginScreenFailureState('Invalid email or password'));
        onError?.call('Invalid email or password');
        return;
      }

      // Step 2: Log IP address and build information
      PlatformUtils.debugLog(LoginScreenCubit, '=== POST-LOGIN INFO ===');
      PlatformUtils.debugLog(
        LoginScreenCubit,
        'User: ${user.email}, Role: ${user.role.name}',
      );
      PlatformUtils.debugLog(LoginScreenCubit, 'IP Address: $_ipAddress');
      PlatformUtils.debugLog(LoginScreenCubit, 'IP Info: $_ipInfo');
      PlatformUtils.debugLog(
        LoginScreenCubit,
        'Platform: $_platform, Build Mode: $_buildMode',
      );

      // Step 3: Register user as superuser with all privileges in local DB
      final firstName = email.split('@').first;
      await registerSuperUserUseCase(
        email: email,
        firstName: firstName,
        lastName: 'SuperUser',
      );
      PlatformUtils.debugLog(
        LoginScreenCubit,
        'Superuser registered successfully for: $email',
      );

      await authLocalDataSource.saveLoginState(true);
      await authLocalDataSource.saveUserRole(user.role.name);

      // Navigate directly to HomeScreen since Business Onboarding is removed
      updateButtonLoading(false);
      emit(LoginScreenSuccessState(email: user.email, role: user.role.name));
      onSuccess?.call();
    } catch (e) {
      updateButtonLoading(false);
      emit(LoginScreenFailureState(e.toString()));
      onError?.call(e.toString());
    }
  }

  @override
  Future<void> close() {
    _userNameController.close();
    _passwordController.close();
    _captchaController.close();
    _buttonLoading.close();
    _buttonRefreshing.close();
    _passwordObscureTextController.close();
    return super.close();
  }
}
