import 'package:get_it/get_it.dart';
import 'data/datasources/currency_exchange_api_service.dart';
import 'presentation/pages/currency_exchange/cubit/currency_exchange_cubit.dart';

void registerSettingsDependencies(GetIt sl) {
  // Services
  sl.registerLazySingleton<CurrencyExchangeApiService>(
    () => CurrencyExchangeApiService(),
  );

  // Cubits
  sl.registerFactory<CurrencyExchangeCubit>(
    () => CurrencyExchangeCubit(apiService: sl<CurrencyExchangeApiService>()),
  );
}
