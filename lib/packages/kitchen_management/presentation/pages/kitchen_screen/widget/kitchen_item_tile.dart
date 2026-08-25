import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../../domain/entities/kitchen_order_item_entity.dart';

class KitchenItemTile extends StatelessWidget {
  final KitchenOrderItemEntity item;
  final Function(String newStatus) onStatusChanged;

  const KitchenItemTile({
    super.key,
    required this.item,
    required this.onStatusChanged,
  });

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'preparing':
        return context.tr(shared.LocaleKeys.kitchenStatusPreparing) ??
            'Preparing';
      case 'ready':
        return context.tr(shared.LocaleKeys.kitchenStatusReady) ?? 'Ready';
      case 'pending':
      default:
        return context.tr(shared.LocaleKeys.kitchenStatusPending) ?? 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context, item.status);
    final statusLabel = _getStatusLabel(context, item.status);

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
                      context.tr(shared.LocaleKeys.kitchenStatusPending) ??
                          'Pending',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'preparing',
                    child: Text(
                      context.tr(shared.LocaleKeys.kitchenStatusPreparing) ??
                          'Preparing',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ready',
                    child: Text(
                      context.tr(shared.LocaleKeys.kitchenStatusReady) ??
                          'Ready',
                    ),
                  ),
                ],
              ),
            ],
          ),
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
