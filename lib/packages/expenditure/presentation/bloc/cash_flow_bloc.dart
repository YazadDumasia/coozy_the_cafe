import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../../domain/entities/cash_flow_summary_entity.dart';
import '../../domain/entities/expenditure_entity.dart';
import '../../domain/usecases/get_cash_flow_summary_usecase.dart';
import '../../domain/usecases/get_expenditures_by_date_range_usecase.dart';
import '../../domain/usecases/expenditure_mutation_usecases.dart';

part 'cash_flow_event.dart';
part 'cash_flow_state.dart';

class CashFlowBloc extends Bloc<CashFlowEvent, CashFlowState> {
  final GetCashFlowSummaryUseCase getCashFlowSummary;
  final GetExpendituresByDateRangeUseCase getExpendituresByDateRange;
  final AddExpenditureUseCase addExpenditure;
  final DeleteExpenditureUseCase deleteExpenditure;

  DateTime _currentStartDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _currentEndDate = DateTime.now();
  String _currentRangeLabel = '';
  String? _currentTypeFilter;
  int _currentOffset = 0;
  static const int _pageSize = 25;

  CashFlowBloc({
    required this.getCashFlowSummary,
    required this.getExpendituresByDateRange,
    required this.addExpenditure,
    required this.deleteExpenditure,
  }) : super(CashFlowInitial()) {
    on<LoadCashFlowData>(_onLoadCashFlowData);
    on<LoadMoreCashFlowData>(_onLoadMoreCashFlowData);
    on<ChangeDateRangeFilter>(_onChangeDateRangeFilter);
    on<AddTransactionSubmitted>(_onAddTransactionSubmitted);
    on<DeleteTransactionSubmitted>(_onDeleteTransactionSubmitted);

    final startStr =
        DateUtil.localFormatDateTime(_currentStartDate, 'dd MMM yyyy') ?? '';
    final endStr =
        DateUtil.localFormatDateTime(_currentEndDate, 'dd MMM yyyy') ?? '';
    _currentRangeLabel = '$startStr - $endStr';
  }

  ({
    Map<String, List<ExpenditureEntity>> grouped,
    Map<String, double> dailyIncome,
    Map<String, double> dailyExpense,
  })
  _groupTransactions(List<ExpenditureEntity> transactions) {
    final grouped = <String, List<ExpenditureEntity>>{};
    final dailyIncome = <String, double>{};
    final dailyExpense = <String, double>{};

    for (final item in transactions) {
      DateTime dt = DateTime.tryParse(item.date) ?? DateTime.now();
      String dateKey = DateUtil.localFormatDateTime(dt, 'dd-MMM-yyyy') ?? '';
      final todayStr =
          DateUtil.localFormatDateTime(DateTime.now(), 'dd-MMM-yyyy') ?? '';
      if (dateKey == todayStr) {
        dateKey = '$dateKey (Today)';
      }

      grouped.putIfAbsent(dateKey, () => []).add(item);

      if (item.type == 'INCOME') {
        dailyIncome[dateKey] = (dailyIncome[dateKey] ?? 0.0) + item.amount;
      } else {
        dailyExpense[dateKey] = (dailyExpense[dateKey] ?? 0.0) + item.amount;
      }
    }

    return (
      grouped: grouped,
      dailyIncome: dailyIncome,
      dailyExpense: dailyExpense,
    );
  }

  Future<void> _onLoadCashFlowData(
    LoadCashFlowData event,
    Emitter<CashFlowState> emit,
  ) async {
    if (event.startDate != null) _currentStartDate = event.startDate!;
    if (event.endDate != null) _currentEndDate = event.endDate!;
    _currentTypeFilter = event.typeFilter;
    _currentOffset = 0;

    final startOfDay = DateTime(
      _currentStartDate.year,
      _currentStartDate.month,
      _currentStartDate.day,
      0,
      0,
      0,
    );
    final endOfDay = DateTime(
      _currentEndDate.year,
      _currentEndDate.month,
      _currentEndDate.day,
      23,
      59,
      59,
    );

    emit(CashFlowLoading());

    final summaryResult = await getCashFlowSummary(
      startDate: startOfDay,
      endDate: endOfDay,
    );

    final transactionsResult = await getExpendituresByDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
      type: _currentTypeFilter,
      limit: _pageSize,
      offset: 0,
    );

