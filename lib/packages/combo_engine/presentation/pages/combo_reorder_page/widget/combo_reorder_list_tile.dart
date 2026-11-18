import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../../domain/entities/combo.dart';

class ComboReorderListTile extends StatelessWidget {
  final Combo combo;
  final int displayIndex;
  final bool isDragging;

  const ComboReorderListTile({
    super.key,
    required this.combo,
    required this.displayIndex,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final discountPct = combo.discountPercentage;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: isDragging ? 0.8 : 0.4,
          ),
          width: isDragging ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order number badge
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$displayIndex',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Leading icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: combo.isActive
                    ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.fastfood_rounded,
                size: 20,
                color: combo.isActive
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        title: Text(
          combo.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          softWrap: true,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                core.CurrencyFormatter.format(value: combo.sellingPrice),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                '•',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              Text(
                context.tr(
                      shared.LocaleKeys.comboFormDialogSuccessItemsCount,
                      track: shared.TrackConstants.comboPageTrack,
                      params: {'count': '${combo.items.length}'},
                    ) ??
                    '${combo.items.length} items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              if (discountPct > 0) ...[
                Text(
                  '•',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.comboListCardBadgeOff,
                          track: shared.TrackConstants.comboPageTrack,
                          params: {'percent': discountPct.toStringAsFixed(0)},
                        ) ??
                        '${discountPct.toStringAsFixed(0)}% OFF',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              if (combo.effectiveDuration != null &&
                  combo.effectiveDuration! > 0) ...[
                Text(
                  '•',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${combo.effectiveDuration}m',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        trailing: isDragging
            ? const SizedBox(width: 38, height: 38)
            : Tooltip(
                message:
                    context.tr(
                      shared.LocaleKeys.comboReorderPageTooltipDragHandle,
                      track: shared.TrackConstants.comboPageTrack,
                    ) ??
                    'Drag to reorder',
                child: ReorderableDragStartListener(
                  index: displayIndex - 1,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
