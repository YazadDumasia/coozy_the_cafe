import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:flutter/material.dart';

class CategoryDropdownAppBarTitle extends StatelessWidget {
  final List<Category> categories;
  final int selectedTabIndex;
  final ValueChanged<int> onCategorySelected;

  const CategoryDropdownAppBarTitle({
    super.key,
    required this.categories,
    required this.selectedTabIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      onSelected: onCategorySelected,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) {
        final menuItems = <PopupMenuEntry<int>>[];
        menuItems.add(
          PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 18,
                  color: selectedTabIndex == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 10),
                Text(
                  'CURRENT ORDER',
                  style: TextStyle(
                    fontWeight: selectedTabIndex == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectedTabIndex == 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
        menuItems.add(const PopupMenuDivider());

        for (int i = 0; i < categories.length; i++) {
          final catIndex = i + 1;
          final cat = categories[i];
          menuItems.add(
            PopupMenuItem<int>(
              value: catIndex,
              child: Text(
                cat.name ?? 'Category ${i + 1}',
                style: TextStyle(
                  fontWeight: selectedTabIndex == catIndex
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: selectedTabIndex == catIndex
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
        return menuItems;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'SELECT CATEGORY',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}
