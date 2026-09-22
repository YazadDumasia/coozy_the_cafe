import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../domain/entities/menu_item_sales_entry.dart';

class MenuItemSalesBarChart extends StatelessWidget {
  const MenuItemSalesBarChart({super.key, required this.entries});
  final List<MenuItemSalesEntry> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No menu item sales recorded for selected range',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    // Aggregate by item name if item appears across multiple dates
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
        );
      } else {
        aggregated[e.itemName] = e;
      }
    }

    final sortedItems = aggregated.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    final display = sortedItems.take(12).toList();

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      legend: const Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        majorGridLines: const MajorGridLines(width: 0),
        labelRotation: -30,
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 10),
        numberFormat: NumberFormat.compactCurrency(symbol: ''),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries>[
        ColumnSeries<MenuItemSalesEntry, String>(
          name: 'Revenue',
          dataSource: display,
          xValueMapper: (MenuItemSalesEntry e, _) => e.itemName,
          yValueMapper: (MenuItemSalesEntry e, _) => e.totalAmount,
          color: scheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: TextStyle(color: scheme.onSurface, fontSize: 9),
          ),
        ),
        ColumnSeries<MenuItemSalesEntry, String>(
          name: 'Profit',
          dataSource: display,
          xValueMapper: (MenuItemSalesEntry e, _) => e.itemName,
          yValueMapper: (MenuItemSalesEntry e, _) => e.totalProfit,
          color: Colors.teal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
