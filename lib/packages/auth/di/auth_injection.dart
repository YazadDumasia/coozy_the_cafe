import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../core/coozy_core.dart' as core;
import '../../database/coozy_database.dart' as db;
import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/ip_location_remote_data_source.dart';
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
import '../presentation/pages/login_page/cubit/login_screen_cubit.dart';
import '../presentation/pages/login_via_phone_number_page/cubit/login_with_phone_cubit.dart';
import '../presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';

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
  // Data Sources
  if (!sl.isRegistered<AuthLocalDataSource>()) {
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(),
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
}
