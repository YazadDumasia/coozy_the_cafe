import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../domain/entities/sales_trend_entry.dart';
import '../../../../domain/utils/report_date_utils.dart';

class SalesTrendsChart extends StatefulWidget {
  const SalesTrendsChart({
    super.key,
    required this.entries,
    required this.format,
  });

  final List<SalesTrendEntry> entries;
  final SalesPeriodFormat format;

  @override
  State<SalesTrendsChart> createState() => _SalesTrendsChartState();
}

class _SalesTrendsChartState extends State<SalesTrendsChart> {
  late final ValueNotifier<bool> _isBarChartNotifier;

  @override
  void initState() {
    super.initState();
    // Default to Bar chart for weekly, monthly, yearly; Line chart for daily
    _isBarChartNotifier = ValueNotifier<bool>(
      widget.format != SalesPeriodFormat.daily,
    );
  }

  @override
  void didUpdateWidget(covariant SalesTrendsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.format != widget.format) {
      _isBarChartNotifier.value = widget.format != SalesPeriodFormat.daily;
    }
  }

  @override
  void dispose() {
    _isBarChartNotifier.dispose();
    super.dispose();
  }

  String _formatLabel(SalesTrendEntry entry, SalesPeriodFormat format) {
    return ReportDateUtils.formatChartLabel(
      period: entry.period,
      format: format,
      startDate: entry.startDate,
      endDate: entry.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (widget.entries.isEmpty) {
      return Center(
        child: Text(
          context.tr(
                shared.LocaleKeys.reportPageEmptyData,
                track: shared.TrackConstants.reportPageTrack,
              ) ??
              'No data found for the selected range',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    // Oldest period first on X axis
    final ordered = widget.entries.reversed.toList();

    return Column(
      children: [
        // Mode toggle (Bar vs Line)
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isBarChartNotifier,
              builder: (context, isBar, _) {
                return IconButton.outlined(
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  tooltip: isBar ? 'Switch to Line Chart' : 'Switch to Bar Chart',
                  icon: Icon(
                    isBar ? Icons.show_chart_rounded : Icons.bar_chart_rounded,
                  ),
                  onPressed: () => _isBarChartNotifier.value = !isBar,
                );
              },
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isBarChartNotifier,
            builder: (context, isBar, _) {
              return SfCartesianChart(
                plotAreaBorderWidth: 0,
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
                  majorGridLines: const MajorGridLines(width: 0),
                  labelRotation: ordered.length > 8 ? -45 : 0,
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
                series: isBar
                    ? <CartesianSeries>[
                        ColumnSeries<SalesTrendEntry, String>(
                          name: 'Net Sales',
                          dataSource: ordered,
                          xValueMapper: (SalesTrendEntry e, _) =>
                              _formatLabel(e, widget.format),
                          yValueMapper: (SalesTrendEntry e, _) => e.netTotal,
                          color: scheme.primary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          dataLabelSettings: DataLabelSettings(
                            isVisible: ordered.length <= 12,
                            labelAlignment: ChartDataLabelAlignment.top,
                            overflowMode: OverflowMode.none,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ColumnSeries<SalesTrendEntry, String>(
                          name: 'Profit',
                          dataSource: ordered,
                          xValueMapper: (SalesTrendEntry e, _) =>
                              _formatLabel(e, widget.format),
                          yValueMapper: (SalesTrendEntry e, _) => e.totalProfit,
                          color: Colors.green.withValues(alpha: 0.85),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          dataLabelSettings: DataLabelSettings(
                            isVisible: ordered.length <= 12,
                            labelAlignment: ChartDataLabelAlignment.top,
                            overflowMode: OverflowMode.none,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    : <CartesianSeries>[
                        SplineAreaSeries<SalesTrendEntry, String>(
                          name: 'Net Sales',
                          dataSource: ordered,
                          xValueMapper: (SalesTrendEntry e, _) =>
                              _formatLabel(e, widget.format),
                          yValueMapper: (SalesTrendEntry e, _) => e.netTotal,
                          color: scheme.primary.withValues(alpha: 0.25),
                          borderColor: scheme.primary,
                          borderWidth: 2,
                          markerSettings: MarkerSettings(
                            isVisible: true,
                            color: scheme.primary,
                            borderColor: scheme.primary,
                            width: 6,
                            height: 6,
                          ),
                        ),
                        SplineSeries<SalesTrendEntry, String>(
                          name: 'Profit',
                          dataSource: ordered,
                          xValueMapper: (SalesTrendEntry e, _) =>
                              _formatLabel(e, widget.format),
                          yValueMapper: (SalesTrendEntry e, _) => e.totalProfit,
                          color: Colors.green,
                          width: 2,
                          markerSettings: const MarkerSettings(
                            isVisible: true,
                            color: Colors.green,
                            borderColor: Colors.green,
                            width: 6,
                            height: 6,
                          ),
                        ),
                      ],
              );
            },
          ),
        ),
      ],
    );
  }
}
