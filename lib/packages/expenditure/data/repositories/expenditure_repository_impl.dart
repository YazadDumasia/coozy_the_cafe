import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../../domain/entities/cash_flow_summary_entity.dart';
import '../../domain/entities/expenditure_category_entity.dart';
import '../../domain/entities/expenditure_entity.dart';
import '../../domain/repositories/expenditure_repository.dart';
import '../datasources/expenditure_local_data_source.dart';
import '../models/expenditure_category_model.dart';
import '../models/expenditure_model.dart';

class ExpenditureRepositoryImpl implements ExpenditureRepository {
  final ExpenditureLocalDataSource localDataSource;

  ExpenditureRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<ExpenditureCategoryEntity>>> getCategoriesByType(
    String type,
  ) async {
    try {
      final list = await localDataSource.getCategoriesByType(type);
      return Right(list);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to load categories: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ExpenditureCategoryEntity>>>
  watchCategoriesByType(String type) {
    return localDataSource
        .watchCategoriesByType(type)
        .map<Either<Failure, List<ExpenditureCategoryEntity>>>(
          (list) => Right(list),
        )
        .handleError(
          (error) =>
              Left(DatabaseFailure(message: 'Stream categories error: $error')),
        );
  }

  @override
  Future<Either<Failure, int>> addCategory(
    ExpenditureCategoryEntity category,
  ) async {
    try {
      final model = ExpenditureCategoryModel(
        name: category.name,
        type: category.type,
        iconCodePoint: category.iconCodePoint,
        iconFontFamily: category.iconFontFamily,
        colorHex: category.colorHex,
        isCustom: category.isCustom,
        isEnabled: category.isEnabled,
      );
      final id = await localDataSource.insertCategory(model);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to add category: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(int id) async {
    try {
      final res = await localDataSource.deleteCategory(id);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExpenditureEntity>>> getExpendituresByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? type,
    int? limit,
    int? offset,
  }) async {
    try {
      final startIso = startDate.toIso8601String();
      final endIso = endDate.toIso8601String();
      final list = await localDataSource.getExpendituresByDateRange(
        startIso: startIso,
        endIso: endIso,
        type: type,
        limit: limit,
        offset: offset,
      );
      return Right(list);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to load expenditures: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ExpenditureEntity>>>
  watchExpendituresByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final startIso = startDate.toIso8601String();
    final endIso = endDate.toIso8601String();
    return localDataSource
        .watchExpendituresByDateRange(startIso: startIso, endIso: endIso)
        .map<Either<Failure, List<ExpenditureEntity>>>((list) => Right(list))
        .handleError(
          (error) => Left(
            DatabaseFailure(message: 'Stream expenditures error: $error'),
          ),
        );
  }

  @override
  Future<Either<Failure, CashFlowSummaryEntity>> getCashFlowSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startIso = startDate.toIso8601String();
      final endIso = endDate.toIso8601String();
      final totals = await localDataSource.getTotalsByDateRange(
        startIso: startIso,
        endIso: endIso,
      );
      return Right(
        CashFlowSummaryEntity(
          totalIncome: totals['income'] ?? 0.0,
          totalExpense: totals['expense'] ?? 0.0,
          netCashFlow: totals['net'] ?? 0.0,
        ),
      );
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to get cash flow summary: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> addExpenditure(
    ExpenditureEntity expenditure,
  ) async {
    try {
      final model = ExpenditureModel(
        type: expenditure.type,
        categoryId: expenditure.categoryId,
        categoryName: expenditure.categoryName,
        amount: expenditure.amount,
        partyName: expenditure.partyName,
        date: expenditure.date,
        paymentMethod: expenditure.paymentMethod,
        notes: expenditure.notes,
        referenceType: expenditure.referenceType,
        referenceId: expenditure.referenceId,
      );
      final id = await localDataSource.insertExpenditure(model);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to add expenditure: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateExpenditure(
    ExpenditureEntity expenditure,
  ) async {
    try {
      final model = ExpenditureModel(
        id: expenditure.id,
        hashId: expenditure.hashId,
        type: expenditure.type,
        categoryId: expenditure.categoryId,
        categoryName: expenditure.categoryName,
        amount: expenditure.amount,
        partyName: expenditure.partyName,
        date: expenditure.date,
        paymentMethod: expenditure.paymentMethod,
        notes: expenditure.notes,
        referenceType: expenditure.referenceType,
        referenceId: expenditure.referenceId,
        isDeleted: expenditure.isDeleted,
      );
      final res = await localDataSource.updateExpenditure(model);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update expenditure: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteExpenditure(int id) async {
    try {
      final res = await localDataSource.deleteExpenditure(id);
      return Right(res);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete expenditure: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getDailyIncomeExpenseSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startIso = startDate.toIso8601String();
      final endIso = endDate.toIso8601String();
      final list = await localDataSource.getDailyIncomeExpenseSummary(
        startIso: startIso,
        endIso: endIso,
      );
      return Right(list);
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to get chart daily summary: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getCategoryBreakdownSummary({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startIso = startDate.toIso8601String();
      final endIso = endDate.toIso8601String();
      final list = await localDataSource.getCategoryBreakdownSummary(
        type: type,
        startIso: startIso,
        endIso: endIso,
      );
      return Right(list);
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to get category breakdown: $e'),
      );
    }
  }
}
