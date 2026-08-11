import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';

class SubcategoryCategoryHorizontalBar extends StatelessWidget {
  final List<MenuCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  const SubcategoryCategoryHorizontalBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: colorScheme.surfaceContainerLow,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          final bool isAll = index == 0;
          final int? catId = isAll ? null : categories[index - 1].id;
          final String label = isAll
              ? 'All'
              : (categories[index - 1].name ?? '');
          final bool isSelected = selectedCategoryId == catId;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(label),
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              selectedColor: colorScheme.primary,
              backgroundColor: colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              onSelected: (_) => onCategorySelected(catId),
            ),
          );
        },
      ),
    );
  }
}
