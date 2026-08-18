import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_item_list_screen_actions.dart';
import '../../widgets/menu_item_list/menu_item_category_filter_header.dart';
import '../../widgets/menu_item_list/menu_item_empty_view.dart';
import '../../widgets/menu_item_list/menu_item_list_item.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_event.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_state.dart';

import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_state.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class MenuItemListScreen extends StatefulWidget {
  const MenuItemListScreen({super.key});

  @override
  State<MenuItemListScreen> createState() => _MenuItemListScreenState();
}

class _MenuItemListScreenState extends State<MenuItemListScreen> {
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier('');
  final ValueNotifier<int?> _selectedCategoryIdNotifier = ValueNotifier(null);
  final ValueNotifier<int?> _selectedSubcategoryIdNotifier = ValueNotifier(
    null,
  );
  final SearchController _searchController = SearchController();
  final ValueNotifier<List<shared.AppliedFilterModel>> _appliedFiltersNotifier =
      ValueNotifier([]);

  @override
  void dispose() {
    _selectedCategoryIdNotifier.dispose();
    _selectedSubcategoryIdNotifier.dispose();
    _searchQueryNotifier.dispose();
    _searchController.dispose();
    _appliedFiltersNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
                  LocaleKeys.homeDrawerMenuItemLabel,
                  track: TrackConstants.homePageTrack,
                ) ??
                'Menu Items',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip:
                  context.tr(
                    LocaleKeys.menuItemPageAddMenuItemAppbarTitle,
                    track: TrackConstants.menuItemPageTrack,
                  ) ??
                  'Add Menu Item',
              onPressed: () =>
                  MenuItemListScreenActions.handleAddMenuItem(context),
            ),
            IconButton(
              icon: Icon(Icons.filter_list),
              tooltip:
                  context.tr(
                    shared.LocaleKeys.commonFilter,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Filter',
              onPressed: () {
                _showFilterBottomSheet(context);
              },
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([
            _selectedCategoryIdNotifier,
            _selectedSubcategoryIdNotifier,
            _searchQueryNotifier,
            _appliedFiltersNotifier,
          ]),
          builder: (context, _) {
            return _buildBody(context);
          },
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
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
                _appliedFiltersNotifier.value = applied;
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
                  previousApplied: _appliedFiltersNotifier.value
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
                  previousApplied: _appliedFiltersNotifier.value
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

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        MenuItemCategoryFilterHeader(
          selectedCategoryId: _selectedCategoryIdNotifier.value,
          selectedSubcategoryId: _selectedSubcategoryIdNotifier.value,
          onCategoryChanged: (val) {
            _selectedCategoryIdNotifier.value = val;
            _selectedSubcategoryIdNotifier.value = null;
          },
          onSubcategoryChanged: (val) {
            _selectedSubcategoryIdNotifier.value = val;
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: SearchBar(
            controller: _searchController,
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
            leading: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            hintText:
                context.tr(
                  LocaleKeys.menuItemPageSearchItems,
                  track: TrackConstants.menuItemPageTrack,
                ) ??
                'Search dish...',
            hintStyle: WidgetStateProperty.all(
              TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            onChanged: (val) {
              _searchQueryNotifier.value = val.toLowerCase();
            },
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _searchQueryNotifier.value = '';
                  },
                ),
            ],
          ),
        ),
        _buildActiveFiltersRow(context),
        // List section
        Expanded(
          child: BlocBuilder<MenuItemBloc, MenuItemState>(
            builder: (context, state) {
              if (state is MenuItemLoading || state is MenuItemInitial) {
                return const shared.LoadingPage();
              } else if (state is MenuItemLoaded) {
                var filteredItems = state.items.where((item) {
                  if (_selectedCategoryIdNotifier.value != null &&
                      item.categoryId != _selectedCategoryIdNotifier.value) {
                    return false;
                  }
                  if (_selectedSubcategoryIdNotifier.value != null &&
                      item.subcategoryId !=
                          _selectedSubcategoryIdNotifier.value) {
                    return false;
                  }
                  if (_searchQueryNotifier.value.isNotEmpty &&
                      !(item.name).toLowerCase().contains(
                        _searchQueryNotifier.value,
                      )) {
                    return false;
                  }

                  if (_appliedFiltersNotifier.value.isNotEmpty) {
                    for (var appliedFilter in _appliedFiltersNotifier.value) {
                      if (appliedFilter.filterKey == 'food_type' &&
                          appliedFilter.applied.isNotEmpty) {
                        var types = appliedFilter.applied
                            .map((e) => e.filterKey.toLowerCase())
                            .toList();
                        final itemFoodType = (item.foodType ?? '')
                            .toLowerCase();
                        bool matches = types.any((t) {
                          if (t == itemFoodType) return true;
                          if (t == 'veg' &&
                              (itemFoodType == 'vegetarian' ||
                                  itemFoodType == 'veg')) {
                            return true;
                          }
                          if (t == 'non-veg' &&
                              (itemFoodType == 'non-vegetarian' ||
                                  itemFoodType == 'non_vegetarian' ||
                                  itemFoodType == 'non-veg')) {
                            return true;
                          }
                          if (t == 'egg' &&
                              (itemFoodType == 'egg' ||
                                  itemFoodType == 'ovo-vegetarian')) {
                            return true;
                          }
                          return false;
                        });
                        if (!matches) {
                          return false;
                        }
                      }
                      if (appliedFilter.filterKey == 'availability' &&
                          appliedFilter.applied.isNotEmpty) {
                        var keys = appliedFilter.applied
                            .map((e) => e.filterKey)
                            .toList();
                        if (keys.contains('true') && keys.contains('false')) {
                          // both selected, ignore
                        } else if (keys.contains('true')) {
                          if (item.isTodayAvailable != true) return false;
                        } else if (keys.contains('false')) {
                          if (item.isTodayAvailable == true) return false;
                        }
                      }
                    }
                  }
                  return true;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const MenuItemEmptyView();
                }

                final bool isTablet = shared.ResponsiveLayout.isTablet(context);
                final bool isDesktop = shared.ResponsiveLayout.isDesktop(
                  context,
                );

                if (isTablet || isDesktop) {
                  return SlidableAutoCloseBehavior(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isDesktop ? 450 : 550,
                        mainAxisExtent: 175,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return MenuItemListItem(
                          item: item,
                          index: index,
                          totalLength: filteredItems.length,
                        );
                      },
                    ),
                  );
                }

                return SlidableAutoCloseBehavior(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return MenuItemListItem(
                        item: item,
                        index: index,
                        totalLength: filteredItems.length,
                      );
                    },
                  ),
                );
              } else if (state is MenuItemError) {
                return shared.ErrorPage(
                  onPressedRetryButton: () {
                    context.read<MenuItemBloc>().add(LoadMenuItems());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersRow(BuildContext context) {
    final bool hasCategory = _selectedCategoryIdNotifier.value != null;
    final bool hasSubcategory = _selectedSubcategoryIdNotifier.value != null;
    final bool hasSearch = _searchQueryNotifier.value.isNotEmpty;
    final bool hasBottomSheetFilters = _appliedFiltersNotifier.value.isNotEmpty;

    if (!hasCategory &&
        !hasSubcategory &&
        !hasSearch &&
        !hasBottomSheetFilters) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final List<Widget> chips = [];

    if (hasCategory) {
      String catName = 'Category';
      final catState = context.read<MenuCategoryFullListCubit>().state;
      if (catState is MenuCategoryFullListLoadedState) {
        final list =
            context.read<MenuCategoryFullListCubit>().categoryList ?? [];
        for (final c in list) {
          if (c.id == _selectedCategoryIdNotifier.value) {
            if (c.name != null && c.name!.isNotEmpty) {
              catName = c.name!;
            }
            break;
          }
        }
      }
      chips.add(
        InputChip(
          label: Text(catName, style: const TextStyle(fontSize: 12)),
          selected: true,
          showCheckmark: false,
          avatar: const Icon(Icons.category_outlined, size: 14),
          onDeleted: () {
            _selectedCategoryIdNotifier.value = null;
            _selectedSubcategoryIdNotifier.value = null;
          },
        ),
      );
    }

    if (hasSubcategory) {
      String subName = 'Subcategory';
      final subState = context.read<MenuSubcategoryBloc>().state;
      if (subState is MenuSubcategoryLoaded) {
        for (final s in subState.subcategories) {
          if (s.id == _selectedSubcategoryIdNotifier.value) {
            if (s.name != null && s.name!.isNotEmpty) {
              subName = s.name!;
            }
            break;
          }
        }
      }
      chips.add(
        InputChip(
          label: Text(subName, style: const TextStyle(fontSize: 12)),
          selected: true,
          showCheckmark: false,
          avatar: const Icon(Icons.polyline_outlined, size: 14),
          onDeleted: () {
            _selectedSubcategoryIdNotifier.value = null;
          },
        ),
      );
    }

    if (hasSearch) {
      chips.add(
        InputChip(
          label: Text(
            '"${_searchQueryNotifier.value}"',
            style: const TextStyle(fontSize: 12),
          ),
          selected: true,
          showCheckmark: false,
          avatar: const Icon(Icons.search, size: 14),
          onDeleted: () {
            _searchController.clear();
            _searchQueryNotifier.value = '';
          },
        ),
      );
    }

    for (final filter in _appliedFiltersNotifier.value) {
      for (final item in filter.applied) {
        chips.add(
          InputChip(
            label: Text(item.filterTitle, style: const TextStyle(fontSize: 12)),
            selected: true,
            showCheckmark: false,
            avatar: const Icon(Icons.tune, size: 14),
            onDeleted: () {
              final current = List<shared.AppliedFilterModel>.from(
                _appliedFiltersNotifier.value,
              );
              current.removeWhere((f) => f.filterKey == filter.filterKey);
              _appliedFiltersNotifier.value = current;
            },
          ),
        );
      }
    }

    chips.add(
      ActionChip(
        label: const Text(
          'Clear All',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        avatar: Icon(
          Icons.refresh_rounded,
          size: 14,
          color: theme.colorScheme.primary,
        ),
        onPressed: () {
          _selectedCategoryIdNotifier.value = null;
          _selectedSubcategoryIdNotifier.value = null;
          _searchController.clear();
          _searchQueryNotifier.value = '';
          _appliedFiltersNotifier.value = [];
        },
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips
              .map(
                (c) =>
                    Padding(padding: const EdgeInsets.only(right: 6), child: c),
              )
              .toList(),
        ),
      ),
    );
  }
}
