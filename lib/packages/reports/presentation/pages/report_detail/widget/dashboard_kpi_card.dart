import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../../domain/entities/sales_dashboard.dart';

class DashboardKpiCard extends StatelessWidget {
  const DashboardKpiCard({super.key, required this.dashboard});
  final SalesDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final profitPercentageStr = dashboard.profitPercentage != null
        ? '${dashboard.profitPercentage!.toStringAsFixed(1)}%'
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Highlight Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.7),
                scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr(
                          shared.LocaleKeys.reportPageNetTotal,
                          track: shared.TrackConstants.reportPageTrack,
                        ) ??
                        'Net Total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: dashboard.totalProfit >= 0
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          dashboard.totalProfit >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: dashboard.totalProfit >= 0
                              ? Colors.green
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profitPercentageStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: dashboard.totalProfit >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _fmt(dashboard.netTotal),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${context.tr(shared.LocaleKeys.reportPageTotalProfit, track: shared.TrackConstants.reportPageTrack) ?? 'Total Profit'}: ${_fmt(dashboard.totalProfit)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: dashboard.totalProfit >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // KPI Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _KpiTile(
              label:
                  context.tr(
                    shared.LocaleKeys.reportPageTotalInvoices,
                    track: shared.TrackConstants.reportPageTrack,
                  ) ??
                  'Total Invoices',
              value: dashboard.totalInvoices.toString(),
              icon: Icons.receipt_long_rounded,
              color: scheme.primary,
            ),
            _KpiTile(
              label:
                  context.tr(
                    shared.LocaleKeys.reportPageGrossSales,
                    track: shared.TrackConstants.reportPageTrack,
                  ) ??
                  'Gross Sales',
              value: _fmt(dashboard.totalSales),
              icon: Icons.attach_money_rounded,
              color: Colors.green,
            ),
            _KpiTile(
              label:
                  context.tr(
                    shared.LocaleKeys.reportPageAvgOrderValue,
                    track: shared.TrackConstants.reportPageTrack,
                  ) ??
                  'Avg Order Value',
              value: _fmt(dashboard.averageOrderValue),
              icon: Icons.bar_chart_rounded,
              color: Colors.orange,
            ),
            _KpiTile(
              label:
                  context.tr(
                    shared.LocaleKeys.reportPageProfitMargin,
                    track: shared.TrackConstants.reportPageTrack,
                  ) ??
                  'Profit Margin',
              value: profitPercentageStr,
              icon: Icons.percent_rounded,
              color: Colors.purple,
            ),
            _KpiTile(
              label:
                  context.tr(
                    shared.LocaleKeys.reportPageTotalTax,
                    track: shared.TrackConstants.reportPageTrack,
                  ) ??
                  'Total Tax',
              value: _fmt(dashboard.totalTax),
              icon: Icons.account_balance_rounded,
              color: Colors.blueGrey,
            ),
            _KpiTile(
              label:
                  context.tr(
                    shared.LocaleKeys.reportPageTotalDiscount,
                    track: shared.TrackConstants.reportPageTrack,
                  ) ??
                  'Total Discount',
              value: _fmt(dashboard.totalDiscount),
              icon: Icons.discount_rounded,
              color: Colors.deepOrange,
            ),
          ],
        ),
      ],
    );
  }

  static String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.65),
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
