import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../domain/entities/inventory_stock_entry.dart';

class InventoryStockBarChart extends StatelessWidget {
  const InventoryStockBarChart({super.key, required this.entries});
  final List<InventoryStockEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No inventory items found',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }
    // Take top 15 items by lowest stock to highlight items needing restock
    final display = entries.take(15).toList();
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.fromLTRB(12, 16, 16, 16),
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
        ColumnSeries<InventoryStockEntry, String>(
          name: 'Current Stock',
          dataSource: display,
          xValueMapper: (InventoryStockEntry e, _) => e.name,
          yValueMapper: (InventoryStockEntry e, _) => e.currentStock,
          dataLabelMapper: (InventoryStockEntry e, _) =>
              e.currentStock == e.currentStock.toInt()
              ? '${e.currentStock.toInt()}'
              : '${e.currentStock}',
          pointColorMapper: (InventoryStockEntry e, _) =>
              e.currentStock <= 5 ? Colors.red : scheme.primary,
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
