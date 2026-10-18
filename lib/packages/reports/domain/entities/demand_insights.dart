class SalesForecastPoint {
  const SalesForecastPoint({
    required this.dateIso,
    required this.predictedSales,
    required this.predictedOrders,
    required this.lowerBound,
    required this.upperBound,
  });

  final String dateIso;
  final double predictedSales;
  final int predictedOrders;
  final double lowerBound;
  final double upperBound;

  Map<String, dynamic> toMap() => {
    'dateIso': dateIso,
    'predictedSales': predictedSales,
    'predictedOrders': predictedOrders,
    'lowerBound': lowerBound,
    'upperBound': upperBound,
  };
}

class HourlyDemandPoint {
  const HourlyDemandPoint({
    required this.hourOfDay,
    required this.orderCount,
    required this.totalSales,
    required this.isPeakHour,
  });

  final int hourOfDay; // 0..23
  final int orderCount;
  final double totalSales;
  final bool isPeakHour;

  String get timeLabel {
    final hour = hourOfDay % 12 == 0 ? 12 : hourOfDay % 12;
    final amPm = hourOfDay < 12 ? 'AM' : 'PM';
    return '$hour $amPm';
  }
}

class StockDepletionForecast {
  const StockDepletionForecast({
    required this.inventoryId,
    required this.inventoryName,
    required this.currentStock,
    required this.unit,
    required this.dailyConsumptionRate,
    required this.estimatedDaysRemaining,
    required this.isUrgentReorder,
  });

  final int inventoryId;
  final String inventoryName;
  final double currentStock;
  final String unit;
  final double dailyConsumptionRate;
  final double estimatedDaysRemaining;
  final bool isUrgentReorder; // <= 2 days
}

enum MenuEngineeringCategory {
  star, // High profit, high sales
  plowhorse, // Low profit, high sales (popular workhorse)
  puzzle, // High profit, low sales (niche/gem)
  dog, // Low profit, low sales (reconsider/remove)
}

class MenuEngineeringItem {
  const MenuEngineeringItem({
    required this.itemId,
    required this.name,
    required this.totalQuantitySold,
    required this.totalRevenue,
    required this.unitMargin,
    required this.marginPercentage,
    required this.category,
  });

  final int itemId;
  final String name;
  final int totalQuantitySold;
  final double totalRevenue;
  final double unitMargin;
  final double marginPercentage;
  final MenuEngineeringCategory category;
}

class DemandInsights {
  const DemandInsights({
    required this.salesForecasts,
    required this.hourlyDemands,
    required this.depletionForecasts,
    required this.menuMatrixItems,
    required this.expectedTomorrowSales,
    required this.growthTrendPercentage,
  });

  final List<SalesForecastPoint> salesForecasts;
  final List<HourlyDemandPoint> hourlyDemands;
  final List<StockDepletionForecast> depletionForecasts;
  final List<MenuEngineeringItem> menuMatrixItems;
  final double expectedTomorrowSales;
  final double growthTrendPercentage;
}

typedef AiDemandInsights = DemandInsights;
