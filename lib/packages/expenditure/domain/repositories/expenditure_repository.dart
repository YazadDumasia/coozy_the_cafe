import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/expenditure_entity.dart';
import '../entities/expenditure_category_entity.dart';
import '../entities/cash_flow_summary_entity.dart';

abstract class ExpenditureRepository {
  Future<Either<Failure, List<ExpenditureCategoryEntity>>> getCategoriesByType(
    String type,
  );
  Stream<Either<Failure, List<ExpenditureCategoryEntity>>>
  watchCategoriesByType(String type);
  Future<Either<Failure, int>> addCategory(ExpenditureCategoryEntity category);
  Future<Either<Failure, bool>> deleteCategory(int id);

  Future<Either<Failure, List<ExpenditureEntity>>> getExpendituresByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? type,
    int? limit,
    int? offset,
  });

  Stream<Either<Failure, List<ExpenditureEntity>>>
  watchExpendituresByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, CashFlowSummaryEntity>> getCashFlowSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, int>> addExpenditure(ExpenditureEntity expenditure);
  Future<Either<Failure, bool>> updateExpenditure(
    ExpenditureEntity expenditure,
  );
  Future<Either<Failure, bool>> deleteExpenditure(int id);

  Future<Either<Failure, List<Map<String, dynamic>>>>
  getDailyIncomeExpenseSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>>
  getCategoryBreakdownSummary({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  });
}
