import '../../domain/entities/daily_sales_entry.dart';
import '../../domain/entities/menu_item_sales_entry.dart';
import '../../domain/entities/monthly_sales_entry.dart';
import '../../domain/entities/top_item_entry.dart';
import '../../domain/entities/payment_mode_entry.dart';
import '../../domain/entities/sales_dashboard.dart';
import '../../domain/entities/inventory_stock_entry.dart';
import '../../domain/entities/purchase_summary_entry.dart';
import '../../domain/entities/expenditure_summary_entry.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl({required this.localDataSource});
  final ReportsLocalDataSource localDataSource;

  @override
  Future<List<DailySalesEntry>> getDailySalesSummary(
    String startIso,
    String endIso,
  ) async {
    final maps = await localDataSource.getDailySalesSummary(startIso, endIso);
    return maps.map(DailySalesEntry.fromMap).toList();
  }

  @override
  Future<List<MonthlySalesEntry>> getMonthlySalesSummary(
    String startIso,
    String endIso,
  ) async {
    final maps = await localDataSource.getMonthlySalesSummary(startIso, endIso);
    return maps.map(MonthlySalesEntry.fromMap).toList();
  }

  @override
  Future<List<TopItemEntry>> getTopSellingItems(
    String startIso,
    String endIso, {
    int limit = 10,
  }) async {
    final maps = await localDataSource.getTopSellingItems(
      startIso,
      endIso,
      limit: limit,
    );
    return maps.map(TopItemEntry.fromMap).toList();
  }

  @override
  Future<List<PaymentModeEntry>> getPaymentModeReport(
    String startIso,
    String endIso,
  ) async {
    final maps = await localDataSource.getPaymentModeReport(startIso, endIso);
    return maps.map(PaymentModeEntry.fromMap).toList();
  }

  @override
  Future<SalesDashboard> getSalesDashboard(
    String startIso,
    String endIso,
  ) async {
    final map = await localDataSource.getSalesDashboard(startIso, endIso);
    if (map.isEmpty) return SalesDashboard.empty();
    return SalesDashboard.fromMap(map);
  }

  @override
  Future<List<MenuItemSalesEntry>> getMenuItemSalesReport(
    String startIso,
    String endIso, {
    String? itemName,
  }) async {
    final maps = await localDataSource.getMenuItemSalesReport(
      startIso,
      endIso,
      itemName: itemName,
    );
    return maps.map(MenuItemSalesEntry.fromMap).toList();
  }

  @override
  Future<List<InventoryStockEntry>> getInventoryStockReport() async {
    final maps = await localDataSource.getInventoryStockReport();
    return maps.map(InventoryStockEntry.fromMap).toList();
  }

  @override
  Future<List<PurchaseSummaryEntry>> getPurchaseSummaryReport(
    String startIso,
    String endIso,
  ) async {
    final maps = await localDataSource.getPurchaseSummaryReport(
      startIso,
      endIso,
    );
    return maps.map(PurchaseSummaryEntry.fromMap).toList();
  }

  @override
  Future<List<ExpenditureSummaryEntry>> getExpenditureSummaryReport(
    String startIso,
    String endIso,
  ) async {
    final maps = await localDataSource.getExpenditureSummaryReport(
      startIso,
      endIso,
    );
    return maps.map(ExpenditureSummaryEntry.fromMap).toList();
  }
}
