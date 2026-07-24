import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_item_list_screen_actions.dart';
import 'widgets/menu_item_list_item.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_state.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';

import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
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
    return Scaffold(
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child:
                    BlocBuilder<
                      MenuCategoryFullListCubit,
                      MenuCategoryFullListState
                    >(
                      builder: (context, state) {
                        List<MenuCategory> categories = const [];
                        if (state is MenuCategoryFullListLoadedState) {
                          categories =
                              context
                                  .read<MenuCategoryFullListCubit>()
                                  .categoryList ??
                              [];
                        }
                        return DropdownButton<int?>(
                          isExpanded: true,
                          hint: Text(
                            context.tr(
                                  LocaleKeys.menuItemPageAllCategories,
                                  track: TrackConstants.menuItemPageTrack,
                                ) ??
                                'All Categories',
                          ),
                          value: _selectedCategoryIdNotifier.value,
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(
                                context.tr(
                                      LocaleKeys.menuItemPageAllCategories,
                                      track: TrackConstants.menuItemPageTrack,
                                    ) ??
                                    'All Categories',
                              ),
                            ),
                            ...categories.map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name ?? ''),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            _selectedCategoryIdNotifier.value = val;
                            _selectedSubcategoryIdNotifier.value = null;
                          },
                        );
                      },
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BlocBuilder<MenuSubcategoryBloc, MenuSubcategoryState>(
                  builder: (context, state) {
                    List<MenuSubcategory> subs = const [];
                    if (state is MenuSubcategoryLoaded &&
                        _selectedCategoryIdNotifier.value != null) {
                      subs = state.subcategories
                          .where(
                            (s) =>
                                s.categoryId ==
                                _selectedCategoryIdNotifier.value,
                          )
                          .toList();
                    }
                    return DropdownButton<int?>(
                      isExpanded: true,
                      hint: Text(
                        context.tr(
                              LocaleKeys.menuItemPageAllSubcategories,
                              track: TrackConstants.menuItemPageTrack,
                            ) ??
                            'All Subcategories',
                      ),
                      value: _selectedSubcategoryIdNotifier.value,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(
                            context.tr(
                                  LocaleKeys.menuItemPageAllSubcategories,
                                  track: TrackConstants.menuItemPageTrack,
                                ) ??
                                'All Subcategories',
                          ),
                        ),
                        ...subs.map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name ?? ''),
                          ),
                        ),
                      ],
                      onChanged: _selectedCategoryIdNotifier.value == null
                          ? null
                          : (val) {
                              _selectedSubcategoryIdNotifier.value = val;
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SearchBar(
            controller: _searchController,
            leading: const Icon(Icons.search),
            hintText:
                context.tr(
                  LocaleKeys.menuItemPageSearchItems,
                  track: TrackConstants.menuItemPageTrack,
                ) ??
                'Search dish...',
            onChanged: (val) {
              _searchQueryNotifier.value = val.toLowerCase();
            },
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchQueryNotifier.value = '';
                  },
                ),
            ],
          ),
        ),
        // List section
        Expanded(
          child: BlocBuilder<MenuItemBloc, MenuItemState>(
            builder: (context, state) {
              if (state is MenuItemLoading || state is MenuItemInitial) {
                return const Center(child: CircularProgressIndicator());
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
                            .map((e) => e.filterKey)
                            .toList();
                        if (!types.contains(item.foodType)) {
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
                  return Center(
                    child: Text(
                      context.tr(
                            LocaleKeys.menuItemPageNoMenuDishesFound,
                            track: TrackConstants.menuItemPageTrack,
                          ) ??
                          'No menu dishes found.',
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SlidableAutoCloseBehavior(
                      child: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = filteredItems[index];
                          return MenuItemListItem(
                            item: item,
                            index: index,
                            totalLength: filteredItems.length,
                          );
                        }, childCount: filteredItems.length),
                      ),
                    ),
                  ],
                );
              } else if (state is MenuItemError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
