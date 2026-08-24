import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class MenuItemListActiveFiltersRow extends StatelessWidget {
  final int? selectedCategoryId;
  final int? selectedSubcategoryId;
  final String searchQuery;
  final List<shared.AppliedFilterModel> appliedFilters;
  final VoidCallback onClearCategory;
  final VoidCallback onClearSubcategory;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onRemoveAppliedFilterKey;
  final VoidCallback onClearAll;

  const MenuItemListActiveFiltersRow({
    super.key,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.searchQuery,
    required this.appliedFilters,
    required this.onClearCategory,
    required this.onClearSubcategory,
    required this.onClearSearch,
    required this.onRemoveAppliedFilterKey,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCategory = selectedCategoryId != null;
    final bool hasSubcategory = selectedSubcategoryId != null;
    final bool hasSearch = searchQuery.isNotEmpty;
    final bool hasBottomSheetFilters = appliedFilters.isNotEmpty;

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
          if (c.id == selectedCategoryId) {
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
          onDeleted: onClearCategory,
        ),
      );
    }

    if (hasSubcategory) {
      String subName = 'Subcategory';
      final subState = context.read<MenuSubcategoryBloc>().state;
      if (subState is MenuSubcategoryLoaded) {
        for (final s in subState.subcategories) {
          if (s.id == selectedSubcategoryId) {
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
          onDeleted: onClearSubcategory,
        ),
      );
    }

    if (hasSearch) {
      chips.add(
        InputChip(
          label: Text('"$searchQuery"', style: const TextStyle(fontSize: 12)),
          selected: true,
          showCheckmark: false,
          avatar: const Icon(Icons.search, size: 14),
          onDeleted: onClearSearch,
        ),
      );
    }

    for (final filter in appliedFilters) {
      for (final item in filter.applied) {
        chips.add(
          InputChip(
            label: Text(item.filterTitle, style: const TextStyle(fontSize: 12)),
            selected: true,
            showCheckmark: false,
            avatar: const Icon(Icons.tune, size: 14),
            onDeleted: () => onRemoveAppliedFilterKey(filter.filterKey),
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
        onPressed: onClearAll,
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
