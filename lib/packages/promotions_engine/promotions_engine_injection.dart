import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';

import 'data/datasources/combo_local_datasource.dart';
import 'data/repositories/combo_repository_impl.dart';
import 'domain/repositories/combo_repository.dart';
import 'domain/usecases/combo_usecases.dart';
import 'presentation/bloc/combo_bloc.dart';

void registerPromotionsEngineDependencies(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<ComboLocalDataSource>(
    () => ComboLocalDataSourceImpl(database: sl<CoozyDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<ComboRepository>(
    () => ComboRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCombosUseCase(sl()));
  sl.registerLazySingleton(() => WatchCombosUseCase(sl()));
  sl.registerLazySingleton(() => CreateComboUseCase(sl()));
  sl.registerLazySingleton(() => UpdateComboUseCase(sl()));
  sl.registerLazySingleton(() => DeleteComboUseCase(sl()));
  sl.registerLazySingleton(() => ToggleComboStatusUseCase(sl()));
  sl.registerLazySingleton(() => SearchMenuItemsForComboUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuItemsCountForComboUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => ComboBloc(
      getCombosUseCase: sl(),
      watchCombosUseCase: sl(),
      createComboUseCase: sl(),
      updateComboUseCase: sl(),
      deleteComboUseCase: sl(),
      toggleComboStatusUseCase: sl(),
    ),
  );
}
