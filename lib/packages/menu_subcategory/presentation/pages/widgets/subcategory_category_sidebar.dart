import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';

class SubcategoryCategorySidebar extends StatelessWidget {
  final List<MenuCategory> categories;
  final int? selectedCategoryId;
  final ScrollController scrollController;
  final ValueChanged<int?> onCategorySelected;

  const SubcategoryCategorySidebar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.scrollController,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return _SidebarTile(
              label: 'All',
              isSelected: isSelected,
              onTap: () => onCategorySelected(null),
            );
          }
          final cat = categories[index - 1];
          final isSelected = selectedCategoryId == cat.id;
          return _SidebarTile(
            label: cat.name ?? '',
            isSelected: isSelected,
            onTap: () => onCategorySelected(cat.id),
          );
        },
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
