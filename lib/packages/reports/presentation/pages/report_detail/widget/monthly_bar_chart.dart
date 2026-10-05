import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../domain/entities/monthly_sales_entry.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key, required this.entries});
  final List<MonthlySalesEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          context.tr(
                shared.LocaleKeys.reportPageEmptyData,
                track: shared.TrackConstants.reportPageTrack,
              ) ??
              'No data found for the selected range',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }
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
        ColumnSeries<MonthlySalesEntry, String>(
          name: 'Net Sales',
          dataSource: ordered,
          xValueMapper: (MonthlySalesEntry e, _) => e.saleMonth,
          yValueMapper: (MonthlySalesEntry e, _) => e.netTotal,
          color: scheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            overflowMode: OverflowMode.none,
            margin: EdgeInsets.zero,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ColumnSeries<MonthlySalesEntry, String>(
          name: 'Profit',
          dataSource: ordered,
          xValueMapper: (MonthlySalesEntry e, _) => e.saleMonth,
          yValueMapper: (MonthlySalesEntry e, _) => e.monthlyProfit,
          color: Colors.green.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            overflowMode: OverflowMode.none,
            margin: EdgeInsets.zero,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
