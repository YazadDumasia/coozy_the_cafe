import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:get_it/get_it.dart';
import 'data/repositories/checkout_repository_impl.dart';
import 'domain/repositories/checkout_repository.dart';
import 'domain/usecases/checkout_calculator.dart';
import 'domain/usecases/get_order_checkout_data.dart';
import 'presentation/bloc/checkout_bloc.dart';

void registerCheckoutDependencies(GetIt sl) {
  // Data Sources / DAOs
  if (!sl.isRegistered<OrdersDao>()) {
    sl.registerLazySingleton(() => OrdersDao(sl()));
  }

  // Repository
  sl.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(ordersDao: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => const CheckoutCalculator());
  sl.registerLazySingleton(() => GetOrderCheckoutData(sl()));

  // BLoC
  sl.registerFactory(
    () => CheckoutBloc(
      calculator: sl(),
      getOrderCheckoutData: sl(),
    ),
  );
}

