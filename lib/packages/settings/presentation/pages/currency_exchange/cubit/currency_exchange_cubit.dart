import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/currency_exchange_api_service.dart';

part 'currency_exchange_state.dart';

class CurrencyExchangeCubit extends Cubit<CurrencyExchangeState> {
  final CurrencyExchangeApiService apiService;

  CurrencyExchangeCubit({required this.apiService})
      : super(const CurrencyExchangeInitial());

  Future<void> loadExchangeData({
    String baseCurrency = 'usd',
    String targetCurrency = 'inr',
    double initialAmount = 1.0,
    bool forceRefresh = false,
  }) async {
    emit(const CurrencyExchangeLoading());
    try {
      final currencies = await apiService.fetchCurrencies();
      final ratesData = await apiService.fetchRates(
        baseCurrency,
        forceRefresh: forceRefresh,
      );

      final validBase = currencies.containsKey(baseCurrency.toLowerCase())
          ? baseCurrency.toLowerCase()
          : 'usd';
      final validTarget = currencies.containsKey(targetCurrency.toLowerCase())
          ? targetCurrency.toLowerCase()
          : 'inr';

      emit(
        CurrencyExchangeLoaded(
          currencies: currencies,
          rates: ratesData.rates,
          baseCurrency: validBase,
          targetCurrency: validTarget,
          amount: initialAmount,
          date: ratesData.date,
          isOffline: ratesData.isOffline,
        ),
      );
    } catch (e) {
      emit(CurrencyExchangeError(e.toString()));
    }
  }

  Future<void> changeBaseCurrency(String newBase) async {
    if (state is! CurrencyExchangeLoaded) return;
    final currentState = state as CurrencyExchangeLoaded;

    emit(const CurrencyExchangeLoading());
    try {
      final ratesData = await apiService.fetchRates(newBase);
      emit(
        currentState.copyWith(
          baseCurrency: newBase.toLowerCase(),
          rates: ratesData.rates,
          date: ratesData.date,
          isOffline: ratesData.isOffline,
        ),
      );
    } catch (e) {
      emit(CurrencyExchangeError(e.toString()));
    }
  }

  void changeTargetCurrency(String newTarget) {
    if (state is! CurrencyExchangeLoaded) return;
    final currentState = state as CurrencyExchangeLoaded;
    emit(currentState.copyWith(targetCurrency: newTarget.toLowerCase()));
  }

  void swapCurrencies() {
    if (state is! CurrencyExchangeLoaded) return;
    final currentState = state as CurrencyExchangeLoaded;
    final newBase = currentState.targetCurrency;
    final newTarget = currentState.baseCurrency;
    changeBaseCurrency(newBase).then((_) {
      if (state is CurrencyExchangeLoaded) {
        emit((state as CurrencyExchangeLoaded).copyWith(targetCurrency: newTarget));
      }
    });
  }

  void updateAmount(double amount) {
    if (state is! CurrencyExchangeLoaded) return;
    final currentState = state as CurrencyExchangeLoaded;
    emit(currentState.copyWith(amount: amount));
  }

  void updateSpread(double spread) {
    if (state is! CurrencyExchangeLoaded) return;
    final currentState = state as CurrencyExchangeLoaded;
    emit(currentState.copyWith(spreadPercentage: spread));
  }

  void updateSearchQuery(String query) {
    if (state is! CurrencyExchangeLoaded) return;
    final currentState = state as CurrencyExchangeLoaded;
    emit(currentState.copyWith(searchQuery: query));
  }
}
