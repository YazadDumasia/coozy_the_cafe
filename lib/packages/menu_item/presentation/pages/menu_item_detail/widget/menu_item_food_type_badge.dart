import 'package:flutter/material.dart';

class MenuItemFoodTypeBadge extends StatelessWidget {
  final String? foodType;

  const MenuItemFoodTypeBadge({
    super.key,
    required this.foodType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ft = (foodType ?? '').toLowerCase();

    Color borderColor;
    Color fillColor;
    IconData? iconData;
    String label;

    if (ft.contains('non') || ft.contains('meat') || ft.contains('chicken')) {
      borderColor = colorScheme.error;
      fillColor = colorScheme.errorContainer;
      label = foodType ?? 'Non-Veg';
    } else if (ft.contains('egg')) {
      borderColor = colorScheme.tertiary;
      fillColor = colorScheme.tertiaryContainer;
      label = foodType ?? 'Egg';
    } else if (ft.contains('vegan')) {
      borderColor = colorScheme.secondary;
      fillColor = colorScheme.secondaryContainer;
      iconData = Icons.eco_outlined;
      label = foodType ?? 'Vegan';
    } else {
      // Default / Veg
      borderColor = colorScheme.primary;
      fillColor = colorScheme.primaryContainer;
      label = foodType ?? 'Veg';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fillColor.withValues(alpha: 0.4),
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconData != null)
            Icon(iconData, size: 14, color: borderColor)
          else
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: borderColor,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
