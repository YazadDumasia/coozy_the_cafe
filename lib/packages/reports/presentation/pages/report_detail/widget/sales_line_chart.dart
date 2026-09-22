import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../domain/entities/daily_sales_entry.dart';

class SalesLineChart extends StatelessWidget {
  const SalesLineChart({super.key, required this.entries});
  final List<DailySalesEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No data for selected range',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    // Reverse so oldest date appears on the left
    final ordered = entries.reversed.toList();
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        numberFormat: NumberFormat.compactCurrency(symbol: ''),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        SplineAreaSeries<DailySalesEntry, String>(
          name: 'Net Sales',
          dataSource: ordered,
          xValueMapper: (DailySalesEntry e, _) => _shortDate(e.saleDate),
          yValueMapper: (DailySalesEntry e, _) => e.netTotal,
          color: scheme.primary.withValues(alpha: 0.3),
          borderColor: scheme.primary,
          borderWidth: 2,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: scheme.primary,
            borderColor: scheme.primary,
          ),
        ),
        SplineSeries<DailySalesEntry, String>(
          name: 'Profit',
          dataSource: ordered,
          xValueMapper: (DailySalesEntry e, _) => _shortDate(e.saleDate),
          yValueMapper: (DailySalesEntry e, _) => e.dailyProfit,
          color: Colors.green,
          width: 2,
          markerSettings: const MarkerSettings(
            isVisible: true,
            color: Colors.green,
            borderColor: Colors.green,
          ),
        ),
      ],
    );
  }

  String _shortDate(String iso) {
    if (iso.length < 10) return iso;
    final parts = iso.substring(0, 10).split('-');
    if (parts.length < 3) return iso;
    return '${parts[2]}/${parts[1]}';
  }
}
