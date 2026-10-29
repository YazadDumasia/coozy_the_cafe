import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/business_profile_local_data_source.dart';
import 'data/repositories/business_profile_repository_impl.dart';
import 'domain/repositories/business_profile_repository.dart';
import 'domain/usecases/get_business_profile_usecase.dart';
import 'domain/usecases/save_business_profile_usecase.dart';
import 'presentation/pages/business_profile/cubit/business_profile_cubit.dart';

void registerBusinessProfileDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<BusinessProfileLocalDataSource>(
    () => BusinessProfileLocalDataSourceImpl(
      sharedPreferences: sl<SharedPreferences>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<BusinessProfileRepository>(
    () => BusinessProfileRepositoryImpl(
      localDataSource: sl<BusinessProfileLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetBusinessProfileUseCase>(
    () => GetBusinessProfileUseCase(
      repository: sl<BusinessProfileRepository>(),
    ),
  );
  sl.registerLazySingleton<SaveBusinessProfileUseCase>(
    () => SaveBusinessProfileUseCase(
      repository: sl<BusinessProfileRepository>(),
    ),
  );

  // Cubit
  sl.registerFactory<BusinessProfileCubit>(
    () => BusinessProfileCubit(
      getBusinessProfileUseCase: sl<GetBusinessProfileUseCase>(),
      saveBusinessProfileUseCase: sl<SaveBusinessProfileUseCase>(),
    ),
  );
}
