import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';

class MenuItemCategoryFilterHeader extends StatelessWidget {
  final int? selectedCategoryId;
  final int? selectedSubcategoryId;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<int?> onSubcategoryChanged;

  const MenuItemCategoryFilterHeader({
    super.key,
    required this.selectedCategoryId,
    required this.selectedSubcategoryId,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCategorySelected = selectedCategoryId != null;
    final isSubcategorySelected = selectedSubcategoryId != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          // Category Dropdown Card
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

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isCategorySelected
                            ? theme.colorScheme.primaryContainer.withValues(
                                alpha: 0.35,
                              )
                            : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCategorySelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(
                                  alpha: 0.5,
                                ),
                          width: isCategorySelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 18,
                            color: isCategorySelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int?>(
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: isCategorySelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                hint: Text(
                                  context.tr(
                                        LocaleKeys.menuItemPageAllCategories,
                                        track: TrackConstants.menuItemPageTrack,
                                      ) ??
                                      'All Categories',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                value:
                                    (selectedCategoryId != null &&
                                        categories.any(
                                          (c) => c.id == selectedCategoryId,
                                        ))
                                    ? selectedCategoryId
                                    : null,
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      context.tr(
                                            LocaleKeys
                                                .menuItemPageAllCategories,
                                            track: TrackConstants
                                                .menuItemPageTrack,
                                          ) ??
                                          'All Categories',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  ...categories.map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(
                                        c.name ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: onCategoryChanged,
                              ),
                            ),
                          ),
                          if (isCategorySelected)
                            InkWell(
                              onTap: () => onCategoryChanged(null),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
          ),
          const SizedBox(width: 10),
          // Subcategory Dropdown Card
          Expanded(
            child: BlocBuilder<MenuSubcategoryBloc, MenuSubcategoryState>(
              builder: (context, state) {
                List<MenuSubcategory> subs = const [];
                if (state is MenuSubcategoryLoaded &&
                    selectedCategoryId != null) {
                  subs = state.subcategories
                      .where((s) => s.categoryId == selectedCategoryId)
                      .toList();
                }

                final bool isSubEnabled = selectedCategoryId != null;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSubcategorySelected
                        ? theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.35,
                          )
                        : (isSubEnabled
                              ? theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.4)
                              : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSubcategorySelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                      width: isSubcategorySelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.polyline_outlined,
                        size: 18,
                        color: isSubcategorySelected
                            ? theme.colorScheme.primary
                            : (isSubEnabled
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isSubcategorySelected
                                  ? theme.colorScheme.primary
                                  : (isSubEnabled
                                        ? theme.colorScheme.onSurfaceVariant
                                        : theme.colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.4)),
                            ),
                            hint: Text(
                              context.tr(
                                    LocaleKeys.menuItemPageAllSubcategories,
                                    track: TrackConstants.menuItemPageTrack,
                                  ) ??
                                  'All Subcategories',
                              style: TextStyle(
                                fontSize: 13,
                                color: isSubEnabled
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.4),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            value:
                                (selectedSubcategoryId != null &&
                                    subs.any(
                                      (s) => s.id == selectedSubcategoryId,
                                    ))
                                ? selectedSubcategoryId
                                : null,
                            items: [
                              DropdownMenuItem(
                                value: null,
                                child: Text(
                                  context.tr(
                                        LocaleKeys.menuItemPageAllSubcategories,
                                        track: TrackConstants.menuItemPageTrack,
                                      ) ??
                                      'All Subcategories',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              ...subs.map(
                                (s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(
                                    s.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: isSubEnabled
                                ? onSubcategoryChanged
                                : null,
                          ),
                        ),
                      ),
                      if (isSubcategorySelected)
                        InkWell(
                          onTap: () => onSubcategoryChanged(null),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
