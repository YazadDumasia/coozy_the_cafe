import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../../domain/entities/order_management_entity.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderManagementEntity order;
  final VoidCallback onTap;
  final Function(String newStatus)? onStatusChanged;

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.onTap,
    this.onStatusChanged,
  });

  Color _getStatusColor(BuildContext context, String status) {
    final theme = Theme.of(context);
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'inprogress':
      case 'in_progress':
      case 'inpreparation':
        return Colors.orange;
      case 'cancelled':
      case 'canceled':
        return theme.colorScheme.error;
      case 'neworder':
      case 'new':
      default:
        return theme.colorScheme.primary;
    }
  }

  String _getStatusLabel(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return context.tr(
              shared.LocaleKeys.orderManagementOrderStatusCompleted,
              track: shared.TrackConstants.orderManagementPageTrack,
            ) ??
            'Completed';
      case 'inprogress':
      case 'in_progress':
      case 'inpreparation':
        return context.tr(
              shared.LocaleKeys.orderManagementOrderStatusInProgress,
              track: shared.TrackConstants.orderManagementPageTrack,
            ) ??
            'In Progress';
      case 'cancelled':
      case 'canceled':
        return context.tr(
              shared.LocaleKeys.orderManagementOrderStatusCancelled,
              track: shared.TrackConstants.orderManagementPageTrack,
            ) ??
            'Cancelled';
      case 'neworder':
      case 'new':
      default:
        return context.tr(
              shared.LocaleKeys.orderManagementOrderStatusNew,
              track: shared.TrackConstants.orderManagementPageTrack,
            ) ??
            'New Order';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final formattedDate = order.creationDate != null
        ? DateUtil.localFormat(order.creationDate, DateUtil.dateFormat3) ??
            order.creationDate!
        : 'N/A';

    final statusColor = _getStatusColor(context, order.status);
    final statusLabel = _getStatusLabel(context, order.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withAlpha(80),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  if (order.tableNameText != null &&
                      order.tableNameText!.isNotEmpty) ...[
                    Icon(
                      Icons.table_restaurant,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.tableNameText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(
                    Icons.room_service,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.orderType ?? 'Dine-In',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (order.paymentMethodName != null &&
                      order.paymentMethodName!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        order.paymentMethodName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (order.customerName != null &&
                      order.customerName!.isNotEmpty) ...[
                    Icon(
                      Icons.person,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        order.customerName!,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} items',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(value: order.totalAmount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
