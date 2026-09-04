import 'package:get_it/get_it.dart';
import 'domain/repositories/customer_repository.dart';
import 'data/repositories/customer_repository_impl.dart';
import 'domain/usecases/customer_usecases.dart';
import 'presentation/bloc/customer_bloc.dart';
import '../database/coozy_database.dart';

void registerCustomerDependencies(GetIt sl) {
  // DAO
  if (!sl.isRegistered<CustomersDao>()) {
    sl.registerLazySingleton<CustomersDao>(
      () => sl<CoozyDatabase>().customersDao,
    );
  }

  // Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl<CustomersDao>()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomerUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCustomerUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCustomerUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => CustomerBloc(
      getCustomersUseCase: sl(),
      addCustomerUseCase: sl(),
      updateCustomerUseCase: sl(),
      deleteCustomerUseCase: sl(),
    ),
  );
}
