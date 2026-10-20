import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'report_empty_view.dart';
import '../../../../domain/entities/daily_sales_entry.dart';

class SalesLineChart extends StatelessWidget {
  const SalesLineChart({super.key, required this.entries});
  final List<DailySalesEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const ReportEmptyView();
    }
    final scheme = Theme.of(context).colorScheme;
    // Reverse so oldest date appears on the left
    final ordered = entries.reversed.toList();
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0),
        maximumLabelWidth: 120,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        numberFormat: NumberFormat.compactCurrency(symbol: ''),
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
