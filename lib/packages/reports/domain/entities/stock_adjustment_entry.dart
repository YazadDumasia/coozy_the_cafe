import '../utils/report_date_utils.dart';
import 'sales_trend_entry.dart';

class StockAdjustmentEntry {
  const StockAdjustmentEntry({
    required this.id,
    this.hashId = '',
    this.inventoryId,
    this.inventoryName = '',
    this.adjustmentType = '',
    this.adjustedQty = 0.0,
    this.previousStock = 0.0,
    this.newStock = 0.0,
    this.reason = '',
    this.createdDate = '',
    this.period = '',
    this.startDate,
    this.endDate,
  });

  factory StockAdjustmentEntry.fromMap(Map<String, dynamic> map) {
    final cDate = map['createdDate'] as String? ?? '';
    final rawPeriod = map['period'] as String? ?? cDate;
    return StockAdjustmentEntry(
      id: (map['id'] as num?)?.toInt() ?? 0,
      hashId: map['hashId'] as String? ?? '',
      inventoryId: (map['inventoryId'] as num?)?.toInt(),
      inventoryName: map['inventoryName'] as String? ?? '',
      adjustmentType: map['adjustmentType'] as String? ?? '',
      adjustedQty: (map['adjustedQty'] as num?)?.toDouble() ?? 0.0,
      previousStock: (map['previousStock'] as num?)?.toDouble() ?? 0.0,
      newStock: (map['newStock'] as num?)?.toDouble() ?? 0.0,
      reason: map['reason'] as String? ?? '',
      createdDate: cDate,
      period: rawPeriod,
      startDate: map['startDate'] as String?,
      endDate: map['endDate'] as String?,
    );
  }

  final int id;
  final String hashId;
  final int? inventoryId;
  final String inventoryName;
  final String adjustmentType; // 'add' or 'remove'
  final double adjustedQty;
  final double previousStock;
  final double newStock;
  final String reason;
  final String createdDate;
  final String period;
  final String? startDate;
  final String? endDate;

  bool get isAddition => adjustmentType.toLowerCase() == 'add';

  (DateTime, DateTime)? get weekRange => ReportDateUtils.resolveWeekRange(
        startDate: startDate,
        endDate: endDate,
        period: period.isNotEmpty ? period : createdDate,
      );

  String formattedPeriod(SalesPeriodFormat format) =>
      ReportDateUtils.formatPeriod(
        period: period.isNotEmpty ? period : createdDate,
        format: format,
        startDate: startDate,
        endDate: endDate,
      );

  String chartLabel(SalesPeriodFormat format) =>
      ReportDateUtils.formatChartLabel(
        period: period.isNotEmpty ? period : createdDate,
        format: format,
        startDate: startDate,
        endDate: endDate,
      );
}
