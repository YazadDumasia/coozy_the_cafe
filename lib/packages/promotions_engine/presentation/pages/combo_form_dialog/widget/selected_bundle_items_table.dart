import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

import '../../../../domain/entities/combo_item.dart';

class SelectedBundleItemsTable extends StatelessWidget {
  final List<ComboItem> items;
  final Function(int index, int newQuantity) onQuantityChanged;
  final Function(int index) onRemoveItem;

  const SelectedBundleItemsTable({
    super.key,
    required this.items,
    required this.onQuantityChanged,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_shopping_cart_rounded,
                size: 40,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No items added to this bundle yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Search and add 2 or more menu items from the left selector.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int index = 0; index < items.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            _buildItemRow(context, items[index], index, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    ComboItem item,
    int index,
    ColorScheme colorScheme,
  ) {
    final itemName = item.menuItem?.name ?? 'Item #${item.menuItemId}';
    final varName = item.variation?.name;
    final title = varName != null ? '$itemName ($varName)' : itemName;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      '${core.CurrencyFormatter.format(value: item.unitPrice)} each',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (item.duration != null && item.duration! > 0) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${item.duration}m',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 18,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: item.quantity > 1
                    ? () => onQuantityChanged(index, item.quantity - 1)
                    : null,
              ),
              Text(
                '${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                iconSize: 18,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onQuantityChanged(index, item.quantity + 1),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            core.CurrencyFormatter.format(value: item.totalPrice),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            iconSize: 20,
            icon: Icon(Icons.close_rounded, color: colorScheme.error),
            onPressed: () => onRemoveItem(index),
          ),
        ],
      ),
    );
  }
}
