import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class OrderDateRangePickerBar extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;

  const OrderDateRangePickerBar({
    super.key,
    required this.selectedDateRange,
    required this.onPickDateRange,
    required this.onClearDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasRange = selectedDateRange != null;
    final startStr = hasRange
        ? DateUtil.dateToString(selectedDateRange!.start, DateUtil.dateFormat7)
        : '';
    final endStr = hasRange
        ? DateUtil.dateToString(selectedDateRange!.end, DateUtil.dateFormat7)
        : '';
    final label = hasRange
        ? '$startStr to $endStr'
        : (context.tr(
              shared.LocaleKeys.orderManagementSelectDateRange,
              track: shared.TrackConstants.orderManagementPageTrack,
            ) ??
            'Select Date Range');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hasRange
            ? colorScheme.primaryContainer.withAlpha(50)
            : colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasRange
              ? colorScheme.primary
              : colorScheme.outline.withAlpha(80),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            size: 20,
            color: hasRange ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: onPickDateRange,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasRange
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: hasRange ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          if (hasRange)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: context.tr(
                    shared.LocaleKeys.orderManagementClearDateRange,
                    track: shared.TrackConstants.orderManagementPageTrack,
                  ) ??
                  'Clear Date Range',
              onPressed: onClearDateRange,
            )
          else
            TextButton(
              onPressed: onPickDateRange,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.tr(
                      shared.LocaleKeys.orderManagementSelectDateRange,
                      track: shared.TrackConstants.orderManagementPageTrack,
                    ) ??
                    'Pick',
              ),
            ),
        ],
      ),
    );
  }
}
