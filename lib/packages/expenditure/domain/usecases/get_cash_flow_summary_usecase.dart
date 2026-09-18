import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/cash_flow_summary_entity.dart';
import '../repositories/expenditure_repository.dart';

class GetCashFlowSummaryUseCase {
  final ExpenditureRepository repository;

  GetCashFlowSummaryUseCase(this.repository);

  Future<Either<Failure, CashFlowSummaryEntity>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getCashFlowSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
