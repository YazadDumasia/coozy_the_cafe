import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'data/datasources/inventory_local_data_source.dart';
import 'data/repositories/inventory_repository_impl.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/usecases/inventory_usecases.dart';
import 'presentation/bloc/inventory_bloc.dart';
import 'presentation/bloc/inventory_picker_bloc.dart';

void registerInventoryDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSourceImpl(database: sl<CoozyDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetInventoryItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetInventoryItemsPagedUseCase(sl()));
  sl.registerLazySingleton(() => AddInventoryItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInventoryItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInventoryItemUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => InventoryBloc(
      getInventoryItemsUseCase: sl(),
      addInventoryItemUseCase: sl(),
      updateInventoryItemUseCase: sl(),
      deleteInventoryItemUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => InventoryPickerBloc(getInventoryItemsPagedUseCase: sl()),
  );
}
