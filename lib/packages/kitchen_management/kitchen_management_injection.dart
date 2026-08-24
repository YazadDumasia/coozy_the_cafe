import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/kitchen_local_datasource.dart';
import 'data/repositories/kitchen_repository_impl.dart';
import 'domain/repositories/kitchen_repository.dart';
import 'domain/usecases/get_active_kitchen_orders_usecase.dart';
import 'domain/usecases/get_aggregated_pending_items_usecase.dart';
import 'domain/usecases/update_all_order_items_status_usecase.dart';
import 'domain/usecases/update_order_item_status_usecase.dart';
import 'domain/usecases/watch_active_kitchen_orders_usecase.dart';
import 'presentation/bloc/kitchen_bloc.dart';

void registerKitchenManagementDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<KitchenLocalDataSource>(
    () => KitchenLocalDataSourceImpl(sl<CoozyDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<KitchenRepository>(
    () => KitchenRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetActiveKitchenOrdersUseCase(sl()));
  sl.registerLazySingleton(() => WatchActiveKitchenOrdersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderItemStatusUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAllOrderItemsStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetAggregatedPendingItemsUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => KitchenBloc(
      getActiveKitchenOrdersUseCase: sl(),
      watchActiveKitchenOrdersUseCase: sl(),
      updateOrderItemStatusUseCase: sl(),
      updateAllOrderItemsStatusUseCase: sl(),
      getAggregatedPendingItemsUseCase: sl(),
    ),
  );
}
