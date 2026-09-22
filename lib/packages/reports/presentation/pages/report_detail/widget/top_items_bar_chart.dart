import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../domain/entities/top_item_entry.dart';

class TopItemsBarChart extends StatelessWidget {
  const TopItemsBarChart({super.key, required this.items});
  final List<TopItemEntry> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No data for selected range',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    // Show top 10 max for readability
    final display = items.take(10).toList();
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
      ),
      primaryYAxis: CategoryAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        BarSeries<TopItemEntry, String>(
          name: 'Qty Sold',
          dataSource: display,
          xValueMapper: (TopItemEntry e, _) => e.itemName,
          yValueMapper: (TopItemEntry e, _) => e.totalQuantity,
          color: scheme.secondary,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(6),
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: scheme.onSurface, fontSize: 9),
          ),
        ),
      ],
    );
  }
}
