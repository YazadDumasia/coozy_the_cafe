import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../repositories/expenditure_repository.dart';

class GetExpenditureChartDataUseCase {
  final ExpenditureRepository repository;

  GetExpenditureChartDataUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> getDailyIncomeExpense({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getDailyIncomeExpenseSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getCategoryBreakdown({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getCategoryBreakdownSummary(
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
