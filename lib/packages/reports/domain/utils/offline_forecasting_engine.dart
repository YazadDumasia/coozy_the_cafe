import 'dart:math' as math;
import '../entities/demand_insights.dart';

/// Pure offline forecasting analytics using Double Exponential Smoothing (Holt's Linear Trend)
/// and Moving Averages, runnable in background isolates.
class OfflineForecastingEngine {
  const OfflineForecastingEngine();

  /// Predict future [forecastDays] sales based on historical daily sales [historicalSales].
  List<SalesForecastPoint> predictSales(
    List<Map<String, dynamic>> historicalSales, {
    int forecastDays = 7,
    double alpha = 0.35, // Level smoothing factor
    double beta = 0.2, // Trend smoothing factor
  }) {
    if (historicalSales.isEmpty) {
      final now = DateTime.now();
      return List.generate(forecastDays, (i) {
        final d = now.add(Duration(days: i + 1));
        final dateStr =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        return SalesForecastPoint(
          dateIso: dateStr,
          predictedSales: 0.0,
          predictedOrders: 0,
          lowerBound: 0.0,
          upperBound: 0.0,
        );
      });
    }

    // Sort ascending by date
    final sorted = List<Map<String, dynamic>>.from(historicalSales)
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

    final series = sorted.map((e) => (e['sales'] as num).toDouble()).toList();
    final orderSeries =
        sorted.map((e) => (e['orders'] as num).toDouble()).toList();

    // Holt's linear trend initial values
    double level = series.first;
    double trend = series.length > 1 ? series[1] - series[0] : 0.0;

    double orderLevel = orderSeries.first;
    double orderTrend =
        orderSeries.length > 1 ? orderSeries[1] - orderSeries[0] : 0.0;

    // Standard deviation for confidence interval
    double varianceSum = 0.0;

    for (int t = 1; t < series.length; t++) {
      final val = series[t];
      final prevLevel = level;
      level = alpha * val + (1 - alpha) * (prevLevel + trend);
      trend = beta * (level - prevLevel) + (1 - beta) * trend;

      final orderVal = orderSeries[t];
      final prevOrderLevel = orderLevel;
      orderLevel =
          alpha * orderVal + (1 - alpha) * (prevOrderLevel + orderTrend);
      orderTrend = beta * (orderLevel - prevOrderLevel) + (1 - beta) * orderTrend;

      final diff = val - (prevLevel + trend);
      varianceSum += diff * diff;
    }

    final stdDev =
        series.length > 1 ? math.sqrt(varianceSum / (series.length - 1)) : 0.0;

    // Generate forecast points
    final lastDateStr = sorted.last['date'] as String;
    DateTime lastDate = DateTime.tryParse(lastDateStr) ?? DateTime.now();

    final results = <SalesForecastPoint>[];
    for (int m = 1; m <= forecastDays; m++) {
      final futureDate = lastDate.add(Duration(days: m));
      final dateStr =
          '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';

      final projectedSales = math.max(0.0, level + m * trend);
      final projectedOrders = math.max(0, (orderLevel + m * orderTrend).round());

      // Margin of error expands into the future (confidence interval 80%)
      final errorMargin = 1.28 * stdDev * math.sqrt(m.toDouble());
      final lower = math.max(0.0, projectedSales - errorMargin);
      final upper = projectedSales + errorMargin;

      results.add(
        SalesForecastPoint(
          dateIso: dateStr,
          predictedSales: double.parse(projectedSales.toStringAsFixed(2)),
          predictedOrders: projectedOrders,
          lowerBound: double.parse(lower.toStringAsFixed(2)),
          upperBound: double.parse(upper.toStringAsFixed(2)),
        ),
      );
    }

    return results;
  }

  /// Analyze hourly demand distribution and peak hours from raw order timestamps
  List<HourlyDemandPoint> analyzeHourlyDemand(
    List<Map<String, dynamic>> hourlyRawData,
  ) {
    final Map<int, Map<String, dynamic>> map = {};
    for (int h = 0; h < 24; h++) {
      map[h] = {'hour': h, 'orders': 0, 'sales': 0.0};
    }

    int maxOrders = 0;
    for (final row in hourlyRawData) {
      final hour = (row['hour'] as num?)?.toInt() ?? 0;
      final orders = (row['orders'] as num?)?.toInt() ?? 0;
      final sales = (row['sales'] as num?)?.toDouble() ?? 0.0;
      if (hour >= 0 && hour < 24) {
        map[hour] = {'hour': hour, 'orders': orders, 'sales': sales};
        if (orders > maxOrders) {
          maxOrders = orders;
        }
      }
    }

    final threshold = maxOrders > 0 ? (maxOrders * 0.75).round() : 1;

    return List.generate(24, (h) {
      final d = map[h]!;
      final orders = d['orders'] as int;
      final sales = d['sales'] as double;
      return HourlyDemandPoint(
        hourOfDay: h,
        orderCount: orders,
        totalSales: sales,
        isPeakHour: orders >= threshold && orders > 0,
      );
    });
  }

