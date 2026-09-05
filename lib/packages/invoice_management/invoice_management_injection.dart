import 'package:get_it/get_it.dart';
import 'data/datasources/invoice_management_remote_datasource.dart';
import 'data/repositories/invoice_management_repository_impl.dart';
import 'domain/repositories/invoice_management_repository.dart';
import 'domain/usecases/get_paginated_invoices_usecase.dart';
import 'domain/usecases/get_invoice_details_usecase.dart';
import 'domain/usecases/update_invoice_usecase.dart';
import 'domain/usecases/delete_invoice_usecase.dart';
import 'domain/usecases/get_payment_modes_usecase.dart';
import 'presentation/bloc/invoice_management_bloc.dart';

void registerInvoiceManagementDependencies(GetIt sl) {
  // BLoC (Factory)
  sl.registerFactory(
    () => InvoiceManagementBloc(
      getPaginatedInvoicesUseCase: sl(),
      getInvoiceDetailsUseCase: sl(),
      updateInvoiceUseCase: sl(),
      deleteInvoiceUseCase: sl(),
      getPaymentModesUseCase: sl(),
    ),
  );

  // Use Cases (Lazy Singleton)
  sl.registerLazySingleton(() => GetPaginatedInvoicesUseCase(sl()));
  sl.registerLazySingleton(() => GetInvoiceDetailsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentModesUseCase(sl()));

  // Repository (Lazy Singleton)
  sl.registerLazySingleton<InvoiceManagementRepository>(
    () => InvoiceManagementRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source (Lazy Singleton)
  sl.registerLazySingleton<InvoiceManagementRemoteDataSource>(
    () => InvoiceManagementRemoteDataSourceImpl(sl()),
  );
}
