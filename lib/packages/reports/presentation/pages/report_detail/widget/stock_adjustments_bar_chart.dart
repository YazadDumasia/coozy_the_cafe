import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../domain/entities/stock_adjustment_entry.dart';

class StockAdjustmentsBarChart extends StatelessWidget {
  const StockAdjustmentsBarChart({super.key, required this.entries});
  final List<StockAdjustmentEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No stock adjustments found for the selected range',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    // Aggregate total additions and total deductions per inventory item
    final Map<String, _AggregatedAdjustment> itemMap = {};
    for (final e in entries) {
      final name = e.inventoryName.isNotEmpty
          ? e.inventoryName
          : 'Item #${e.inventoryId ?? e.id}';
      final current = itemMap.putIfAbsent(
        name,
        () => _AggregatedAdjustment(name: name),
      );
      if (e.isAddition) {
        current.addedQty += e.adjustedQty;
      } else {
        current.removedQty += e.adjustedQty;
      }
    }

    // Sort by largest net volume of adjustments and take top 15
    final display = itemMap.values.toList()
      ..sort((a, b) =>
          (b.addedQty + b.removedQty).compareTo(a.addedQty + a.removedQty));
    final chartData = display.take(15).toList();

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
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
        majorGridLines: MajorGridLines(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          dashArray: const <double>[4, 4],
        ),
      ),
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
        ColumnSeries<_AggregatedAdjustment, String>(
          name: 'Added Stock',
          dataSource: chartData,
          xValueMapper: (_AggregatedAdjustment a, _) => a.name,
          yValueMapper: (_AggregatedAdjustment a, _) => a.addedQty,
          dataLabelMapper: (_AggregatedAdjustment a, _) => a.addedQty > 0
              ? (a.addedQty == a.addedQty.toInt()
                  ? '${a.addedQty.toInt()}'
                  : '${a.addedQty}')
              : '',
          color: Colors.green,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
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
        ColumnSeries<_AggregatedAdjustment, String>(
          name: 'Removed / Waste Stock',
          dataSource: chartData,
          xValueMapper: (_AggregatedAdjustment a, _) => a.name,
          yValueMapper: (_AggregatedAdjustment a, _) => a.removedQty,
          dataLabelMapper: (_AggregatedAdjustment a, _) => a.removedQty > 0
              ? (a.removedQty == a.removedQty.toInt()
                  ? '${a.removedQty.toInt()}'
                  : '${a.removedQty}')
              : '',
          color: Colors.orange,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
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

class _AggregatedAdjustment {
  _AggregatedAdjustment({required this.name});

  final String name;
  double addedQty = 0.0;
  double removedQty = 0.0;
}
