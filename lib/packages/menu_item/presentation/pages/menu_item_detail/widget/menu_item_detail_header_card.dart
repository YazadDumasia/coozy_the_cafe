import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'menu_item_food_type_badge.dart';

class MenuItemDetailHeaderCard extends StatelessWidget {
  final MenuItem item;
  final String? categoryName;
  final String? subcategoryName;

  const MenuItemDetailHeaderCard({
    super.key,
    required this.item,
    this.categoryName,
    this.subcategoryName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAvailable = item.isTodayAvailable ?? true;

    return Card(
      elevation: 2,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MenuItemFoodTypeBadge(foodType: item.foodType),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (item.duration != null && item.duration! > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.duration} mins prep',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (categoryName != null && categoryName!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        subcategoryName != null && subcategoryName!.isNotEmpty
                            ? '$categoryName  >  $subcategoryName'
                            : categoryName!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? colorScheme.primaryContainer
                            : colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isAvailable
                            ? Icons.check_circle_outline
                            : Icons.block_outlined,
                        size: 18,
                        color: isAvailable
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                                shared.LocaleKeys.statusLabel,
                                track: shared.TrackConstants.menuItemPageTrack,
                              ) ??
                              'Status',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          isAvailable
                              ? (context.tr(
                                      shared.LocaleKeys.todayAvailable,
                                      track: shared
                                          .TrackConstants
                                          .menuItemPageTrack,
                                    ) ??
                                    'Today Available')
                              : (context.tr(
                                      shared.LocaleKeys.notAvailable,
                                      track: shared
                                          .TrackConstants
                                          .menuItemPageTrack,
                                    ) ??
                                    'Not Available'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAvailable
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: isAvailable,
                  thumbIcon: WidgetStateProperty.resolveWith<Icon?>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Icon(Icons.check, color: Colors.green);
                    }
                    return Icon(Icons.close, color: colorScheme.error);
                  }),
                  onChanged: (bool newVal) {
                    final updatedVariations = item.variations
                        .map((v) => v.copyWith(isTodayAvailable: newVal))
                        .toList();
                    final updatedItem = item.copyWith(
                      isTodayAvailable: newVal,
                      variations: updatedVariations,
                    );
                    context.read<MenuItemBloc>().add(
                      UpdateMenuItem(updatedItem),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
