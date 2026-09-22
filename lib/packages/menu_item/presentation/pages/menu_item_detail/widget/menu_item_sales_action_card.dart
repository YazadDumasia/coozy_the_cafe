import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/reports/domain/entities/report_category.dart';
import 'package:coozy_the_cafe/packages/reports/presentation/bloc/reports_cubit/reports_cubit.dart';
import 'package:coozy_the_cafe/packages/reports/presentation/pages/report_detail/report_detail_page.dart';

class MenuItemSalesActionCard extends StatelessWidget {
  const MenuItemSalesActionCard({super.key, required this.item});
  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final category = ReportCategory(
            id: 'item_sales_${item.id ?? item.name}',
            title: '${item.name} Sales',
            subtitle: 'Detailed sales, quantity sold & profit trends',
            type: ReportType.menuItemSales,
            icon: Icons.insights_rounded,
            filterItemName: item.name,
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider<ReportsCubit>(
                create: (_) => GetIt.instance<ReportsCubit>(),
                child: ReportDetailPage(category: category),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.auto_graph_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(
                            shared.LocaleKeys.reportPageViewItemSalesAction,
                            track: shared.TrackConstants.reportPageTrack,
                          ) ??
                          'View Sales & Analytics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Check sales trends, quantity sold, and profit margins for ${item.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
