import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

void showOrderFilterBottomSheet({
  required BuildContext context,
  required ValueNotifier<List<shared.AppliedFilterModel>> appliedFiltersNotifier,
  required void Function(List<shared.AppliedFilterModel> applied) onApply,
}) {
  final List<shared.FilterItemModel> statusFilterOptions = [
    shared.FilterItemModel(
      filterKey: 'all',
      filterTitle: context.tr(
            shared.LocaleKeys.orderManagementAllStatuses,
            track: shared.TrackConstants.orderManagementPageTrack,
          ) ??
          'All',
    ),
    shared.FilterItemModel(
      filterKey: 'newOrder',
      filterTitle: context.tr(
            shared.LocaleKeys.orderManagementOrderStatusNew,
            track: shared.TrackConstants.orderManagementPageTrack,
          ) ??
          'New',
    ),
    shared.FilterItemModel(
      filterKey: 'inProgress',
      filterTitle: context.tr(
            shared.LocaleKeys.orderManagementOrderStatusInProgress,
            track: shared.TrackConstants.orderManagementPageTrack,
          ) ??
          'In Progress',
    ),
    shared.FilterItemModel(
      filterKey: 'completed',
      filterTitle: context.tr(
            shared.LocaleKeys.orderManagementOrderStatusCompleted,
            track: shared.TrackConstants.orderManagementPageTrack,
          ) ??
          'Completed',
    ),
    shared.FilterItemModel(
      filterKey: 'cancelled',
      filterTitle: context.tr(
            shared.LocaleKeys.orderManagementOrderStatusCancelled,
            track: shared.TrackConstants.orderManagementPageTrack,
          ) ??
          'Cancelled',
    ),
  ];

  final appliedList = appliedFiltersNotifier.value
      .where((e) => e.filterKey == 'order_status')
      .expand((e) => e.applied)
      .toList();

  final List<shared.FilterItemModel> previousApplied = [];
  for (final item in appliedList) {
    final matched = statusFilterOptions.firstWhere(
      (opt) => opt.filterKey?.toLowerCase() == item.filterKey?.toLowerCase(),
      orElse: () => item,
    );
    previousApplied.add(matched);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return FractionallySizedBox(
        heightFactor: 0.8,
        child: shared.FilterWidget(
          filterProps: shared.FilterProps(
            title: context.tr(
                  shared.LocaleKeys.commonFilters,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Filters',
            onFilterChange: (applied) {
              appliedFiltersNotifier.value = applied;
              onApply(applied);
            },
            themeProps: shared.ThemeProps.defaultThemeProps(context),
            filters: [
              shared.FilterListModel(
                filterKey: 'order_status',
                title: context.tr(
                      shared.LocaleKeys.orderManagementFilterByStatus,
                      track: shared.TrackConstants.orderManagementPageTrack,
                    ) ??
                    'Order Status',
                type: shared.FilterType.radioGroup,
                previousApplied: previousApplied,
                filterOptions: statusFilterOptions,
              ),
            ],
          ),
        ),
      );
    },
  );
}
