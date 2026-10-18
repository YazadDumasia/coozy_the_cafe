import '../../domain/entities/daily_sales_entry.dart';
import '../../domain/entities/sales_trend_entry.dart';
import '../../domain/entities/menu_item_sales_entry.dart';
import '../../domain/entities/monthly_sales_entry.dart';
import '../../domain/entities/top_item_entry.dart';
import '../../domain/entities/payment_mode_entry.dart';
import '../../domain/entities/sales_dashboard.dart';
import '../../domain/entities/inventory_stock_entry.dart';
import '../../domain/entities/purchase_summary_entry.dart';
import '../../domain/entities/expenditure_summary_entry.dart';
import '../../domain/entities/stock_adjustment_entry.dart';
import '../../domain/entities/demand_insights.dart';
import '../../domain/utils/offline_forecasting_engine.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_local_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl({required this.localDataSource});
  final ReportsLocalDataSource localDataSource;

  @override
  Future<List<SalesTrendEntry>> getSalesTrendsReport(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) async {
    final maps = await localDataSource.getSalesTrendsReport(
      startIso,
      endIso,
      format: format.sqlFormat,
    );
    return maps.map(SalesTrendEntry.fromMap).toList();
  }

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
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) async {
    final maps = await localDataSource.getMenuItemSalesReport(
      startIso,
      endIso,
      itemName: itemName,
      format: format.sqlFormat,
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
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) async {
    final maps = await localDataSource.getPurchaseSummaryReport(
      startIso,
      endIso,
      format: format.sqlFormat,
    );
    return maps.map(PurchaseSummaryEntry.fromMap).toList();
  }

  @override
  Future<List<ExpenditureSummaryEntry>> getExpenditureSummaryReport(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) async {
    final maps = await localDataSource.getExpenditureSummaryReport(
      startIso,
      endIso,
      format: format.sqlFormat,
    );
    return maps.map(ExpenditureSummaryEntry.fromMap).toList();
  }

  @override
  Future<List<StockAdjustmentEntry>> getStockAdjustmentsReport(
    String startIso,
    String endIso, {
    SalesPeriodFormat format = SalesPeriodFormat.daily,
  }) async {
    final maps = await localDataSource.getStockAdjustmentsReport(
      startIso,
      endIso,
      format: format.sqlFormat,
    );
    return maps.map(StockAdjustmentEntry.fromMap).toList();
  }

  @override
  Future<AiDemandInsights> getAiDemandInsights({
    required String startIso,
    required String endIso,
  }) async {
    const engine = OfflineForecastingEngine();

    // 1. Fetch historical sales & orders for trend forecasting
    final salesHistory =
        await localDataSource.getDailySalesHistoryForForecast(
          startIso: startIso,
          endIso: endIso,
        );

    // 2. Fetch hourly orders distribution
    final hourlyDistribution =
        await localDataSource.getHourlyOrderDistribution(
          startIso: startIso,
          endIso: endIso,
        );

    // 3. Fetch current inventory & consumption rates
    final currentInventory = await localDataSource.getInventoryStockReport();
    final recentConsumption =
        await localDataSource.getRecentInventoryConsumption(
          startIso: startIso,
          endIso: endIso,
        );

    // 4. Fetch menu engineering popularity vs margin raw data
    final menuRawData = await localDataSource.getMenuEngineeringRawData(
      startIso: startIso,
      endIso: endIso,
    );

    // Compute forecasting & predictions
    final salesForecasts = engine.predictSales(salesHistory, forecastDays: 7);
    final hourlyDemands = engine.analyzeHourlyDemand(hourlyDistribution);
    final depletionForecasts = engine.forecastDepletion(
      currentInventory: currentInventory,
      recentConsumption: recentConsumption,
    );
    final menuMatrix = engine.computeMenuEngineering(menuRawData);

    final expectedTomorrow =
        salesForecasts.isNotEmpty ? salesForecasts.first.predictedSales : 0.0;

    double growthTrend = 0.0;
    if (salesHistory.length >= 2) {
      final firstHalf = salesHistory.take(salesHistory.length ~/ 2);
      final secondHalf = salesHistory.skip(salesHistory.length ~/ 2);
      final firstAvg =
          firstHalf.fold<double>(
            0.0,
            (acc, el) => acc + (el['sales'] as num).toDouble(),
          ) /
          firstHalf.length;
      final secondAvg =
          secondHalf.fold<double>(
            0.0,
            (acc, el) => acc + (el['sales'] as num).toDouble(),
          ) /
          secondHalf.length;
      if (firstAvg > 0) {
        growthTrend = ((secondAvg - firstAvg) / firstAvg) * 100;
      }
    }

    return AiDemandInsights(
      salesForecasts: salesForecasts,
      hourlyDemands: hourlyDemands,
      depletionForecasts: depletionForecasts,
      menuMatrixItems: menuMatrix,
      expectedTomorrowSales: double.parse(expectedTomorrow.toStringAsFixed(2)),
      growthTrendPercentage: double.parse(growthTrend.toStringAsFixed(1)),
    );
  }
}

