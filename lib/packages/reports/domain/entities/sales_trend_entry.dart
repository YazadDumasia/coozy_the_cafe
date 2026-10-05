import '../utils/report_date_utils.dart';

enum SalesPeriodFormat {
  daily,
  weekly,
  monthly,
  yearly;

  String get sqlFormat {
    switch (this) {
      case SalesPeriodFormat.daily:
        return 'daily';
      case SalesPeriodFormat.weekly:
        return 'weekly';
      case SalesPeriodFormat.monthly:
        return 'monthly';
      case SalesPeriodFormat.yearly:
        return 'yearly';
    }
  }
}

class SalesTrendEntry {
  const SalesTrendEntry({
    required this.period,
    this.startDate,
    this.endDate,
    this.totalInvoices = 0,
    this.totalSales = 0,
    this.totalTax = 0,
    this.totalDiscount = 0,
    this.netTotal = 0,
    this.totalCost = 0,
    this.totalProfit = 0,
    this.profitPercentage,
  });

  factory SalesTrendEntry.fromMap(Map<String, dynamic> map) {
    return SalesTrendEntry(
      period: map['period'] as String? ?? '',
      startDate: map['startDate'] as String?,
      endDate: map['endDate'] as String?,
      totalInvoices: (map['totalInvoices'] as num?)?.toInt() ?? 0,
      totalSales: (map['totalSales'] as num?)?.toDouble() ?? 0,
      totalTax: (map['totalTax'] as num?)?.toDouble() ?? 0,
      totalDiscount: (map['totalDiscount'] as num?)?.toDouble() ?? 0,
      netTotal: (map['netTotal'] as num?)?.toDouble() ?? 0,
      totalCost: (map['totalCost'] as num?)?.toDouble() ?? 0,
      totalProfit: (map['totalProfit'] as num?)?.toDouble() ?? 0,
      profitPercentage: (map['profitPercentage'] as num?)?.toDouble(),
    );
  }

  final String period;
  final String? startDate;
  final String? endDate;
  final int totalInvoices;
  final double totalSales;
  final double totalTax;
  final double totalDiscount;
  final double netTotal;
  final double totalCost;
  final double totalProfit;
  final double? profitPercentage;

  /// Resolves the starting and ending date for a weekly period.
  (DateTime, DateTime)? get weekRange => ReportDateUtils.resolveWeekRange(
    startDate: startDate,
    endDate: endDate,
    period: period,
  );

  /// Human-readable period string for tabular view and export reports.
  String formattedPeriod(SalesPeriodFormat format) =>
      ReportDateUtils.formatPeriod(
        period: period,
        format: format,
        startDate: startDate,
        endDate: endDate,
      );

  /// Short period label for chart axis and tooltips.
  String chartLabel(SalesPeriodFormat format) =>
      ReportDateUtils.formatChartLabel(
        period: period,
        format: format,
        startDate: startDate,
        endDate: endDate,
      );
}
