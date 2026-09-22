import 'package:coozy_the_cafe/packages/database/src/database.dart';

abstract class ReportsLocalDataSource {
  Future<List<Map<String, dynamic>>> getDailySalesSummary(
    String startIso,
    String endIso,
  );
  Future<List<Map<String, dynamic>>> getMonthlySalesSummary(
    String startIso,
    String endIso,
  );
  Future<List<Map<String, dynamic>>> getTopSellingItems(
    String startIso,
    String endIso, {
    int limit,
  });
  Future<List<Map<String, dynamic>>> getPaymentModeReport(
    String startIso,
    String endIso,
  );
  Future<Map<String, dynamic>> getSalesDashboard(
    String startIso,
    String endIso,
  );
  Future<List<Map<String, dynamic>>> getMenuItemSalesReport(
    String startIso,
    String endIso, {
    String? itemName,
  });
  Future<List<Map<String, dynamic>>> getInventoryStockReport();
  Future<List<Map<String, dynamic>>> getPurchaseSummaryReport(
    String startIso,
    String endIso,
  );
  Future<List<Map<String, dynamic>>> getExpenditureSummaryReport(
    String startIso,
    String endIso,
  );
}

class ReportsLocalDataSourceImpl implements ReportsLocalDataSource {
  ReportsLocalDataSourceImpl({required this.database});
  final CoozyDatabase database;

  @override
  Future<List<Map<String, dynamic>>> getDailySalesSummary(
    String startIso,
    String endIso,
  ) => database.reportsDao.getDailySalesSummary(startIso, endIso);

  @override
  Future<List<Map<String, dynamic>>> getMonthlySalesSummary(
    String startIso,
    String endIso,
  ) => database.reportsDao.getMonthlySalesSummary(startIso, endIso);

  @override
  Future<List<Map<String, dynamic>>> getTopSellingItems(
    String startIso,
    String endIso, {
    int limit = 10,
  }) => database.reportsDao.getTopSellingItems(startIso, endIso, limit: limit);

  @override
  Future<List<Map<String, dynamic>>> getPaymentModeReport(
    String startIso,
    String endIso,
  ) => database.reportsDao.getPaymentModeReport(startIso, endIso);

  @override
  Future<Map<String, dynamic>> getSalesDashboard(
    String startIso,
    String endIso,
  ) => database.reportsDao.getSalesDashboard(startIso, endIso);

  @override
  Future<List<Map<String, dynamic>>> getMenuItemSalesReport(
    String startIso,
    String endIso, {
    String? itemName,
  }) => database.reportsDao.getMenuItemSalesReport(
    startIso,
    endIso,
    itemName: itemName,
  );

  @override
  Future<List<Map<String, dynamic>>> getInventoryStockReport() =>
      database.reportsDao.getInventoryStockReport();

  @override
  Future<List<Map<String, dynamic>>> getPurchaseSummaryReport(
    String startIso,
    String endIso,
  ) => database.reportsDao.getPurchaseSummaryReport(startIso, endIso);

  @override
  Future<List<Map<String, dynamic>>> getExpenditureSummaryReport(
    String startIso,
    String endIso,
  ) => database.reportsDao.getExpenditureSummaryReport(startIso, endIso);
}