  /// Forecast inventory stock depletion velocity
  List<StockDepletionForecast> forecastDepletion({
    required List<Map<String, dynamic>> currentInventory,
    required List<Map<String, dynamic>> recentConsumption,
    int daysAnalyzed = 14,
  }) {
    final Map<int, double> consumptionMap = {};
    for (final row in recentConsumption) {
      final invId = (row['inventoryId'] as num?)?.toInt();
      final qty = (row['consumedQty'] as num?)?.toDouble() ?? 0.0;
      if (invId != null) {
        consumptionMap[invId] = (consumptionMap[invId] ?? 0.0) + qty;
      }
    }

    final results = <StockDepletionForecast>[];

    for (final item in currentInventory) {
      final id = (item['id'] as num).toInt();
      final name = (item['name'] as String?) ?? 'Unknown Item';
      final stock = (item['currentStock'] as num?)?.toDouble() ?? 0.0;
      final unit = (item['purchaseUnit'] as String?) ?? 'units';

      final totalConsumed = consumptionMap[id] ?? 0.0;
      final dailyRate = totalConsumed / math.max(1, daysAnalyzed);

      final daysRemaining =
          dailyRate > 0 ? stock / dailyRate : (stock > 0 ? 999.0 : 0.0);

      results.add(
        StockDepletionForecast(
          inventoryId: id,
          inventoryName: name,
          currentStock: stock,
          unit: unit,
          dailyConsumptionRate: double.parse(dailyRate.toStringAsFixed(2)),
          estimatedDaysRemaining: double.parse(
            daysRemaining.toStringAsFixed(1),
          ),
          isUrgentReorder: daysRemaining <= 2.5 && stock >= 0,
        ),
      );
    }

    // Sort by urgent reorders first, then by days remaining ascending
    results.sort((a, b) {
      if (a.isUrgentReorder && !b.isUrgentReorder) return -1;
      if (!a.isUrgentReorder && b.isUrgentReorder) return 1;
      return a.estimatedDaysRemaining.compareTo(b.estimatedDaysRemaining);
    });

    return results;
  }

  /// Classify menu items via BCG Matrix (Popularity vs Profitability)
  List<MenuEngineeringItem> computeMenuEngineering(
    List<Map<String, dynamic>> itemSalesWithCost,
  ) {
    if (itemSalesWithCost.isEmpty) return [];

    double totalVolume = 0.0;
    double totalMarginSum = 0.0;
    int itemCount = 0;

    final parsedItems = <Map<String, dynamic>>[];

    for (final row in itemSalesWithCost) {
      final qty = (row['totalQuantity'] as num?)?.toInt() ?? 0;
      final revenue = (row['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      final totalCost = (row['totalCost'] as num?)?.toDouble() ?? 0.0;
      final unitPrice = qty > 0 ? revenue / qty : 0.0;
      final unitCost = qty > 0 ? totalCost / qty : 0.0;
      final unitMargin = unitPrice - unitCost;
      final marginPct = unitPrice > 0 ? (unitMargin / unitPrice) * 100 : 0.0;

      totalVolume += qty;
      totalMarginSum += unitMargin;
      itemCount++;

      parsedItems.add({
        'id': row['itemId'],
        'name': row['itemName'],
        'qty': qty,
        'revenue': revenue,
        'unitMargin': unitMargin,
        'marginPct': marginPct,
      });
    }

    final avgVolume = itemCount > 0 ? totalVolume / itemCount : 0.0;
    final avgMargin = itemCount > 0 ? totalMarginSum / itemCount : 0.0;

    return parsedItems.map((item) {
      final qty = item['qty'] as int;
      final margin = item['unitMargin'] as double;

      final isHighSales = qty >= avgVolume;
      final isHighMargin = margin >= avgMargin;

      MenuEngineeringCategory category;
      if (isHighSales && isHighMargin) {
        category = MenuEngineeringCategory.star;
      } else if (isHighSales && !isHighMargin) {
        category = MenuEngineeringCategory.plowhorse;
      } else if (!isHighSales && isHighMargin) {
        category = MenuEngineeringCategory.puzzle;
      } else {
        category = MenuEngineeringCategory.dog;
      }

      return MenuEngineeringItem(
        itemId: item['id'] as int,
        name: item['name'] as String,
        totalQuantitySold: qty,
        totalRevenue: item['revenue'] as double,
        unitMargin: double.parse(margin.toStringAsFixed(2)),
        marginPercentage: double.parse(
          (item['marginPct'] as double).toStringAsFixed(1),
        ),
        category: category,
      );
    }).toList();
  }
}
