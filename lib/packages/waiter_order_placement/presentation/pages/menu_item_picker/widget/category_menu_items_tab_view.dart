import 'package:coozy_the_cafe/packages/database/src/database_dao/menu_items_dao.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_item_picker_tile.dart';
import 'subcategory_header_widget.dart';

class CategoryMenuItemsTabView extends StatelessWidget {
  final MenuCatalogCategoryData categoryData;
  final String searchQuery;

  const CategoryMenuItemsTabView({
    super.key,
    required this.categoryData,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MenuItemPickerBloc>().state;
    final loadedState = state is MenuItemPickerLoadedState ? state : null;

    final subcategories = categoryData.subcategories;
    final subcatMap = categoryData.subcategoryItems;
    final uncategorizedItems = categoryData.uncategorizedItems;

    // Filter items based on search query
    bool matchesSearch(MenuItemWithVariations itemWithVar) {
      if (searchQuery.isEmpty) return true;
      return itemWithVar.item.name.toLowerCase().contains(searchQuery.toLowerCase());
    }

    final filteredUncategorized = uncategorizedItems.where(matchesSearch).toList();

    // Check if category has any content
    bool hasAnyItems = filteredUncategorized.isNotEmpty;
    for (final subcat in subcategories) {
      final items = (subcatMap[subcat.id] ?? []).where(matchesSearch).toList();
      if (items.isNotEmpty) {
        hasAnyItems = true;
        break;
      }
    }

    if (!hasAnyItems) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No items available in this category',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Uncategorized items under this category
          if (filteredUncategorized.isNotEmpty) ...[
            _buildItemsListView(
              context: context,
              items: filteredUncategorized,
              loadedState: loadedState,
            ),
          ],

          // 2. Subcategories with subheaders and items
          for (final subcat in subcategories) ...[
            if ((subcatMap[subcat.id] ?? []).where(matchesSearch).isNotEmpty) ...[
              SubcategoryHeaderWidget(title: subcat.name ?? 'Subcategory'),
              _buildItemsListView(
                context: context,
                items: (subcatMap[subcat.id] ?? []).where(matchesSearch).toList(),
                loadedState: loadedState,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildItemsListView({
    required BuildContext context,
    required List<MenuItemWithVariations> items,
    required MenuItemPickerLoadedState? loadedState,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final itemWithVar = items[index];
        final qty = loadedState?.getItemQuantityInCart(itemWithVar.item.id, null) ?? 0;
        return MenuItemPickerTile(
          itemWithVariations: itemWithVar,
          quantityInCart: qty,
          onAdd: () {
            context.read<MenuItemPickerBloc>().add(
                  AddItemToCartEvent(
                    item: itemWithVar.item,
                    categoryId: categoryData.category.id,
                  ),
                );
          },
          onRemove: () {
            context.read<MenuItemPickerBloc>().add(
                  RemoveItemFromCartEvent(
                    item: itemWithVar.item,
                  ),
                );
          },
        );
      },
    );
  }
}