    summaryResult.fold((failure) => emit(CashFlowError(failure.message)), (
      summary,
    ) {
      transactionsResult.fold(
        (failure) => emit(CashFlowError(failure.message)),
        (transactions) {
          final grouping = _groupTransactions(transactions);
          final bool hasReachedMax = transactions.length < _pageSize;
          _currentOffset = transactions.length;

          final startFormatted =
              DateUtil.localFormatDateTime(_currentStartDate, 'dd MMM yyyy') ??
              '';
          final endFormatted =
              DateUtil.localFormatDateTime(_currentEndDate, 'dd MMM yyyy') ??
              '';
          _currentRangeLabel = '$startFormatted - $endFormatted';

          emit(
            CashFlowLoaded(
              startDate: _currentStartDate,
              endDate: _currentEndDate,
              dateRangeLabel: _currentRangeLabel,
              summary: summary,
              transactions: transactions,
              groupedTransactions: grouping.grouped,
              dailyIncomeTotals: grouping.dailyIncome,
              dailyExpenseTotals: grouping.dailyExpense,
              hasReachedMax: hasReachedMax,
              isLoadingMore: false,
            ),
          );
        },
      );
    });
  }

  Future<void> _onLoadMoreCashFlowData(
    LoadMoreCashFlowData event,
    Emitter<CashFlowState> emit,
  ) async {
    if (state is! CashFlowLoaded) return;
    final currentState = state as CashFlowLoaded;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final startOfDay = DateTime(
      _currentStartDate.year,
      _currentStartDate.month,
      _currentStartDate.day,
      0,
      0,
      0,
    );
    final endOfDay = DateTime(
      _currentEndDate.year,
      _currentEndDate.month,
      _currentEndDate.day,
      23,
      59,
      59,
    );

    final result = await getExpendituresByDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
      type: _currentTypeFilter,
      limit: _pageSize,
      offset: _currentOffset,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isLoadingMore: false)),
      (newTransactions) {
        final updatedTransactions = List<ExpenditureEntity>.from(
          currentState.transactions,
        )..addAll(newTransactions);
        final bool hasReachedMax = newTransactions.length < _pageSize;
        _currentOffset += newTransactions.length;

        final grouping = _groupTransactions(updatedTransactions);

        emit(
          currentState.copyWith(
            transactions: updatedTransactions,
            groupedTransactions: grouping.grouped,
            dailyIncomeTotals: grouping.dailyIncome,
            dailyExpenseTotals: grouping.dailyExpense,
            hasReachedMax: hasReachedMax,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onChangeDateRangeFilter(
    ChangeDateRangeFilter event,
    Emitter<CashFlowState> emit,
  ) async {
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;
    _currentRangeLabel = event.dateRangeLabel;
    add(
      LoadCashFlowData(startDate: _currentStartDate, endDate: _currentEndDate),
    );
  }

  Future<void> _onAddTransactionSubmitted(
    AddTransactionSubmitted event,
    Emitter<CashFlowState> emit,
  ) async {
    final result = await addExpenditure(event.expenditure);
    result.fold(
      (failure) => emit(CashFlowError(failure.message)),
      (_) => add(
        LoadCashFlowData(
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        ),
      ),
    );
  }

  Future<void> _onDeleteTransactionSubmitted(
    DeleteTransactionSubmitted event,
    Emitter<CashFlowState> emit,
  ) async {
    final result = await deleteExpenditure(event.id);
    result.fold(
      (failure) => emit(CashFlowError(failure.message)),
      (_) => add(
        LoadCashFlowData(
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        ),
      ),
    );
  }
}
