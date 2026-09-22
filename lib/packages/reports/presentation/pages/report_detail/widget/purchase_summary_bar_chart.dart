import 'package:flutter/material.dart';
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    final display = entries.take(12).toList();
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<PurchaseSummaryEntry, String>(
          name: 'Total Spent',
          dataSource: display,
          xValueMapper: (PurchaseSummaryEntry e, _) => e.itemName,
          yValueMapper: (PurchaseSummaryEntry e, _) => e.totalCost,
          color: Colors.deepOrange,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(color: scheme.onSurface, fontSize: 9),
          ),
        ),
        ColumnSeries<PurchaseSummaryEntry, String>(
          name: 'Qty Bought',
          dataSource: display,
          xValueMapper: (PurchaseSummaryEntry e, _) => e.itemName,
          yValueMapper: (PurchaseSummaryEntry e, _) => e.totalQty,
          color: scheme.primary.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
