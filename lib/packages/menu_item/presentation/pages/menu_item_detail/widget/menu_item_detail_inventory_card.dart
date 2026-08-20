import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class MenuItemDetailInventoryCard extends StatelessWidget {
  final double? stockQuantity;
  final String? quantity;
  final String? purchaseUnit;
  final int? sortOrderIndex;

  const MenuItemDetailInventoryCard({
    super.key,
    this.stockQuantity,
    this.quantity,
    this.purchaseUnit,
    this.sortOrderIndex,
  });

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr(
                        shared.LocaleKeys.menuItemPageAddEditMenuItemSellingUnit,
                        track: shared.TrackConstants.menuItemPageTrack,
                      ) ??
                      'Inventory & Portion',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.pie_chart_outline,
                    label:
                        context.tr(
                          shared.LocaleKeys.menuItemPageAddEditMenuItemSellingUnitQuantity,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Stock Quantity',
                    value: stockQuantity != null
                        ? '${stockQuantity!.toStringAsFixed(stockQuantity! % 1 == 0 ? 0 : 2)} units'
                        : 'Not Tracked',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.scale_outlined,
                    label:
                        context.tr(
                          shared.LocaleKeys.menuItemPageAddEditMenuItemSellingUnit,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Portion Size',
                    value: (quantity != null && quantity!.isNotEmpty)
                        ? quantity!
                        : 'N/A',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    label:
                        context.tr(
                          shared.LocaleKeys.menuItemPageAddEditMenuItemSellingUnit,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Purchase Unit',
                    value: (purchaseUnit != null && purchaseUnit!.isNotEmpty)
                        ? purchaseUnit!
                        : 'N/A',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    icon: Icons.sort,
                    label:
                        context.tr(
                          shared.LocaleKeys.menuItemPageTypes,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Sort Index',
                    value: sortOrderIndex != null ? '#$sortOrderIndex' : 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
