import 'package:get_it/get_it.dart';
import 'data/datasources/purchase_local_data_source.dart';
import 'data/repositories/purchase_repository_impl.dart';
import 'domain/repositories/purchase_repository.dart';
import 'domain/usecases/purchase_usecases.dart';
import 'presentation/bloc/item_purchase_bloc.dart';
import 'presentation/bloc/purchase_list_bloc.dart';

void registerPurchaseDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<PurchaseLocalDataSource>(
    () => PurchaseLocalDataSourceImpl(database: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPurchasesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllPurchasesPagedUseCase(sl()));
  sl.registerLazySingleton(() => AddPurchaseRecordUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePurchaseRecordUseCase(sl()));
  sl.registerLazySingleton(() => DeletePurchaseRecordUseCase(sl()));
  sl.registerLazySingleton(() => GetPurchaseSummaryUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => PurchaseListBloc(
      getAllPurchasesPagedUseCase: sl(),
      addPurchaseRecordUseCase: sl(),
      updatePurchaseRecordUseCase: sl(),
      deletePurchaseRecordUseCase: sl(),
      getPurchaseSummaryUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ItemPurchaseBloc(
      getPurchasesUseCase: sl(),
      addPurchaseRecordUseCase: sl(),
    ),
  );
}
