import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../domain/entities/purchase_summary_entry.dart';

class PurchaseSummaryBarChart extends StatelessWidget {
  const PurchaseSummaryBarChart({super.key, required this.entries});
  final List<PurchaseSummaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No purchases recorded in this date range',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }
    final Map<String, PurchaseSummaryEntry> aggregated = {};
    for (final e in entries) {
      if (aggregated.containsKey(e.itemName)) {
        final existing = aggregated[e.itemName]!;
        aggregated[e.itemName] = PurchaseSummaryEntry(
          itemName: e.itemName,
          purchaseUnit: e.purchaseUnit,
          totalQty: existing.totalQty + e.totalQty,
          totalCost: existing.totalCost + e.totalCost,
          period: e.period,
          startDate: e.startDate,
          endDate: e.endDate,
        );
      } else {
        aggregated[e.itemName] = e;
      }
    }
    final sorted = aggregated.values.toList()
      ..sort((a, b) => b.totalCost.compareTo(a.totalCost));
    final display = sorted.take(12).toList();
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        majorGridLines: const MajorGridLines(width: 0),
        labelRotation: -30,
        maximumLabelWidth: 140,
        labelIntersectAction: AxisLabelIntersectAction.none,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        numberFormat: NumberFormat.compactCurrency(symbol: ''),
        majorGridLines: MajorGridLines(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          dashArray: const <double>[4, 4],
        ),
      ),
      axes: <ChartAxis>[
        NumericAxis(
          name: 'qtyAxis',
          opposedPosition: true,
          minimum: 0,
          labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
          majorGridLines: const MajorGridLines(width: 0),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
        enableMouseWheelZooming: true,
        enableSelectionZooming: true,
        zoomMode: ZoomMode.x,
      ),
      series: <CartesianSeries>[
        ColumnSeries<PurchaseSummaryEntry, String>(
          name: 'Total Spent',
          dataSource: display,
          xValueMapper: (PurchaseSummaryEntry e, _) => e.itemName,
          yValueMapper: (PurchaseSummaryEntry e, _) => e.totalCost,
          dataLabelMapper: (PurchaseSummaryEntry e, _) =>
              NumberFormat.compactCurrency(symbol: '')
                  .format(e.totalCost)
                  .trim(),
          color: Colors.deepOrange,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ColumnSeries<PurchaseSummaryEntry, String>(
          name: 'Qty Bought',
          yAxisName: 'qtyAxis',
          dataSource: display,
          xValueMapper: (PurchaseSummaryEntry e, _) => e.itemName,
          yValueMapper: (PurchaseSummaryEntry e, _) => e.totalQty,
          dataLabelMapper: (PurchaseSummaryEntry e, _) =>
              e.totalQty == e.totalQty.toInt()
              ? '${e.totalQty.toInt()}'
              : '${e.totalQty}',
          color: scheme.primary.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
