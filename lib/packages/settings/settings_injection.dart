import 'package:get_it/get_it.dart';

import 'data/datasources/currency_exchange_api_service.dart';
import 'domain/services/thermal_printer_service.dart';
import 'domain/services/local_p2p_sync_service.dart';
import 'presentation/pages/currency_exchange/cubit/currency_exchange_cubit.dart';
import 'presentation/pages/settings/cubit/thermal_printer_settings_cubit.dart';
import 'presentation/pages/settings/cubit/p2p_sync_settings_cubit.dart';

void registerSettingsDependencies(GetIt sl) {
  // Services
  sl.registerLazySingleton<CurrencyExchangeApiService>(
    () => CurrencyExchangeApiService(),
  );
  sl.registerLazySingleton<ThermalPrinterService>(
    () => ThermalPrinterService.instance,
  );
  sl.registerLazySingleton<LocalP2pSyncService>(
    () => LocalP2pSyncService.instance,
  );

  // Cubits
  sl.registerFactory<CurrencyExchangeCubit>(
    () => CurrencyExchangeCubit(apiService: sl<CurrencyExchangeApiService>()),
  );
  sl.registerFactory<ThermalPrinterSettingsCubit>(
    () => ThermalPrinterSettingsCubit(
      printerService: sl<ThermalPrinterService>(),
    ),
  );
  sl.registerFactory<P2pSyncSettingsCubit>(
    () => P2pSyncSettingsCubit(
      syncService: sl<LocalP2pSyncService>(),
    ),
  );
}


