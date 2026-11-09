import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'package:coozy_the_cafe/packages/database/src/database_dao/stock_alerts_dao.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/data/datasources/inventory_intelligence_local_datasource.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/data/repositories/inventory_intelligence_repository_impl.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/repositories/inventory_intelligence_repository.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/usecases/inventory_intelligence_usecases.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/cubit/stock_alerts_cubit.dart';

void initInventoryIntelligenceDependencies() {
  final sl = GetIt.instance;

  // DAO
  sl.registerLazySingleton<StockAlertsDao>(
    () => StockAlertsDao(sl<CoozyDatabase>()),
  );

  // Data Source
  sl.registerLazySingleton<InventoryIntelligenceLocalDataSource>(
    () => InventoryIntelligenceLocalDataSourceImpl(
      stockAlertsDao: sl<StockAlertsDao>(),
      database: sl<CoozyDatabase>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<InventoryIntelligenceRepository>(
    () => InventoryIntelligenceRepositoryImpl(
      localDataSource: sl<InventoryIntelligenceLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => WatchActiveAlertsUseCase(sl<InventoryIntelligenceRepository>()),
  );
  sl.registerLazySingleton(
    () => GetActiveAlertsUseCase(sl<InventoryIntelligenceRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchStockThresholdsUseCase(sl<InventoryIntelligenceRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateStockThresholdUseCase(sl<InventoryIntelligenceRepository>()),
  );
  sl.registerLazySingleton(
    () => DismissStockAlertUseCase(sl<InventoryIntelligenceRepository>()),
  );
  sl.registerLazySingleton(
    () => ScanAndGenerateAlertsUseCase(sl<InventoryIntelligenceRepository>()),
  );
  sl.registerLazySingleton(
    () =>
        GetAutoReorderSuggestionsUseCase(sl<InventoryIntelligenceRepository>()),
  );
  sl.registerLazySingleton(
    () => ExecuteReorderUseCase(sl<InventoryIntelligenceRepository>()),
  );

  // Cubit
  sl.registerFactory(
    () => StockAlertsCubit(
      watchActiveAlertsUseCase: sl<WatchActiveAlertsUseCase>(),
      getActiveAlertsUseCase: sl<GetActiveAlertsUseCase>(),
      watchStockThresholdsUseCase: sl<WatchStockThresholdsUseCase>(),
      updateStockThresholdUseCase: sl<UpdateStockThresholdUseCase>(),
      dismissStockAlertUseCase: sl<DismissStockAlertUseCase>(),
      scanAndGenerateAlertsUseCase: sl<ScanAndGenerateAlertsUseCase>(),
      getAutoReorderSuggestionsUseCase: sl<GetAutoReorderSuggestionsUseCase>(),
      executeReorderUseCase: sl<ExecuteReorderUseCase>(),
    ),
  );
}
