import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/combo_engine/domain/entities/combo.dart';

class ComboPickerTile extends StatelessWidget {
  final Combo combo;
  final int quantityInCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ComboPickerTile({
    super.key,
    required this.combo,
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isSelected = quantityInCart > 0;
    final cardBorderColor = isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    final discountPct = combo.discountPercentage;
    final originalPrice = combo.calculatedOriginalPrice;
    final sellingPrice = combo.sellingPrice;

    return Card(
      elevation: isSelected ? 2 : 1,
      margin: cardMargin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: cardBorderColor, width: isSelected ? 1.5 : 1.0),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onAdd,
        onLongPress: quantityInCart > 0 ? onRemove : null,
        child: Padding(
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Name, Badges, Description, Bundled Items
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Combo Title
                        Text(
                          combo.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ).inExpandedRow(),
                        // Badges Row (Discount % & Preparation Duration)
                        if (discountPct > 0 ||
                            (combo.effectiveDuration != null &&
                                combo.effectiveDuration! > 0)) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (discountPct > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${discountPct.toStringAsFixed(0)}% OFF',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              if (combo.effectiveDuration != null &&
                                  combo.effectiveDuration! > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 11,
                                        color: colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${combo.effectiveDuration}m',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSecondaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                        if (combo.description != null &&
                            combo.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            combo.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? colorScheme.onSurfaceVariant
                                  : const Color(0xFF666666),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (combo.items.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: combo.items.map((it) {
                              final itemName =
                                  it.menuItem?.name ?? 'Item #${it.menuItemId}';
                              final varName = it.variation?.name;
                              final title = varName != null
                                  ? '$itemName ($varName)'
                                  : itemName;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  '${it.quantity}x $title',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right: Quantity Controls (x 0 or - [qty] +)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (quantityInCart > 0) ...[
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: colorScheme.error,
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
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'x $quantityInCart',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: colorScheme.primary,
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
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Price display
              Row(
                children: [
                  Text(
                    core.CurrencyFormatter.format(value: sellingPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (originalPrice > sellingPrice) ...[
                    const SizedBox(width: 8),
                    Text(
                      core.CurrencyFormatter.format(value: originalPrice),
                      style: theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
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
