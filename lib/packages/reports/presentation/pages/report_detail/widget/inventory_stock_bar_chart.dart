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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    // Take top 15 items by lowest stock to highlight items needing restock
    final display = entries.take(15).toList();
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<InventoryStockEntry, String>(
          name: 'Current Stock',
          dataSource: display,
          xValueMapper: (InventoryStockEntry e, _) => e.name,
          yValueMapper: (InventoryStockEntry e, _) => e.currentStock,
          pointColorMapper: (InventoryStockEntry e, _) =>
              e.currentStock <= 5 ? Colors.red : scheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(color: scheme.onSurface, fontSize: 9),
          ),
        ),
      ],
    );
  }
}
