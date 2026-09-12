import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class InvoiceListActiveFiltersRow extends StatelessWidget {
  final List<shared.AppliedFilterModel> appliedFilters;
  final ValueChanged<String> onRemoveAppliedFilterKey;
  final VoidCallback onClearAll;

  const InvoiceListActiveFiltersRow({
    super.key,
    required this.appliedFilters,
    required this.onRemoveAppliedFilterKey,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (appliedFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Widget> chips = [];

    for (final filter in appliedFilters) {
      for (final item in filter.applied) {
        chips.add(
          InputChip(
            label: Text(
              item.filterTitle,
              style: const TextStyle(fontSize: 12),
            ),
            selected: true,
            showCheckmark: false,
            avatar: const Icon(Icons.tune, size: 14),
            deleteButtonTooltipMessage: context.tr(
                  shared.LocaleKeys.commonDelete,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Remove',
            onDeleted: () => onRemoveAppliedFilterKey(item.filterKey),
          ),
        );
      }
    }

    if (chips.isNotEmpty) {
      chips.add(
        ActionChip(
          tooltip: context.tr(
                shared.LocaleKeys.commonReset,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Clear All',
          label: Text(
            context.tr(
                  shared.LocaleKeys.commonReset,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Clear All',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          avatar: Icon(
            Icons.clear_all_rounded,
            size: 14,
            color: colorScheme.error,
          ),
          onPressed: onClearAll,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips
              .map(
                (chip) => Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: chip,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
