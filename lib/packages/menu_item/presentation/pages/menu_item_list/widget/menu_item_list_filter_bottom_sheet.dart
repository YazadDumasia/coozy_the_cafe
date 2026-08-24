import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

void showMenuItemFilterBottomSheet({
  required BuildContext context,
  required ValueNotifier<List<shared.AppliedFilterModel>>
  appliedFiltersNotifier,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return FractionallySizedBox(
        heightFactor: 0.8,
        child: shared.FilterWidget(
          filterProps: shared.FilterProps(
            title:
                context.tr(
                  shared.LocaleKeys.commonFilters,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Filters',
            onFilterChange: (applied) {
              appliedFiltersNotifier.value = applied;
            },
            filters: [
              shared.FilterListModel(
                filterKey: 'food_type',
                title:
                    context.tr(
                      shared.LocaleKeys.menuItemFoodType,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Food Type',
                type: shared.FilterType.checkboxList,
                previousApplied: appliedFiltersNotifier.value
                    .where((e) => e.filterKey == 'food_type')
                    .expand((e) => e.applied)
                    .toList(),
                filterOptions: [
                  shared.FilterItemModel(
                    filterKey: 'Veg',
                    filterTitle:
                        context.tr(
                          shared.LocaleKeys.menuItemPageFoodTypeVegetarian,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Vegetarian',
                  ),
                  shared.FilterItemModel(
                    filterKey: 'Non-Veg',
                    filterTitle:
                        context.tr(
                          shared.LocaleKeys.menuItemPageFoodTypeNonVegetarian,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Non-Vegetarian',
                  ),
                  shared.FilterItemModel(
                    filterKey: 'Egg',
                    filterTitle:
                        context.tr(
                          shared.LocaleKeys.menuItemPageFoodTypeEgg,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Egg',
                  ),
                  shared.FilterItemModel(
                    filterKey: 'Vegan',
                    filterTitle:
                        context.tr(
                          shared.LocaleKeys.menuItemPageFoodTypeVegan,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Vegan',
                  ),
                ],
              ),
              shared.FilterListModel(
                filterKey: 'availability',
                title:
                    context.tr(
                      shared.LocaleKeys.menuItemAvailability,
                      track: shared.TrackConstants.menuItemPageTrack,
                    ) ??
                    'Availability',
                type: shared.FilterType.checkboxList,
                previousApplied: appliedFiltersNotifier.value
                    .where((e) => e.filterKey == 'availability')
                    .expand((e) => e.applied)
                    .toList(),
                filterOptions: [
                  shared.FilterItemModel(
                    filterKey: 'true',
                    filterTitle:
                        context.tr(
                          shared.LocaleKeys.todayAvailable,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Today Available',
                  ),
                  shared.FilterItemModel(
                    filterKey: 'false',
                    filterTitle:
                        context.tr(
                          shared.LocaleKeys.notAvailable,
                          track: shared.TrackConstants.menuItemPageTrack,
                        ) ??
                        'Not Available',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
