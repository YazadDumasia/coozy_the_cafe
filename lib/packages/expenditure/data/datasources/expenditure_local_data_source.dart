import 'package:coozy_the_cafe/packages/database/src/database_dao/expenditure_dao.dart';
import '../models/expenditure_category_model.dart';

import '../models/expenditure_model.dart';

abstract class ExpenditureLocalDataSource {
  Future<List<ExpenditureCategoryModel>> getCategoriesByType(String type);
  Stream<List<ExpenditureCategoryModel>> watchCategoriesByType(String type);
  Future<int> insertCategory(ExpenditureCategoryModel category);
  Future<bool> deleteCategory(int id);

  Future<List<ExpenditureModel>> getExpendituresByDateRange({
    required String startIso,
    required String endIso,
    String? type,
    int? limit,
    int? offset,
  });

  Stream<List<ExpenditureModel>> watchExpendituresByDateRange({
    required String startIso,
    required String endIso,
  });

  Future<Map<String, double>> getTotalsByDateRange({
    required String startIso,
    required String endIso,
  });

  Future<int> insertExpenditure(ExpenditureModel model);
  Future<bool> updateExpenditure(ExpenditureModel model);
  Future<bool> deleteExpenditure(int id);

  Future<List<Map<String, dynamic>>> getDailyIncomeExpenseSummary({
    required String startIso,
    required String endIso,
  });

  Future<List<Map<String, dynamic>>> getCategoryBreakdownSummary({
    required String type,
    required String startIso,
    required String endIso,
  });
}

class ExpenditureLocalDataSourceImpl implements ExpenditureLocalDataSource {
  final ExpenditureDao expenditureDao;

  ExpenditureLocalDataSourceImpl(this.expenditureDao);

  @override
  Future<List<ExpenditureCategoryModel>> getCategoriesByType(
    String type,
  ) async {
    final list = await expenditureDao.getCategoriesByType(type);
    return list.map(ExpenditureCategoryModel.fromTableData).toList();
  }

  @override
  Stream<List<ExpenditureCategoryModel>> watchCategoriesByType(String type) {
    return expenditureDao
        .watchCategoriesByType(type)
        .map(
          (list) => list.map(ExpenditureCategoryModel.fromTableData).toList(),
        );
  }

  @override
  Future<int> insertCategory(ExpenditureCategoryModel category) {
    return expenditureDao.insertCategory(category.toCompanion());
  }

  @override
  Future<bool> deleteCategory(int id) {
    return expenditureDao.deleteCategory(id);
  }

  @override
  Future<List<ExpenditureModel>> getExpendituresByDateRange({
    required String startIso,
    required String endIso,
    String? type,
    int? limit,
    int? offset,
  }) async {
    final list = await expenditureDao.getExpendituresByDateRange(
      startIso: startIso,
      endIso: endIso,
      type: type,
      limit: limit,
      offset: offset,
    );
    return list.map(ExpenditureModel.fromTableData).toList();
  }

  @override
  Stream<List<ExpenditureModel>> watchExpendituresByDateRange({
    required String startIso,
    required String endIso,
  }) {
    return expenditureDao
        .watchExpendituresByDateRange(startIso: startIso, endIso: endIso)
        .map((list) => list.map(ExpenditureModel.fromTableData).toList());
  }

  @override
  Future<Map<String, double>> getTotalsByDateRange({
    required String startIso,
    required String endIso,
  }) {
    return expenditureDao.getTotalsByDateRange(
      startIso: startIso,
      endIso: endIso,
    );
  }

  @override
  Future<int> insertExpenditure(ExpenditureModel model) {
    return expenditureDao.insertExpenditure(model.toCompanion());
  }

  @override
  Future<bool> updateExpenditure(ExpenditureModel model) {
    return expenditureDao.updateExpenditure(model.toCompanion());
  }

  @override
  Future<bool> deleteExpenditure(int id) {
    return expenditureDao.softDeleteExpenditure(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyIncomeExpenseSummary({
    required String startIso,
    required String endIso,
  }) {
    return expenditureDao.getDailyIncomeExpenseSummary(
      startIso: startIso,
      endIso: endIso,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoryBreakdownSummary({
    required String type,
    required String startIso,
    required String endIso,
  }) {
    return expenditureDao.getCategoryBreakdownSummary(
      type: type,
      startIso: startIso,
      endIso: endIso,
    );
  }
}
