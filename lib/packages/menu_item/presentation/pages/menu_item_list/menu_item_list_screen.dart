import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../widgets/menu_item_list/menu_item_category_filter_header.dart';
import '../../widgets/menu_item_list/menu_item_empty_view.dart';
import 'menu_item_list_screen_actions.dart';
import 'widget/menu_item_list_active_filters_row.dart';
import 'widget/menu_item_list_content_view.dart';
import 'widget/menu_item_list_filter_bottom_sheet.dart';
import 'widget/menu_item_list_search_bar.dart';

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
                  shared.LocaleKeys.homeDrawerMenuItemLabel,
                  track: shared.TrackConstants.homePageTrack,
                ) ??
                'Menu Items',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip:
                  context.tr(
                    shared.LocaleKeys.menuItemPageAddMenuItemAppbarTitle,
                    track: shared.TrackConstants.menuItemPageTrack,
                  ) ??
                  'Add Menu Item',
              onPressed: () =>
                  MenuItemListScreenActions.handleAddMenuItem(context),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip:
                  context.tr(
                    shared.LocaleKeys.commonFilter,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Filter',
              onPressed: () {
                showMenuItemFilterBottomSheet(
                  context: context,
                  appliedFiltersNotifier: _appliedFiltersNotifier,
                );
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
        MenuItemListSearchBar(
          controller: _searchController,
          onChanged: (val) {
            _searchQueryNotifier.value = val.toLowerCase();
          },
          onClear: () {
            _searchController.clear();
            _searchQueryNotifier.value = '';
          },
        ),
        MenuItemListActiveFiltersRow(
          selectedCategoryId: _selectedCategoryIdNotifier.value,
          selectedSubcategoryId: _selectedSubcategoryIdNotifier.value,
          searchQuery: _searchQueryNotifier.value,
          appliedFilters: _appliedFiltersNotifier.value,
          onClearCategory: () {
            _selectedCategoryIdNotifier.value = null;
            _selectedSubcategoryIdNotifier.value = null;
          },
          onClearSubcategory: () {
            _selectedSubcategoryIdNotifier.value = null;
          },
          onClearSearch: () {
            _searchController.clear();
            _searchQueryNotifier.value = '';
          },
          onRemoveAppliedFilterKey: (filterKey) {
            final current = List<shared.AppliedFilterModel>.from(
              _appliedFiltersNotifier.value,
            );
            current.removeWhere((f) => f.filterKey == filterKey);
            _appliedFiltersNotifier.value = current;
          },
          onClearAll: () {
            _selectedCategoryIdNotifier.value = null;
            _selectedSubcategoryIdNotifier.value = null;
            _searchController.clear();
            _searchQueryNotifier.value = '';
            _appliedFiltersNotifier.value = [];
          },
        ),
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

                return MenuItemListContentView(filteredItems: filteredItems);
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
}
