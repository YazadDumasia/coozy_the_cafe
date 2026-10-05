import '../utils/report_date_utils.dart';
import 'sales_trend_entry.dart';

class MenuItemSalesEntry {
  const MenuItemSalesEntry({
    required this.itemName,
    String? saleDate,
    String? period,
    this.startDate,
    this.endDate,
    this.quantitySold = 0,
    this.totalAmount = 0.0,
    this.totalCost = 0.0,
    this.totalProfit = 0.0,
    this.profitPercentage,
  }) : period = period ?? saleDate ?? '',
       saleDate = saleDate ?? period ?? '';

  factory MenuItemSalesEntry.fromMap(Map<String, dynamic> map) {
    final rawPeriod = (map['period'] ?? map['saleDate']) as String? ?? '';
    return MenuItemSalesEntry(
      itemName: map['itemName'] as String? ?? '',
      saleDate: rawPeriod,
      period: rawPeriod,
      startDate: map['startDate'] as String?,
      endDate: map['endDate'] as String?,
      quantitySold: (map['quantitySold'] as num?)?.toInt() ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
      totalProfit: (map['totalProfit'] as num?)?.toDouble() ?? 0.0,
      profitPercentage: (map['profitPercentage'] as num?)?.toDouble(),
    );
  }

  final String itemName;
  final String saleDate;
  final String period;
  final String? startDate;
  final String? endDate;
  final int quantitySold;
  final double totalAmount;
  final double totalCost;
  final double totalProfit;
  final double? profitPercentage;

  (DateTime, DateTime)? get weekRange => ReportDateUtils.resolveWeekRange(
    startDate: startDate,
    endDate: endDate,
    period: period,
  );

  String formattedPeriod(SalesPeriodFormat format) =>
      ReportDateUtils.formatPeriod(
        period: period,
        format: format,
        startDate: startDate,
        endDate: endDate,
      );

  String chartLabel(SalesPeriodFormat format) =>
      ReportDateUtils.formatChartLabel(
        period: period,
        format: format,
        startDate: startDate,
        endDate: endDate,
      );
}
