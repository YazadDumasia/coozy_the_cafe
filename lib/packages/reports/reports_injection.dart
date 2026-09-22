import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'data/datasources/reports_local_data_source.dart';
import 'data/repositories/reports_repository_impl.dart';
import 'domain/repositories/reports_repository.dart';
import 'domain/usecases/reports_usecases.dart';
import 'presentation/bloc/reports_cubit/reports_cubit.dart';

void registerReportsDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<ReportsLocalDataSource>(
    () => ReportsLocalDataSourceImpl(database: sl<CoozyDatabase>()),
  );

  // Repository
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDailySalesSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetMonthlySalesSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetTopSellingItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentModeReportUseCase(sl()));
  sl.registerLazySingleton(() => GetSalesDashboardUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuItemSalesReportUseCase(sl()));
  sl.registerLazySingleton(() => GetInventoryStockReportUseCase(sl()));
  sl.registerLazySingleton(() => GetPurchaseSummaryReportUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenditureSummaryReportUseCase(sl()));

  // Cubit
  sl.registerFactory(
    () => ReportsCubit(
      getDailySalesSummaryUseCase: sl(),
      getMonthlySalesSummaryUseCase: sl(),
      getTopSellingItemsUseCase: sl(),
      getPaymentModeReportUseCase: sl(),
      getSalesDashboardUseCase: sl(),
      getInventoryStockReportUseCase: sl(),
      getPurchaseSummaryReportUseCase: sl(),
      getExpenditureSummaryReportUseCase: sl(),
      getMenuItemSalesReportUseCase: sl(),
    ),
  );
}
