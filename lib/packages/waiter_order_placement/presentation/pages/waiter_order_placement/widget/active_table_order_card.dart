import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/active_table_order.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/active_table_orders_bloc.dart';
import 'delete_order_dialog.dart';

class ActiveTableOrderCard extends StatelessWidget {
  final ActiveTableOrder order;
  final VoidCallback onDeleteConfirmed;
  final VoidCallback? onItemTap;

  const ActiveTableOrderCard({
    super.key,
    required this.order,
    required this.onDeleteConfirmed,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    const EdgeInsets cardMargin = EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    );
    const EdgeInsets cardPadding = EdgeInsets.all(12.0);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      margin: cardMargin,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onItemTap,
        onLongPress: () async {
          final confirm = await DeleteOrderDialog.show(context);
          if (confirm == true) {
            onDeleteConfirmed();
          }
        },
        child: Padding(
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.tableName.toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (order.tableShape != null)
                          Text(
                            order.tableShape!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        Text(
                          context.tr(shared.LocaleKeys.shapeLabel) ?? 'Shape',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BlocSelector<
                        ActiveTableOrdersBloc,
                        ActiveTableOrdersState,
                        String
                      >(
                        selector: (state) {
                          if (state is ActiveTableOrdersLoaded) {
                            return state.orderDurations[order.orderId] ??
                                '0m:0s';
                          }
                          return '0m:0s';
                        },
                        builder: (context, formattedDuration) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.stopwatch,
                                size: 16,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDuration,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: primaryColor,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (order.tableLocationNotes != null)
                        Text(
                          order.tableLocationNotes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusItem(
                    context: context,
                    count: order.pendingItemCount,
                    icon: CupertinoIcons.hourglass,
                  ),
                  _buildStatusItem(
                    context: context,
                    count: order.cookingItemCount,
                    icon: Icons.soup_kitchen_outlined,
                  ),
                  _buildStatusItem(
                    context: context,
                    count: order.servedItemCount,
                    icon: Icons.flatware_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required BuildContext context,
    required int count,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final countText = count > 0 ? '$count' : '-';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          countText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
      ],
    );
  }
}
