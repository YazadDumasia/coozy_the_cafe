import 'package:coozy_the_cafe/packages/database/src/database_dao/menu_items_dao.dart';
import 'package:flutter/material.dart';

class MenuItemPickerTile extends StatelessWidget {
  final MenuItemWithVariations itemWithVariations;
  final int quantityInCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const MenuItemPickerTile({
    super.key,
    required this.itemWithVariations,
    required this.quantityInCart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const EdgeInsets cardMargin = EdgeInsets.symmetric(
      horizontal: 4.0,
      vertical: 4.0,
    );
    const EdgeInsets cardPadding = EdgeInsets.symmetric(
      horizontal: 14.0,
      vertical: 12.0,
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final item = itemWithVariations.item;
    final variations = itemWithVariations.variations;
    final isMultiVariation = variations.isNotEmpty;

    final priceDisplay = isMultiVariation
        ? '₹${variations.first.sellingPrice?.toStringAsFixed(0) ?? "0"}+'
        : '₹${item.sellingPrice?.toStringAsFixed(0) ?? "0"}';

    final isSelected = quantityInCart > 0;
    final cardBorderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Card(
      elevation: isSelected ? 2 : 1,
      margin: cardMargin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: cardBorderColor, width: isSelected ? 1.5 : 1.0),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onAdd,
        onLongPress: quantityInCart > 0 ? onRemove : null,
        child: Padding(
          padding: cardPadding,
          child: Row(
            children: [
              // Left: Name & Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceDisplay,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? theme.colorScheme.onSurfaceVariant
                            : const Color(0xFF666666),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Quantity Controls (x 0 or - [1] +)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (quantityInCart > 0) ...[
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: theme.colorScheme.error,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onRemove,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'x $quantityInCart',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: theme.colorScheme.primary,
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onAdd,
                    ),
                  ] else ...[
                    Text(
                      'x 0',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
