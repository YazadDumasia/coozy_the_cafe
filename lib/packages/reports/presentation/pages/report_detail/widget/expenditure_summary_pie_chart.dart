import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../domain/entities/expenditure_summary_entry.dart';

class ExpenditureSummaryPieChart extends StatelessWidget {
  const ExpenditureSummaryPieChart({super.key, required this.entries});
  final List<ExpenditureSummaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No expenditure records found for selected range',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }
    // Separate expense vs income or show breakdown
    final total = entries.fold<double>(0, (s, e) => s + e.totalAmount);
    return SfCircularChart(
      legend: const Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        DoughnutSeries<ExpenditureSummaryEntry, String>(
          dataSource: entries,
          xValueMapper: (ExpenditureSummaryEntry e, _) =>
              '${e.categoryName} (${e.type})',
          yValueMapper: (ExpenditureSummaryEntry e, _) => e.totalAmount,
          dataLabelMapper: (ExpenditureSummaryEntry e, _) => total > 0
              ? '${(e.totalAmount / total * 100).toStringAsFixed(1)}%'
              : '0%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
          ),
          innerRadius: '55%',
          animationDuration: 800,
        ),
      ],
    );
  }
}
