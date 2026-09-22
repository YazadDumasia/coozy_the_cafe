import 'package:flutter/material.dart';
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
          'No data for selected range',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
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
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<MonthlySalesEntry, String>(
          name: 'Net Sales',
          dataSource: ordered,
          xValueMapper: (MonthlySalesEntry e, _) => e.saleMonth,
          yValueMapper: (MonthlySalesEntry e, _) => e.netTotal,
          color: scheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(color: scheme.onSurface, fontSize: 9),
          ),
        ),
        ColumnSeries<MonthlySalesEntry, String>(
          name: 'Profit',
          dataSource: ordered,
          xValueMapper: (MonthlySalesEntry e, _) => e.saleMonth,
          yValueMapper: (MonthlySalesEntry e, _) => e.monthlyProfit,
          color: Colors.green.withValues(alpha: 0.8),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
