import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/database/coozy_database.dart' show OrderItemStatus;
import '../../../../domain/entities/kitchen_order_item_entity.dart';

class KitchenItemTile extends StatelessWidget {
  final KitchenOrderItemEntity item;
  final Function(String newStatus) onStatusChanged;

  const KitchenItemTile({
    super.key,
    required this.item,
    required this.onStatusChanged,
  });

  Color _getStatusColor(BuildContext context, OrderItemStatus status) {
    switch (status) {
      case OrderItemStatus.preparing:
        return Colors.blue;
      case OrderItemStatus.ready:
        return Colors.green;
      case OrderItemStatus.served:
        return Colors.purple;
      case OrderItemStatus.cancelled:
        return Theme.of(context).colorScheme.error;
      case OrderItemStatus.pending:
        return Colors.orange;
    }
  }

  String _getStatusLabel(BuildContext context, OrderItemStatus status) {
    switch (status) {
      case OrderItemStatus.preparing:
        return context.tr(shared.LocaleKeys.kitchenStatusPreparing, track: shared.TrackConstants.orderPageTrack) ??
            'Preparing';
      case OrderItemStatus.ready:
        return context.tr(shared.LocaleKeys.kitchenStatusReady, track: shared.TrackConstants.orderPageTrack) ?? 'Ready';
      case OrderItemStatus.served:
        return 'Served';
      case OrderItemStatus.cancelled:
        return 'Cancelled';
      case OrderItemStatus.pending:
        return context.tr(shared.LocaleKeys.kitchenStatusPending, track: shared.TrackConstants.orderPageTrack) ?? 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context, item.orderItemStatus);
    final statusLabel = _getStatusLabel(context, item.orderItemStatus);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${item.quantity}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: item.status == 'ready'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (item.variationQuantity != null &&
                        item.variationUnit != null)
                      Text(
                        '${item.variationQuantity} ${item.variationUnit}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                initialValue: item.status,
                onSelected: onStatusChanged,
                child: Chip(
                  label: Text(
                    statusLabel.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: statusColor,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pending',
                    child: Text(
                      context.tr(shared.LocaleKeys.kitchenStatusPending, track: shared.TrackConstants.orderPageTrack) ??
                          'Pending',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'preparing',
                    child: Text(
                      context.tr(shared.LocaleKeys.kitchenStatusPreparing, track: shared.TrackConstants.orderPageTrack) ??
                          'Preparing',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ready',
                    child: Text(
                      context.tr(shared.LocaleKeys.kitchenStatusReady, track: shared.TrackConstants.orderPageTrack) ??
                          'Ready',
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (item.waitingDuration != null || item.preparationDuration != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (item.waitingDuration != null) ...[
                  Icon(Icons.hourglass_empty, size: 12, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 2),
                  Text(
                    'Wait: ${item.waitingDuration!.inMinutes}m ${item.waitingDuration!.inSeconds.remainder(60)}s',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (item.preparationDuration != null) ...[
                  Icon(Icons.timer_outlined, size: 12, color: Colors.blue.shade700),
                  const SizedBox(width: 2),
                  Text(
                    'Prep: ${item.preparationDuration!.inMinutes}m ${item.preparationDuration!.inSeconds.remainder(60)}s',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (item.remarks != null && item.remarks!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 12,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.kitchenNotePrefix,
                            params: {'note': item.remarks!},
                          ) ??
                          'Note: ${item.remarks}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
