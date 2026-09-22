import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../domain/entities/payment_mode_entry.dart';

class PaymentModePieChart extends StatelessWidget {
  const PaymentModePieChart({super.key, required this.entries});
  final List<PaymentModeEntry> entries;

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
    final total = entries.fold<double>(0, (s, e) => s + e.totalAmount);
    return SfCircularChart(
      legend: const Legend(
        isVisible: true,
        overflowMode: LegendItemOverflowMode.wrap,
        position: LegendPosition.bottom,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        DoughnutSeries<PaymentModeEntry, String>(
          dataSource: entries,
          xValueMapper: (PaymentModeEntry e, _) => e.paymentMethodName,
          yValueMapper: (PaymentModeEntry e, _) => e.totalAmount,
          dataLabelMapper: (PaymentModeEntry e, _) => total > 0
              ? '${(e.totalAmount / total * 100).toStringAsFixed(1)}%'
              : '0%',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
          ),
          innerRadius: '60%',
          animationDuration: 800,
        ),
      ],
    );
  }
}
