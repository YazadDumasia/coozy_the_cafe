import 'package:equatable/equatable.dart';

class CashFlowSummaryEntity extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netCashFlow;

  const CashFlowSummaryEntity({
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
  });

  @override
  List<Object?> get props => [totalIncome, totalExpense, netCashFlow];
}
