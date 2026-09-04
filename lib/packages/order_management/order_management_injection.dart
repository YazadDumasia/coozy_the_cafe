import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'data/datasources/order_management_local_data_source.dart';
import 'data/repositories/order_management_repository_impl.dart';
import 'domain/repositories/order_management_repository.dart';
import 'domain/usecases/get_paginated_orders_usecase.dart';
import 'domain/usecases/get_order_info_usecase.dart';
import 'domain/usecases/update_order_status_usecase.dart';
import 'presentation/bloc/order_management_bloc.dart';

void registerOrderManagementDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<OrderManagementLocalDataSource>(
    () => OrderManagementLocalDataSourceImpl(ordersDao: sl<OrdersDao>()),
  );

  // Repository
  sl.registerLazySingleton<OrderManagementRepository>(
    () => OrderManagementRepositoryImpl(
      localDataSource: sl<OrderManagementLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetPaginatedOrdersUseCase>(
    () => GetPaginatedOrdersUseCase(sl<OrderManagementRepository>()),
  );
  sl.registerLazySingleton<GetOrderInfoUseCase>(
    () => GetOrderInfoUseCase(sl<OrderManagementRepository>()),
  );
  sl.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(sl<OrderManagementRepository>()),
  );

  // Bloc
  sl.registerFactory<OrderManagementBloc>(
    () => OrderManagementBloc(
      getPaginatedOrdersUseCase: sl<GetPaginatedOrdersUseCase>(),
      getOrderInfoUseCase: sl<GetOrderInfoUseCase>(),
      updateOrderStatusUseCase: sl<UpdateOrderStatusUseCase>(),
    ),
  );
}
