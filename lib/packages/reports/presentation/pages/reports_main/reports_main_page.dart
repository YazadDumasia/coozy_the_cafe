import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/reports_cubit/reports_cubit.dart';
import '../../../domain/entities/report_category.dart';
import '../report_detail/report_detail_page.dart';
import 'widget/report_category_card.dart';

class ReportsMainPage extends StatelessWidget {
  const ReportsMainPage({super.key});

  List<ReportCategory> _buildCategories(BuildContext context) {
    return [
      ReportCategory(
        id: 'sales_trends',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategorySalesTrendsTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Sales Trends',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategorySalesTrendsSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Track sales performance by day, week, month, or year',
        type: ReportType.salesTrends,
        icon: Icons.trending_up_rounded,
      ),
      ReportCategory(
        id: 'top_items',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategoryTopItemsTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Top Selling Items',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategoryTopItemsSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Discover your best-performing menu items',
        type: ReportType.topSellingItems,
        icon: Icons.trending_up_rounded,
      ),
      ReportCategory(
        id: 'menu_item_sales',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategoryMenuItemSalesTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Menu Item Sales',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategoryMenuItemSalesSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Detailed sales and profit by menu item',
        type: ReportType.menuItemSales,
        icon: Icons.restaurant_menu_rounded,
      ),
      ReportCategory(
        id: 'payment_modes',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategoryPaymentModesTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Payment Modes',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategoryPaymentModesSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Breakdown of revenue by payment method',
        type: ReportType.paymentModes,
        icon: Icons.payments_rounded,
      ),
      ReportCategory(
        id: 'dashboard',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategoryDashboardTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Sales Dashboard',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategoryDashboardSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'KPI overview — profit, averages, totals',
        type: ReportType.salesDashboard,
        icon: Icons.dashboard_rounded,
      ),
      ReportCategory(
        id: 'inventory_stock',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategoryInventoryStockTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Inventory Stock',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategoryInventoryStockSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Stock levels, units, and reorder warnings',
        type: ReportType.inventoryStock,
        icon: Icons.inventory_2_rounded,
      ),
      ReportCategory(
        id: 'purchases',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategoryPurchasesTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Purchase Summary',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategoryPurchasesSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Procurement costs and volume trends',
        type: ReportType.purchases,
        icon: Icons.shopping_cart_checkout_rounded,
      ),
      ReportCategory(
        id: 'expenditure',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategoryExpenditureTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Expenditure Report',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategoryExpenditureSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Expense vs income and category breakdown',
        type: ReportType.expenditure,
        icon: Icons.account_balance_wallet_rounded,
      ),
      ReportCategory(
        id: 'stock_adjustments',
        title:
            context.tr(
              shared.LocaleKeys.reportPageCategoryStockAdjustmentsTitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Stock Adjustments',
        subtitle:
            context.tr(
              shared.LocaleKeys.reportPageCategoryStockAdjustmentsSubtitle,
              track: shared.TrackConstants.reportPageTrack,
            ) ??
            'Manual stock additions, reductions, and reasons',
        type: ReportType.stockAdjustments,
        icon: Icons.tune_rounded,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final categories = _buildCategories(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.reportPageReportsAndAnalytics,
                track: shared.TrackConstants.reportPageTrack,
              ) ??
              'Reports & Analytics',
        ),
      ),
      body: shared.ResponsiveLayout(
        mobile: _buildScrollView(
          context: context,
          theme: theme,
          scheme: scheme,
          categories: categories,
          crossAxisCount: 2,
          mainAxisExtent: 170,
        ),
        tablet: _buildScrollView(
          context: context,
          theme: theme,
          scheme: scheme,
          categories: categories,
          crossAxisCount: 3,
          mainAxisExtent: 150,
        ),
        desktop: _buildScrollView(
          context: context,
          theme: theme,
          scheme: scheme,
          categories: categories,
          crossAxisCount: 4,
          mainAxisExtent: 150,
        ),
      ),
    );
  }

  Widget _buildScrollView({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme scheme,
    required List<ReportCategory> categories,
    required int crossAxisCount,
    required double mainAxisExtent,
  }) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.12),
                    scheme.surfaceContainerLow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: scheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                                shared.LocaleKeys.reportPageReportsAndAnalytics,
                                track: shared.TrackConstants.reportPageTrack,
                              ) ??
                              'Reports & Analytics',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr(
                                shared
                                    .LocaleKeys
                                    .reportPageChooseReportSubtitle,
                                track: shared.TrackConstants.reportPageTrack,
                              ) ??
                              'Choose a report to view detailed charts, tabular data and export insights',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              mainAxisExtent: mainAxisExtent,
            ),
            delegate: SliverChildBuilderDelegate(
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              (context, index) {
                final category = categories[index];
                return ReportCategoryCard(
                  category: category,
                  onTap: () => _openReport(context, category),
                );
              },
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }

  void _openReport(BuildContext context, ReportCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<ReportsCubit>(
          create: (_) => GetIt.instance<ReportsCubit>(),
          child: ReportDetailPage(category: category),
        ),
      ),
    );
  }
}
