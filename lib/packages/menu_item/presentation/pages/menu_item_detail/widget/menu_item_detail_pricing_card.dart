import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_bloc.dart';

class MenuItemDetailPricingCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemDetailPricingCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSimple = item.isSimpleVariation ?? true;
    final variations = item.variations;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isSimple ? 'Pricing & Details' : 'Variations & Pricing',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isSimple
                        ? (context.tr(
                              shared.LocaleKeys.simpleVariation,
                              track: shared.TrackConstants.menuItemPageTrack,
                            ) ??
                            'Simple')
                        : (context.tr(
                              shared.LocaleKeys.multiVariation,
                              track: shared.TrackConstants.menuItemPageTrack,
                            ) ??
                            'Multi-Variation'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (variations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  context.tr(
                        shared.LocaleKeys.commonNoDataFoundMsg,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'No variations available.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: variations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _buildVariationTile(context, variations[index], isSimple);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariationTile(
    BuildContext context,
    MenuItemVariation v,
    bool isSimple,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAvailable = v.isTodayAvailable ?? true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? colorScheme.outlineVariant.withValues(alpha: 0.6)
              : colorScheme.error.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (!isSimple && (v.name?.isNotEmpty ?? false))
                      ? v.name!
                      : 'Variation Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAvailable
                        ? (context.tr(
                              shared.LocaleKeys.menuItemPageAvailable,
                              track: shared.TrackConstants.menuItemPageTrack,
                            ) ??
                            'Available')
                        : (context.tr(
                              shared.LocaleKeys.unavailable,
                              track: shared.TrackConstants.menuItemPageTrack,
                            ) ??
                            'Unavailable'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isAvailable
                          ? colorScheme.primary
                          : colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 24,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Switch.adaptive(
                        value: isAvailable,
                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Icon(Icons.check, color: Colors.green);
                          }
                          return Icon(Icons.close, color: colorScheme.error);
                        }),
                        onChanged: (bool newVal) {
                          final updatedVariations = item.variations.map((vItem) {
                            if ((vItem.id != null && vItem.id == v.id) ||
                                (vItem.hashId != null && vItem.hashId == v.hashId) ||
                                (vItem.name == v.name)) {
                              return vItem.copyWith(isTodayAvailable: newVal);
                            }
                            return vItem;
                          }).toList();

                          final bool anyAvailable = updatedVariations.any(
                            (vItem) => vItem.isTodayAvailable == true,
                          );

                          final updatedItem = item.copyWith(
                            isTodayAvailable: anyAvailable,
                            variations: updatedVariations,
                          );

                          context.read<MenuItemBloc>().add(
                                UpdateMenuItem(updatedItem),
                              );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTileDetail(
                  context,
                  label: 'Selling Price',
                  value: v.sellingPrice != null
                      ? '\$${v.sellingPrice!.toStringAsFixed(2)}'
                      : 'N/A',
                  valueColor: colorScheme.primary,
                  isBold: true,
                ),
              ),
              Expanded(
                child: _buildTileDetail(
                  context,
                  label: 'Cost Price',
                  value: v.costPrice != null
                      ? '\$${v.costPrice!.toStringAsFixed(2)}'
                      : 'N/A',
                  valueColor: colorScheme.secondary,
                ),
              ),
              Expanded(
                child: _buildTileDetail(
                  context,
                  label: 'Stock',
                  value: v.stockQuantity != null ? '${v.stockQuantity}' : 'N/A',
                  valueColor: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (v.quantity != null || v.purchaseUnit != null || v.sortOrderIndex != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (v.quantity != null || v.purchaseUnit != null)
                  Expanded(
                    child: _buildTileDetail(
                      context,
                      label: 'Portion / Unit',
                      value: '${v.quantity ?? ''} ${v.purchaseUnit ?? ''}'.trim(),
                    ),
                  ),
                if (v.sortOrderIndex != null)
                  Expanded(
                    child: _buildTileDetail(
                      context,
                      label: 'Sort Index',
                      value: '#${v.sortOrderIndex}',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTileDetail(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? 'N/A' : value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
