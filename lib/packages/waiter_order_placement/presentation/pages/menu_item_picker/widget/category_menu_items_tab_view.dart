import 'package:coozy_the_cafe/packages/database/src/database_dao/menu_items_dao.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_item_picker_tile.dart';
import 'subcategory_header_widget.dart';

class CategoryMenuItemsTabView extends StatelessWidget {
  final MenuCatalogCategoryData categoryData;
  final String searchQuery;
  final VoidCallback? onReviewOrder;

  const CategoryMenuItemsTabView({
    super.key,
    required this.categoryData,
    required this.searchQuery,
    this.onReviewOrder,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 40.0;
    const EdgeInsets contentPadding = EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 8.0,
    );
    const double horizontalPadding = 10.0;
    final state = context.watch<MenuItemPickerBloc>().state;
    final loadedState = state is MenuItemPickerLoadedState ? state : null;

    final subcategories = categoryData.subcategories;
    final subcatMap = categoryData.subcategoryItems;
    final uncategorizedItems = categoryData.uncategorizedItems;

    // Filter items based on search query
    bool matchesSearch(MenuItemWithVariations itemWithVar) {
      final q = searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;

      final item = itemWithVar.item;
      final nameMatch = item.name.toLowerCase().contains(q);
      final descMatch = item.description.toLowerCase().contains(q);
      final codeMatch = (item.quantity ?? '').toLowerCase().contains(q);
      final variationMatch = itemWithVar.variations.any(
        (v) => (v.name ?? '').toLowerCase().contains(q),
      );

      return nameMatch || descMatch || codeMatch || variationMatch;
    }

    final filteredUncategorized = uncategorizedItems
        .where(matchesSearch)
        .toList();

    // Check if category has any content
    bool hasAnyItems = filteredUncategorized.isNotEmpty;
    for (final subcat in subcategories) {
      final items = (subcatMap[subcat.id] ?? []).where(matchesSearch).toList();
      if (items.isNotEmpty) {
        hasAnyItems = true;
        break;
      }
    }

    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Column(
      children: [
        Expanded(
          child: !hasAnyItems
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.noItemsAvailableInCategoryMsg,
                          ) ??
                          'No items available in this category',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: contentPadding,
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
                        if ((subcatMap[subcat.id] ?? [])
                            .where(matchesSearch)
                            .isNotEmpty) ...[
                          SubcategoryHeaderWidget(
                            title: subcat.name ?? 'Subcategory',
                          ),
                          _buildItemsListView(
                            context: context,
                            items: (subcatMap[subcat.id] ?? [])
                                .where(matchesSearch)
                                .toList(),
                            loadedState: loadedState,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
        ),

        // Bottom "Review Order" Button Container
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isLandscape ? 8 : 12,
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      onPressed: onReviewOrder,
                      child: Text(
                        context.tr(shared.LocaleKeys.reviewOrderBtnText) ??
                            'Review Order',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        final qty =
            loadedState?.getItemQuantityInCart(itemWithVar.item.id, null) ?? 0;
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
              RemoveItemFromCartEvent(item: itemWithVar.item),
            );
          },
        );
      },
    );
  }
}
