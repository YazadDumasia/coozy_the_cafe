import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../../domain/entities/demand_insights.dart';

class InsightsDashboardView extends StatelessWidget {
  const InsightsDashboardView({super.key, required this.insights});

  final DemandInsights insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary KPI Cards ─────────────────────────────────────────────
          _buildSummaryCards(context, scheme, isDark),
          const SizedBox(height: 24),

          // ── 7-Day Demand & Sales Projection Chart ─────────────────────────
          _buildProjectionSection(context, scheme, isDark),
          const SizedBox(height: 24),

          // ── Rush-Hour / Peak Demand Heatmap Bar Chart ────────────────────
          _buildHourlyPeakSection(context, scheme, isDark),
          const SizedBox(height: 24),

          // ── Inventory Stock Depletion & Low Stock Runout Forecast ────────
          _buildDepletionSection(context, scheme, isDark),
          const SizedBox(height: 24),

          // ── Menu Engineering (BCG Matrix) ─────────────────────────────────
          _buildMenuMatrixSection(context, scheme, isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);

    final cards = [
      _KpiMiniCard(
        title: 'Projected Tomorrow Sales',
        value: '₹${insights.expectedTomorrowSales.toStringAsFixed(0)}',
        icon: Icons.auto_awesome_rounded,
        color: scheme.primary,
        subtitle: 'Holt-Winters double exponential forecast',
      ),
      _KpiMiniCard(
        title: 'Sales Velocity Trend',
        value:
            '${insights.growthTrendPercentage >= 0 ? '+' : ''}${insights.growthTrendPercentage.toStringAsFixed(1)}%',
        icon:
            insights.growthTrendPercentage >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
        color:
            insights.growthTrendPercentage >= 0 ? Colors.green : Colors.orange,
        subtitle: 'Period-over-period momentum',
      ),
      _KpiMiniCard(
        title: 'Urgent Stockouts Risk',
        value:
            '${insights.depletionForecasts.where((d) => d.isUrgentReorder).length} Items',
        icon: Icons.warning_amber_rounded,
        color:
            insights.depletionForecasts.any((d) => d.isUrgentReorder)
                ? Colors.red
                : Colors.teal,
        subtitle: 'Depleting in ≤ 2.5 days',
      ),
      _KpiMiniCard(
        title: 'Star Menu Items',
        value:
            '${insights.menuMatrixItems.where((m) => m.category == MenuEngineeringCategory.star).length} Stars',
        icon: Icons.star_rounded,
        color: Colors.amber.shade700,
        subtitle: 'High profit + high sales volume',
      ),
    ];

    if (isDesktop) {
      return Row(
        children:
            cards
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: c,
                    ),
                  ),
                )
                .toList(),
      );
    }

    if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 12),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }

    // Mobile layout
    return Column(
      children:
          cards
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: c,
                ),
              )
              .toList(),
    );
  }

  Widget _buildProjectionSection(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final points = insights.salesForecasts;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: scheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next 7-Day Demand & Revenue Forecast',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Projected revenue with confidence interval band',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 260,
              child:
                  points.isEmpty
                      ? const Center(child: Text('No forecast data available'))
                      : SfCartesianChart(
                        primaryXAxis: const CategoryAxis(
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        primaryYAxis: NumericAxis(
                          numberFormat: null,
                          axisLine: const AxisLine(width: 0),
                          majorTickLines: const MajorTickLines(size: 0),
                          labelFormat: '₹{value}',
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <CartesianSeries<SalesForecastPoint, String>>[
                          SplineAreaSeries<SalesForecastPoint, String>(
                            name: 'Upper Bound',
                            dataSource: points,
                            xValueMapper: (f, _) {
                              final parts = f.dateIso.split('-');
                              return parts.length >= 3
                                  ? '${parts[1]}/${parts[2]}'
                                  : f.dateIso;
                            },
                            yValueMapper: (f, _) => f.upperBound,
                            color: scheme.primary.withValues(alpha: 0.1),
                            borderColor: Colors.transparent,
                          ),
                          SplineSeries<SalesForecastPoint, String>(
                            name: 'Predicted Sales',
                            dataSource: points,
                            xValueMapper: (f, _) {
                              final parts = f.dateIso.split('-');
                              return parts.length >= 3
                                  ? '${parts[1]}/${parts[2]}'
                                  : f.dateIso;
                            },
                            yValueMapper: (f, _) => f.predictedSales,
                            color: scheme.primary,
                            width: 3,
                            markerSettings: const MarkerSettings(
                              isVisible: true,
                              height: 6,
                              width: 6,
                              shape: DataMarkerType.circle,
                            ),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.top,
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyPeakSection(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final hours = insights.hourlyDemands;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peak Rush Hours & Demand Curve',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Order concentration throughout the day for staffing & kitchen prep optimization',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  labelRotation: -45,
                ),
                primaryYAxis: const NumericAxis(
                  axisLine: AxisLine(width: 0),
                  majorTickLines: MajorTickLines(size: 0),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<HourlyDemandPoint, String>>[
                  ColumnSeries<HourlyDemandPoint, String>(
                    name: 'Orders',
                    dataSource: hours,
                    xValueMapper: (h, _) => h.timeLabel,
                    yValueMapper: (h, _) => h.orderCount,
                    pointColorMapper:
                        (h, _) =>
                            h.isPeakHour
                                ? Colors.orange.shade700
                                : scheme.primary.withValues(alpha: 0.6),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepletionSection(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final items = insights.depletionForecasts;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.teal,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory Burn Rate & Runout Forecast',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Predicts days until raw stock depletion based on recent consumption velocity',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No inventory stock logged yet')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.take(6).length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.inventoryName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Stock: ${item.currentStock} ${item.unit} • Burn rate: ${item.dailyConsumptionRate} ${item.unit}/day',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            item.isUrgentReorder
                                ? Colors.red.withValues(alpha: 0.15)
                                : Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.estimatedDaysRemaining > 90
                            ? 'Ample Stock'
                            : '${item.estimatedDaysRemaining} Days left',
                        style: TextStyle(
                          color:
                              item.isUrgentReorder ? Colors.red : Colors.teal,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuMatrixSection(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final items = insights.menuMatrixItems;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.purple,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Menu Engineering (BCG Matrix)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Classifies dishes by Sales Volume vs Profit Margin to optimize pricing & menu placement',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No menu item sales recorded yet')),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    items.take(12).map((item) {
                      Color badgeColor;
                      String label;
                      IconData icon;
                      switch (item.category) {
                        case MenuEngineeringCategory.star:
                          badgeColor = Colors.amber.shade700;
                          label = 'Star';
                          icon = Icons.star_rounded;
                        case MenuEngineeringCategory.plowhorse:
                          badgeColor = Colors.blue.shade700;
                          label = 'Workhorse';
                          icon = Icons.flash_on_rounded;
                        case MenuEngineeringCategory.puzzle:
                          badgeColor = Colors.purple.shade600;
                          label = 'Hidden Gem';
                          icon = Icons.lightbulb_rounded;
                        case MenuEngineeringCategory.dog:
                          badgeColor = Colors.grey.shade600;
                          label = 'Underperformer';
                          icon = Icons.low_priority_rounded;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 18, color: badgeColor),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '$label • ${item.totalQuantitySold} sold • ${item.marginPercentage}% margin',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: badgeColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _KpiMiniCard extends StatelessWidget {
  const _KpiMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
