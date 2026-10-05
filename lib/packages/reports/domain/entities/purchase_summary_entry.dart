import '../utils/report_date_utils.dart';
import 'sales_trend_entry.dart';

class PurchaseSummaryEntry {
  const PurchaseSummaryEntry({
    required this.itemName,
    this.purchaseUnit = '',
    this.period = '',
    this.startDate,
    this.endDate,
    this.totalQty = 0.0,
    this.totalCost = 0.0,
  });

  factory PurchaseSummaryEntry.fromMap(Map<String, dynamic> map) {
    return PurchaseSummaryEntry(
      itemName: map['itemName'] as String? ?? '',
      purchaseUnit: map['purchaseUnit'] as String? ?? '',
      period: map['period'] as String? ?? '',
      startDate: map['startDate'] as String?,
      endDate: map['endDate'] as String?,
      totalQty: (map['totalQty'] as num?)?.toDouble() ?? 0.0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final String itemName;
  final String purchaseUnit;
  final String period;
  final String? startDate;
  final String? endDate;
  final double totalQty;
  final double totalCost;

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
