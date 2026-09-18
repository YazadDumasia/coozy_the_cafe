part of 'cash_flow_bloc.dart';

sealed class CashFlowEvent extends Equatable {
  const CashFlowEvent();

  @override
  List<Object?> get props => [];
}

class LoadCashFlowData extends CashFlowEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? typeFilter;

  const LoadCashFlowData({this.startDate, this.endDate, this.typeFilter});

  @override
  List<Object?> get props => [startDate, endDate, typeFilter];
}

class ChangeDateRangeFilter extends CashFlowEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String dateRangeLabel;

  const ChangeDateRangeFilter({
    required this.startDate,
    required this.endDate,
    required this.dateRangeLabel,
  });

  @override
  List<Object?> get props => [startDate, endDate, dateRangeLabel];
}

class AddTransactionSubmitted extends CashFlowEvent {
  final ExpenditureEntity expenditure;

  const AddTransactionSubmitted(this.expenditure);

  @override
  List<Object?> get props => [expenditure];
}

class DeleteTransactionSubmitted extends CashFlowEvent {
  final int id;

  const DeleteTransactionSubmitted(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadMoreCashFlowData extends CashFlowEvent {
  const LoadMoreCashFlowData();

  @override
  List<Object?> get props => [];
}
