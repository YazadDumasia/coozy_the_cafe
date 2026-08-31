import 'package:coozy_the_cafe/packages/database/src/database_dao/menu_items_dao.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/bloc/menu_item_picker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_item_picker_tile.dart';

class MenuItemSearchScreen extends StatefulWidget {
  const MenuItemSearchScreen({super.key});

  static Future<void> push(BuildContext context) {
    final bloc = context.read<MenuItemPickerBloc>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<MenuItemPickerBloc>.value(
          value: bloc,
          child: const MenuItemSearchScreen(),
        ),
      ),
    );
  }

  @override
  State<MenuItemSearchScreen> createState() => _MenuItemSearchScreenState();
}

class _MenuItemSearchScreenState extends State<MenuItemSearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    final blocQuery =
        context.read<MenuItemPickerBloc>().state is MenuItemPickerLoadedState
        ? (context.read<MenuItemPickerBloc>().state
                  as MenuItemPickerLoadedState)
              .searchQuery
        : '';
    _searchController = TextEditingController(text: blocQuery);
    _searchFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String query) {
    setState(() {});
    context.read<MenuItemPickerBloc>().add(
      FilterSearchQueryEvent(query.trim()),
    );
  }

  bool _matchesQuery(MenuItemWithVariations itemWithVar, String query) {
    if (query.isEmpty) return false;
    final q = query.toLowerCase();
    final item = itemWithVar.item;

    final nameMatch = item.name.toLowerCase().contains(q);
    final descMatch = item.description.toLowerCase().contains(q);
    final codeMatch = (item.quantity ?? '').toLowerCase().contains(q);
    final variationMatch = itemWithVar.variations.any(
      (v) => (v.name ?? '').toLowerCase().contains(q),
    );

    return nameMatch || descMatch || codeMatch || variationMatch;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appBarFgColor = Colors.white;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            decoration: InputDecoration(
              hintText:
                  context.tr(shared.LocaleKeys.searchDishNameHint, track: shared.TrackConstants.tablePageTrack) ??
                  'Search dish name...',
              hintStyle: theme.textTheme.titleMedium?.copyWith(
                color: appBarFgColor,
              ),
              border: InputBorder.none,

              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: appBarFgColor),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchQueryChanged('');
                      },
                    )
                  : null,
            ),
            style: theme.textTheme.titleMedium?.copyWith(color: appBarFgColor),
            onChanged: _onSearchQueryChanged,
          ),
        ),
        body: BlocBuilder<MenuItemPickerBloc, MenuItemPickerState>(
          builder: (context, state) {
            if (state is! MenuItemPickerLoadedState) {
              return const Center(child: CircularProgressIndicator());
            }

            final query = _searchController.text.trim();
            final catalogData = state.catalogData;

            // Collect all matching items with category details
            final List<_SearchResultItem> searchResults = [];

            for (final catData in catalogData.categoryDataList) {
              final catName = catData.category.name ?? 'Category';

              // 1. Uncategorized items under category
              for (final itemWithVar in catData.uncategorizedItems) {
                if (_matchesQuery(itemWithVar, query)) {
                  searchResults.add(
                    _SearchResultItem(
                      itemWithVariations: itemWithVar,
                      categoryId: catData.category.id,
                      categoryName: catName,
                    ),
                  );
                }
              }

              // 2. Subcategory items
              for (final subcat in catData.subcategories) {
                final subcatItems = catData.subcategoryItems[subcat.id] ?? [];
                for (final itemWithVar in subcatItems) {
                  if (_matchesQuery(itemWithVar, query)) {
                    searchResults.add(
                      _SearchResultItem(
                        itemWithVariations: itemWithVar,
                        categoryId: catData.category.id,
                        categoryName: catName,
                        subcategoryName: subcat.name,
                      ),
                    );
                  }
                }
              }
            }

            if (query.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr(shared.LocaleKeys.searchDishNameHint, track: shared.TrackConstants.tablePageTrack) ??
                            'Type dish name to search...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (searchResults.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: theme.colorScheme.error.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.tr(
                              shared.LocaleKeys.commonNoSearchResultFoundMsg,
                            ) ??
                            'No search result found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                final itemWithVar = result.itemWithVariations;
                final qty = state.getItemQuantityInCart(
                  itemWithVar.item.id,
                  null,
                );

                final subtitleText = result.subcategoryName != null
                    ? '${result.categoryName} • ${result.subcategoryName}'
                    : result.categoryName;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index == 0 ||
                        searchResults[index - 1].categoryName !=
                            result.categoryName) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 6,
                          top: 12,
                          bottom: 4,
                        ),
                        child: Text(
                          subtitleText.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                    MenuItemPickerTile(
                      itemWithVariations: itemWithVar,
                      quantityInCart: qty,
                      onAdd: () {
                        context.read<MenuItemPickerBloc>().add(
                          AddItemToCartEvent(
                            item: itemWithVar.item,
                            categoryId: result.categoryId,
                          ),
                        );
                      },
                      onRemove: () {
                        context.read<MenuItemPickerBloc>().add(
                          RemoveItemFromCartEvent(item: itemWithVar.item),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SearchResultItem {
  final MenuItemWithVariations itemWithVariations;
  final int categoryId;
  final String categoryName;
  final String? subcategoryName;

  _SearchResultItem({
    required this.itemWithVariations,
    required this.categoryId,
    required this.categoryName,
    this.subcategoryName,
  });
}
