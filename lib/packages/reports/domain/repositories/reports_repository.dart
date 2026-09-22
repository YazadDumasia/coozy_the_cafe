import '../entities/daily_sales_entry.dart';
import '../entities/menu_item_sales_entry.dart';
import '../entities/monthly_sales_entry.dart';
import '../entities/top_item_entry.dart';
import '../entities/payment_mode_entry.dart';
import '../entities/sales_dashboard.dart';
import '../entities/inventory_stock_entry.dart';
import '../entities/purchase_summary_entry.dart';
import '../entities/expenditure_summary_entry.dart';

abstract class ReportsRepository {
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
  });

  Future<List<InventoryStockEntry>> getInventoryStockReport();

  Future<List<PurchaseSummaryEntry>> getPurchaseSummaryReport(
    String startIso,
    String endIso,
  );

  Future<List<ExpenditureSummaryEntry>> getExpenditureSummaryReport(
    String startIso,
    String endIso,
  );
}
