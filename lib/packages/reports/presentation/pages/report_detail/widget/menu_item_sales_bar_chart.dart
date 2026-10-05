import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../domain/entities/menu_item_sales_entry.dart';

import '../../../../domain/entities/sales_trend_entry.dart';
import '../../../../domain/utils/report_date_utils.dart';

class MenuItemSalesBarChart extends StatelessWidget {
  const MenuItemSalesBarChart({
    super.key,
    required this.entries,
    this.format = SalesPeriodFormat.daily,
  });
  final List<MenuItemSalesEntry> entries;
  final SalesPeriodFormat format;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No menu item sales recorded for selected range',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
        ),
      );
    }

    final uniqueItems = entries.map((e) => e.itemName).toSet();
    final bool isSingleItem = uniqueItems.length == 1;

    final List<MenuItemSalesEntry> display;
    if (isSingleItem) {
      display = entries.reversed.toList();
    } else {
      // Aggregate by item name across periods
      final Map<String, MenuItemSalesEntry> aggregated = {};
      for (final e in entries) {
        if (aggregated.containsKey(e.itemName)) {
          final existing = aggregated[e.itemName]!;
          final newQty = existing.quantitySold + e.quantitySold;
          final newTotal = existing.totalAmount + e.totalAmount;
          final newCost = existing.totalCost + e.totalCost;
          final newProfit = newTotal - newCost;
          aggregated[e.itemName] = MenuItemSalesEntry(
            itemName: e.itemName,
            saleDate: e.saleDate,
            quantitySold: newQty,
            totalAmount: newTotal,
            totalCost: newCost,
            totalProfit: newProfit,
            profitPercentage: newTotal > 0 ? (newProfit / newTotal) * 100 : 0,
            period: e.period,
            startDate: e.startDate,
            endDate: e.endDate,
          );
        } else {
          aggregated[e.itemName] = e;
        }
      }

      final sortedItems = aggregated.values.toList()
        ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

      display = sortedItems.take(12).toList();
    }

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: const EdgeInsets.fromLTRB(12, 16, 16, 16),
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        majorGridLines: const MajorGridLines(width: 0),
        labelRotation: -30,
        maximumLabelWidth: 140,
        labelIntersectAction: AxisLabelIntersectAction.none,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        numberFormat: NumberFormat.compactCurrency(symbol: ''),
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
        zoomMode: ZoomMode.x,
      ),
      series: <CartesianSeries>[
        ColumnSeries<MenuItemSalesEntry, String>(
          name: 'Revenue',
          dataSource: display,
          xValueMapper: (MenuItemSalesEntry e, _) => isSingleItem
              ? ReportDateUtils.formatChartLabel(
                  period: e.period,
                  format: format,
                  startDate: e.startDate,
                  endDate: e.endDate,
                )
              : e.itemName,
          yValueMapper: (MenuItemSalesEntry e, _) => e.totalAmount,
          color: scheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ColumnSeries<MenuItemSalesEntry, String>(
          name: 'Profit',
          dataSource: display,
          xValueMapper: (MenuItemSalesEntry e, _) => isSingleItem
              ? ReportDateUtils.formatChartLabel(
                  period: e.period,
                  format: format,
                  startDate: e.startDate,
                  endDate: e.endDate,
                )
              : e.itemName,
          yValueMapper: (MenuItemSalesEntry e, _) => e.totalProfit,
          color: Colors.teal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
