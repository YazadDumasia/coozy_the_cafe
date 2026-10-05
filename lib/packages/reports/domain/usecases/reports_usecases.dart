import '../entities/daily_sales_entry.dart';
import '../entities/sales_trend_entry.dart';
import '../entities/menu_item_sales_entry.dart';
import '../entities/monthly_sales_entry.dart';
import '../entities/top_item_entry.dart';
import '../entities/payment_mode_entry.dart';
import '../entities/sales_dashboard.dart';
import '../entities/inventory_stock_entry.dart';
import '../entities/purchase_summary_entry.dart';
import '../entities/expenditure_summary_entry.dart';
import '../entities/stock_adjustment_entry.dart';
import '../repositories/reports_repository.dart';

class GetSalesTrendsReportUseCase {
  GetSalesTrendsReportUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<SalesTrendEntry>> call(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) => repository.getSalesTrendsReport(startIso, endIso, format: format);
}

class GetDailySalesSummaryUseCase {
  GetDailySalesSummaryUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<DailySalesEntry>> call(String startIso, String endIso) =>
      repository.getDailySalesSummary(startIso, endIso);
}

class GetMonthlySalesSummaryUseCase {
  GetMonthlySalesSummaryUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<MonthlySalesEntry>> call(String startIso, String endIso) =>
      repository.getMonthlySalesSummary(startIso, endIso);
}

class GetTopSellingItemsUseCase {
  GetTopSellingItemsUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<TopItemEntry>> call(
    String startIso,
    String endIso, {
    int limit = 10,
  }) => repository.getTopSellingItems(startIso, endIso, limit: limit);
}

class GetPaymentModeReportUseCase {
  GetPaymentModeReportUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<PaymentModeEntry>> call(String startIso, String endIso) =>
      repository.getPaymentModeReport(startIso, endIso);
}

class GetSalesDashboardUseCase {
  GetSalesDashboardUseCase(this.repository);
  final ReportsRepository repository;

  Future<SalesDashboard> call(String startIso, String endIso) =>
      repository.getSalesDashboard(startIso, endIso);
}

class GetMenuItemSalesReportUseCase {
  GetMenuItemSalesReportUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<MenuItemSalesEntry>> call(
    String startIso,
    String endIso, {
    String? itemName,
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) => repository.getMenuItemSalesReport(
    startIso,
    endIso,
    itemName: itemName,
    format: format,
  );
}

class GetInventoryStockReportUseCase {
  GetInventoryStockReportUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<InventoryStockEntry>> call() =>
      repository.getInventoryStockReport();
}

class GetPurchaseSummaryReportUseCase {
  GetPurchaseSummaryReportUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<PurchaseSummaryEntry>> call(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) => repository.getPurchaseSummaryReport(startIso, endIso, format: format);
}

class GetExpenditureSummaryReportUseCase {
  GetExpenditureSummaryReportUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<ExpenditureSummaryEntry>> call(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) =>
      repository.getExpenditureSummaryReport(startIso, endIso, format: format);
}

class GetStockAdjustmentsReportUseCase {
  GetStockAdjustmentsReportUseCase(this.repository);
  final ReportsRepository repository;

  Future<List<StockAdjustmentEntry>> call(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) => repository.getStockAdjustmentsReport(startIso, endIso, format: format);
}
