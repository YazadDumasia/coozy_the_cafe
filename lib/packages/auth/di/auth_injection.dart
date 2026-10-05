import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../core/coozy_core.dart' as core;
import '../../database/coozy_database.dart' as db;
import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/ip_location_remote_data_source.dart';
import '../data/services/security_storage_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/ip_location_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/ip_location_repository.dart';
import '../domain/services/sign_up_validation_service.dart';
import '../domain/services/auth_device_info_service.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/get_ip_address_usecase.dart';
import '../domain/usecases/get_current_user_ip_info_usecase.dart';
import '../domain/usecases/check_auth_status_usecase.dart';
import '../domain/usecases/get_country_code_usecase.dart';
import '../domain/usecases/register_superuser_usecase.dart';
import '../domain/usecases/send_password_reset_email_usecase.dart';
import '../domain/usecases/reset_password_usecase.dart';
import '../domain/usecases/change_password_usecase.dart';
import '../presentation/pages/login_page/cubit/login_screen_cubit.dart';
import '../presentation/pages/login_via_phone_number_page/cubit/login_with_phone_cubit.dart';
import '../presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';
import '../presentation/pages/forgot_password_page/cubit/forgot_password_cubit.dart';
import '../presentation/pages/reset_password_page/cubit/reset_password_cubit.dart';
import '../presentation/pages/change_password_page/cubit/change_password_cubit.dart';

void registerAuthDependencies(GetIt sl) {
  // HTTP Client
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton<http.Client>(() => http.Client());
  }

  // NetworkInfo — InternetConnection is created internally by NetworkInfoImpl
  if (!sl.isRegistered<core.NetworkInfo>()) {
    sl.registerLazySingleton<core.NetworkInfo>(() => core.NetworkInfoImpl());
  }

  // Database & DAOs
  if (!sl.isRegistered<db.CoozyDatabase>()) {
    sl.registerLazySingleton<db.CoozyDatabase>(() => db.CoozyDatabase());
  }
  if (!sl.isRegistered<db.UserLoginsDao>()) {
    sl.registerLazySingleton<db.UserLoginsDao>(
      () => sl<db.CoozyDatabase>().userLoginsDao,
    );
  }
  // Security Storage Service (AES + SHA-256 + FlutterSecureStorage)
  if (!sl.isRegistered<SecurityStorageService>()) {
    sl.registerLazySingleton<SecurityStorageService>(
      () => SecurityStorageService(),
    );
  }

  // Data Sources
  if (!sl.isRegistered<AuthLocalDataSource>()) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(securityStorageService: sl()),
    );
  }
  if (!sl.isRegistered<IpLocationRemoteDataSource>()) {
    sl.registerLazySingleton<IpLocationRemoteDataSource>(
      () => IpLocationRemoteDataSourceImpl(client: sl()),
    );
  }

  // Repositories
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(localDataSource: sl(), userLoginsDao: sl()),
    );
  }
  if (!sl.isRegistered<IpLocationRepository>()) {
    sl.registerLazySingleton<IpLocationRepository>(
      () => IpLocationRepositoryImpl(remoteDataSource: sl()),
    );
  }

  // Services
  if (!sl.isRegistered<SignUpValidationService>()) {
    sl.registerLazySingleton<SignUpValidationService>(
      () => SignUpValidationService(),
    );
  }

  if (!sl.isRegistered<AuthDeviceInfoService>()) {
    sl.registerLazySingleton<AuthDeviceInfoService>(
      () => AuthDeviceInfoService(
        getIpAddressUseCase: sl(),
        getCurrentUserIpInfoUseCase: sl(),
      ),
    );
  }

  // Use Cases
  if (!sl.isRegistered<LoginUseCase>()) {
    sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  }
  if (!sl.isRegistered<CheckAuthStatusUseCase>()) {
    sl.registerLazySingleton<CheckAuthStatusUseCase>(
      () => CheckAuthStatusUseCase(sl()),
    );
  }
  if (!sl.isRegistered<GetCountryCodeUseCase>()) {
    sl.registerLazySingleton<GetCountryCodeUseCase>(
      () => GetCountryCodeUseCase(sl()),
    );
  }
  if (!sl.isRegistered<GetIpAddressUseCase>()) {
    sl.registerLazySingleton<GetIpAddressUseCase>(
      () => GetIpAddressUseCase(sl()),
    );
  }
  if (!sl.isRegistered<GetCurrentUserIpInfoUseCase>()) {
    sl.registerLazySingleton<GetCurrentUserIpInfoUseCase>(
      () => GetCurrentUserIpInfoUseCase(sl()),
    );
  }
  if (!sl.isRegistered<RegisterSuperUserUseCase>()) {
    sl.registerLazySingleton<RegisterSuperUserUseCase>(
      () => RegisterSuperUserUseCase(sl()),
    );
  }
  if (!sl.isRegistered<SendPasswordResetEmailUseCase>()) {
    sl.registerLazySingleton<SendPasswordResetEmailUseCase>(
      () => SendPasswordResetEmailUseCase(sl()),
    );
  }
  if (!sl.isRegistered<ResetPasswordUseCase>()) {
    sl.registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(sl()),
    );
  }
  if (!sl.isRegistered<ChangePasswordUseCase>()) {
    sl.registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(sl()),
    );
  }
  // Cubits
  if (!sl.isRegistered<LoginScreenCubit>()) {
    sl.registerFactory(
      () => LoginScreenCubit(
        loginUseCase: sl(),
        deviceInfoService: sl(),
        networkInfo: sl(),
        registerSuperUserUseCase: sl(),
        authLocalDataSource: sl(),
      ),
    );
  }
  if (!sl.isRegistered<SignUpCubit>()) {
    sl.registerFactory<SignUpCubit>(
      () => SignUpCubit(
        getCountryCodeUseCase: sl(),
        validationService: sl(),
        networkInfo: sl(),
      ),
    );
  }

  if (!sl.isRegistered<LoginWithPhoneCubit>()) {
    sl.registerFactory<LoginWithPhoneCubit>(
      () => LoginWithPhoneCubit(ipLocationRepository: sl()),
    );
  }

  if (!sl.isRegistered<ForgotPasswordCubit>()) {
    sl.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(sendPasswordResetEmailUseCase: sl()),
    );
  }

  if (!sl.isRegistered<ResetPasswordCubit>()) {
    sl.registerFactory<ResetPasswordCubit>(
      () => ResetPasswordCubit(resetPasswordUseCase: sl()),
    );
  }

  if (!sl.isRegistered<ChangePasswordCubit>()) {
    sl.registerFactory<ChangePasswordCubit>(
      () => ChangePasswordCubit(changePasswordUseCase: sl()),
    );
  }
}
