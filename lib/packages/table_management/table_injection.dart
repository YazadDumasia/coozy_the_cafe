import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

import 'data/datasources/table_local_data_source.dart';
import 'data/datasources/table_picker_dao.dart';
import 'data/repositories/table_repository_impl.dart';
import 'data/repositories/tables_repository_impl.dart';
import 'domain/repositories/tables_repository.dart';
import 'domain/repositories/table_repository.dart';
import 'domain/usecases/add_table_usecase.dart';
import 'domain/usecases/delete_table_usecase.dart';
import 'domain/usecases/get_tables_usecase.dart';
import 'domain/usecases/update_table_sort_orders_usecase.dart';
import 'domain/usecases/update_table_usecase.dart';
import 'domain/usecases/watch_tables_use_case.dart';
import 'presentation/bloc/table_picker_bloc.dart';
import 'presentation/cubit/table_cubit.dart';

void registerTableDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<TableLocalDataSource>(
    () => TableLocalDataSourceImpl(database: sl<CoozyDatabase>()),
  );
  sl.registerLazySingleton<TablePickerDao>(
    () => TablePickerDao(sl<CoozyDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<TableRepository>(
    () => TableRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TablesRepository>(
    () => TablesRepositoryImpl(tablePickerDao: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTablesUseCase(sl()));
  sl.registerLazySingleton(() => AddTableUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTableUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTableUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTableSortOrdersUseCase(sl()));
  sl.registerLazySingleton(() => WatchTablesUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => TableCubit(
      getTablesUseCase: sl(),
      addTableUseCase: sl(),
      updateTableUseCase: sl(),
      deleteTableUseCase: sl(),
      updateTableSortOrdersUseCase: sl(),
    ),
  );
  sl.registerFactory(() => TablePickerBloc(watchTablesUseCase: sl()));
}
