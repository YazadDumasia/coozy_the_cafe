import 'package:get_it/get_it.dart';
import 'data/datasources/home_remote_data_source.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/usecases/get_home_data_usecase.dart';
import 'presentation/cubit/home_cubit.dart';

void registerHomeDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));

  // Cubits
  sl.registerFactory(() => HomeCubit(getHomeDataUseCase: sl()));
}
