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

abstract class ReportsRepository {
  Future<List<SalesTrendEntry>> getSalesTrendsReport(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  });

  Future<List<DailySalesEntry>> getDailySalesSummary(
    String startIso,
    String endIso,
  );

  Future<List<MonthlySalesEntry>> getMonthlySalesSummary(
    String startIso,
    String endIso,
  );

  Future<List<TopItemEntry>> getTopSellingItems(
    String startIso,
    String endIso, {
    int limit,
  });

  Future<List<PaymentModeEntry>> getPaymentModeReport(
    String startIso,
    String endIso,
  );

  Future<SalesDashboard> getSalesDashboard(String startIso, String endIso);

  Future<List<MenuItemSalesEntry>> getMenuItemSalesReport(
    String startIso,
    String endIso, {
    String? itemName,
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  });

  Future<List<InventoryStockEntry>> getInventoryStockReport();

  Future<List<PurchaseSummaryEntry>> getPurchaseSummaryReport(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  });

  Future<List<ExpenditureSummaryEntry>> getExpenditureSummaryReport(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  });

  Future<List<StockAdjustmentEntry>> getStockAdjustmentsReport(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  });
}
