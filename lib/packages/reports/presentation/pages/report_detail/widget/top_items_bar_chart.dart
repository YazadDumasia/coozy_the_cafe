import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
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
    // Show top 10 items.
    // In BarSeries, reversing the list places the #1 best seller on top!
    final display = items.take(10).toList().reversed.toList();

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.fromLTRB(12, 16, 24, 16),
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        majorGridLines: const MajorGridLines(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
        labelRotation: 0,
        maximumLabelWidth: 160,
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
        zoomMode: ZoomMode.y,
      ),
      series: <CartesianSeries>[
        BarSeries<TopItemEntry, String>(
          name: 'Qty Sold',
          dataSource: display,
          xValueMapper: (TopItemEntry e, _) => e.itemName,
          yValueMapper: (TopItemEntry e, _) => e.totalQuantity,
          color: scheme.primary,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(6),
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.outer,
            textStyle: TextStyle(
              color: scheme.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
