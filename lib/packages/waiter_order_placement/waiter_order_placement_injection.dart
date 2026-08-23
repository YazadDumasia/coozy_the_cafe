import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/waiter_order_placement_local_datasource.dart';
import 'data/repositories/waiter_order_placement_repository_impl.dart';
import 'domain/repositories/waiter_order_placement_repository.dart';
import 'domain/usecases/delete_table_order_usecase.dart';
import 'domain/usecases/get_active_menu_catalog_usecase.dart';
import 'domain/usecases/get_active_table_orders_usecase.dart';
import 'domain/usecases/get_order_details_usecase.dart';
import 'domain/usecases/submit_order_usecase.dart';
import 'presentation/bloc/active_table_orders_bloc.dart';
import 'presentation/bloc/menu_item_picker_bloc.dart';

void registerWaiterOrderPlacementDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<WaiterOrderPlacementLocalDataSource>(
    () => WaiterOrderPlacementLocalDataSourceImpl(sl<CoozyDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<WaiterOrderPlacementRepository>(
    () => WaiterOrderPlacementRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => GetActiveMenuCatalogUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => SubmitOrderUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetOrderDetailsUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => GetActiveTableOrdersUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => DeleteTableOrderUseCase(sl()),
  );

  // BLoC
  sl.registerFactory(
    () => MenuItemPickerBloc(
      getActiveMenuCatalogUseCase: sl(),
      submitOrderUseCase: sl(),
      getOrderDetailsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => ActiveTableOrdersBloc(
      getActiveTableOrdersUseCase: sl(),
      deleteTableOrderUseCase: sl(),
    ),
  );
}
