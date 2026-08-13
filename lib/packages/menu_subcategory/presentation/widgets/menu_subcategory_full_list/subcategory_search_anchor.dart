import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class SubcategorySearchAnchor extends StatelessWidget {
  final SearchController searchController;
  final FocusNode searchFocusNode;
  final List<MenuSubcategory> subcategories;
  final List<MenuCategory> categories;
  final void Function(
    MenuSubcategory selectedSubcategory,
    List<MenuSubcategory> allSubcategories,
  )
  onResultSelected;

  const SubcategorySearchAnchor({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.subcategories,
    required this.categories,
    required this.onResultSelected,
  });

  (String subCatName, String catName) _parseNames(MenuSubcategory sub) {
    MenuCategory? category;
    for (final c in categories) {
      if (c.id == sub.categoryId) {
        category = c;
        break;
      }
    }

    String catName = category?.name ?? '';
    String subCatName = sub.name ?? '';

    if (catName.isNotEmpty && subCatName.startsWith('$catName - ')) {
      subCatName = subCatName.substring(catName.length + 3);
    } else if (subCatName.contains(' - ')) {
      final parts = subCatName.split(' - ');
      if (catName.isEmpty) {
        catName = parts[0];
      }
      subCatName = parts.sublist(1).join(' - ');
    }

    return (subCatName, catName);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SearchAnchor(
        searchController: searchController,
        isFullScreen: false,
        viewConstraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .35 < 220
              ? 220
              : MediaQuery.of(context).size.height * .35 > 220
              ? 250
              : MediaQuery.of(context).size.height * .35,
        ),
        builder: (BuildContext context, SearchController controller) {
          return Theme(
            data: Theme.of(context),
            child: SearchBar(
              controller: controller,
              focusNode: searchFocusNode,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 12.0),
              ),
              hintText:
                  context.tr(
                    shared.LocaleKeys.commonSearchHint,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Search...',
              leading: const Icon(Icons.search),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              trailing: [
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
              ],
            ),
          );
        },
        suggestionsBuilder:
            (BuildContext context, SearchController controller) {
              final keyword = controller.text.toLowerCase().trim();
              if (keyword.isEmpty) {
                return [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.commonSearchHint,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Type to search subcategories...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ];
              }

              final matches = subcategories.where((sub) {
                final rawName = sub.name?.toLowerCase() ?? '';
                final (subCatName, catName) = _parseNames(sub);
                return rawName.contains(keyword) ||
                    subCatName.toLowerCase().contains(keyword) ||
                    catName.toLowerCase().contains(keyword);
              }).toList();

              if (matches.isEmpty) {
                return [
                  ListTile(
                    leading: const Icon(Icons.search_off),
                    title: Text(
                      context.tr(
                            shared.LocaleKeys.noSubcategoriesFound,
                            track:
                                shared.TrackConstants.menuSubCategoryPageTrack,
                          ) ??
                          'No matching subcategories',
                    ),
                  ),
                ];
              }

              return matches.map((sub) {
                final (subCatName, catName) = _parseNames(sub);
                return ListTile(
                  leading: const Icon(Icons.subdirectory_arrow_right),
                  title: Text(
                    subCatName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: catName.isNotEmpty
                      ? Text(
                          catName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        )
                      : null,
                  onTap: () {
                    onResultSelected(sub, subcategories);
                  },
                );
              });
            },
      ),
    );
  }
}
