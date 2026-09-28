import '../utils/report_date_utils.dart';
import 'sales_trend_entry.dart';

class ExpenditureSummaryEntry {
  const ExpenditureSummaryEntry({
    required this.type,
    required this.categoryName,
    this.period = '',
    this.startDate,
    this.endDate,
    this.totalAmount = 0.0,
    this.transactionCount = 0,
  });

  factory ExpenditureSummaryEntry.fromMap(Map<String, dynamic> map) {
    return ExpenditureSummaryEntry(
      type: map['type'] as String? ?? 'EXPENSE',
      categoryName: map['categoryName'] as String? ?? 'General',
      period: map['period'] as String? ?? '',
      startDate: map['startDate'] as String?,
      endDate: map['endDate'] as String?,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (map['transactionCount'] as num?)?.toInt() ?? 0,
    );
  }

  final String type; // 'EXPENSE' or 'INCOME'
  final String categoryName;
  final String period;
  final String? startDate;
  final String? endDate;
  final double totalAmount;
  final int transactionCount;

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
