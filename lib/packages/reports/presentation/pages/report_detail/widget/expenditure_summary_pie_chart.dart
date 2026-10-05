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
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }
    // Aggregate by category & type across periods
    final Map<String, double> categoryTotals = {};
    for (final e in entries) {
      final key = '${e.categoryName} (${e.type})';
      categoryTotals[key] = (categoryTotals[key] ?? 0) + e.totalAmount;
    }
    final aggregated = categoryTotals.entries.map((entry) {
      return _AggregatedExpenditure(name: entry.key, amount: entry.value);
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    final total = aggregated.fold<double>(0, (s, e) => s + e.amount);
    return SfCircularChart(
      legend: const Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        DoughnutSeries<_AggregatedExpenditure, String>(
          dataSource: aggregated,
          xValueMapper: (_AggregatedExpenditure e, _) => e.name,
          yValueMapper: (_AggregatedExpenditure e, _) => e.amount,
          dataLabelMapper: (_AggregatedExpenditure e, _) => total > 0
              ? '${(e.amount / total * 100).toStringAsFixed(1)}%'
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

class _AggregatedExpenditure {
  const _AggregatedExpenditure({required this.name, required this.amount});
  final String name;
  final double amount;
}
