part of 'currency_exchange_cubit.dart';

sealed class CurrencyExchangeState extends Equatable {
  const CurrencyExchangeState();

  @override
  List<Object?> get props => [];
}

class CurrencyExchangeInitial extends CurrencyExchangeState {
  const CurrencyExchangeInitial();
}

class CurrencyExchangeLoading extends CurrencyExchangeState {
  const CurrencyExchangeLoading();
}

class CurrencyExchangeLoaded extends CurrencyExchangeState {
  final Map<String, String> currencies;
  final Map<String, double> rates;
  final String baseCurrency;
  final String targetCurrency;
  final double amount;
  final String date;
  final bool isOffline;
  final double spreadPercentage;
  final String searchQuery;

  final bool isChangingBase;

  const CurrencyExchangeLoaded({
    required this.currencies,
    required this.rates,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.amount,
    required this.date,
    required this.isOffline,
    this.spreadPercentage = 0.5, // 0.5% default market spread
    this.searchQuery = '',
    this.isChangingBase = false,
  });

  bool get hasTargetRate => rates.containsKey(targetCurrency.toLowerCase());
  double? get rawTargetRate => rates[targetCurrency.toLowerCase()];
  double get targetRate => rawTargetRate ?? 1.0;
  double get convertedAmount => amount * targetRate;

  // Spread calculations (Bid / Ask)
  double get bidRate => targetRate * (1 - (spreadPercentage / 100));
  double get askRate => targetRate * (1 + (spreadPercentage / 100));
  double get bidAmount => amount * bidRate;
  double get askAmount => amount * askRate;

  CurrencyExchangeLoaded copyWith({
    Map<String, String>? currencies,
    Map<String, double>? rates,
    String? baseCurrency,
    String? targetCurrency,
    double? amount,
    String? date,
    bool? isOffline,
    double? spreadPercentage,
    String? searchQuery,
    bool? isChangingBase,
  }) {
    return CurrencyExchangeLoaded(
      currencies: currencies ?? this.currencies,
      rates: rates ?? this.rates,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isOffline: isOffline ?? this.isOffline,
      spreadPercentage: spreadPercentage ?? this.spreadPercentage,
      searchQuery: searchQuery ?? this.searchQuery,
      isChangingBase: isChangingBase ?? this.isChangingBase,
    );
  }

  @override
  List<Object?> get props => [
        currencies,
        rates,
        baseCurrency,
        targetCurrency,
        amount,
        date,
        isOffline,
        spreadPercentage,
        searchQuery,
        isChangingBase,
      ];
}

class CurrencyExchangeError extends CurrencyExchangeState {
  final String message;

  const CurrencyExchangeError(this.message);

  @override
  List<Object?> get props => [message];
}
