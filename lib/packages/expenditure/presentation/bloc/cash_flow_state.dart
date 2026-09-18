part of 'cash_flow_bloc.dart';

sealed class CashFlowState extends Equatable {
  const CashFlowState();

  @override
  List<Object?> get props => [];
}

class CashFlowInitial extends CashFlowState {}

class CashFlowLoading extends CashFlowState {}

class CashFlowLoaded extends CashFlowState {
  final DateTime startDate;
  final DateTime endDate;
  final String dateRangeLabel;
  final CashFlowSummaryEntity summary;
  final List<ExpenditureEntity> transactions;
  final Map<String, List<ExpenditureEntity>> groupedTransactions;
  final Map<String, double> dailyIncomeTotals;
  final Map<String, double> dailyExpenseTotals;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const CashFlowLoaded({
    required this.startDate,
    required this.endDate,
    required this.dateRangeLabel,
    required this.summary,
    required this.transactions,
    required this.groupedTransactions,
    required this.dailyIncomeTotals,
    required this.dailyExpenseTotals,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  CashFlowLoaded copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? dateRangeLabel,
    CashFlowSummaryEntity? summary,
    List<ExpenditureEntity>? transactions,
    Map<String, List<ExpenditureEntity>>? groupedTransactions,
    Map<String, double>? dailyIncomeTotals,
    Map<String, double>? dailyExpenseTotals,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return CashFlowLoaded(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateRangeLabel: dateRangeLabel ?? this.dateRangeLabel,
      summary: summary ?? this.summary,
      transactions: transactions ?? this.transactions,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      dailyIncomeTotals: dailyIncomeTotals ?? this.dailyIncomeTotals,
      dailyExpenseTotals: dailyExpenseTotals ?? this.dailyExpenseTotals,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    dateRangeLabel,
    summary,
    transactions,
    groupedTransactions,
    dailyIncomeTotals,
    dailyExpenseTotals,
    hasReachedMax,
    isLoadingMore,
  ];
}

class CashFlowError extends CashFlowState {
  final String message;

  const CashFlowError(this.message);

  @override
  List<Object?> get props => [message];
}
