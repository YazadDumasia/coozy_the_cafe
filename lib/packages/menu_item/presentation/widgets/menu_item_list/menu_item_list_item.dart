import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_state.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_item/presentation/bloc/menu_item_event.dart';
import '../../pages/menu_item_list/menu_item_list_screen_actions.dart';

class MenuItemListItem extends StatelessWidget {
  final MenuItem item;
  final int index;
  final int totalLength;

  const MenuItemListItem({
    super.key,
    required this.item,
    required this.index,
    required this.totalLength,
  });

  @override
  Widget build(BuildContext context) {
    String? categoryName;
    String? subcategoryName;

    final catState = context.watch<MenuCategoryFullListCubit>().state;
    if (catState is MenuCategoryFullListLoadedState) {
      final categories =
          context.read<MenuCategoryFullListCubit>().categoryList ?? [];
      for (final c in categories) {
        if (c.id == item.categoryId) {
          categoryName = c.name;
          break;
        }
      }
    }

    final subState = context.watch<MenuSubcategoryBloc>().state;
    if (subState is MenuSubcategoryLoaded) {
      for (final s in subState.subcategories) {
        if (s.id == item.subcategoryId) {
          subcategoryName = s.name;
          break;
        }
      }
    }

    final theme = Theme.of(context);
    final bool isMasterAvailable = item.isTodayAvailable ?? true;
    final bool isSimple = item.isSimpleVariation ?? true;

    final bool isTabletOrDesktop =
        shared.ResponsiveLayout.isTablet(context) ||
        shared.ResponsiveLayout.isDesktop(context);

    return Padding(
      padding: isTabletOrDesktop
          ? EdgeInsets.zero
          : EdgeInsets.only(
              left: 16,
              right: 16,
              top: index == 0 ? 8 : 4,
              bottom: index == totalLength - 1 ? 16 : 4,
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          key: ValueKey('item_${item.id}'),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) =>
                    MenuItemListScreenActions.handleEditMenuItem(context, item),
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label:
                    context.tr(
                      shared.LocaleKeys.commonEdit,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Edit',
              ),
              SlidableAction(
                onPressed: (context) =>
                    MenuItemListScreenActions.handleDeleteMenuItem(
                      context,
                      item,
                    ),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label:
                    context.tr(
                      shared.LocaleKeys.commonDelete,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Delete',
              ),
            ],
          ),
          child: Card(
            elevation: 1.5,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(80),
                width: 1,
              ),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              childrenPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              collapsedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              title: Row(
                children: [
                  _buildFoodTypeIndicator(item.foodType),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCategoryBreadcrumb(
                      context,
                      categoryName,
                      subcategoryName,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.menuItemPageTypes,
                                  track:
                                      shared.TrackConstants.menuItemPageTrack,
                                  params: {
                                    "foodType":
                                        item.foodType ??
                                        context.tr(
                                          shared.LocaleKeys.commonUnknown,
                                          track:
                                              shared.TrackConstants.commonTrack,
                                        ) ??
                                        'Unknown',
                                  },
                                ) ??
                                'Type: ${item.foodType ?? 'Unknown'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isMasterAvailable ? 'Available' : 'Unavailable',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isMasterAvailable
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              height: 24,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Switch.adaptive(
                                  value: isMasterAvailable,
                                  onChanged: (bool newVal) {
                                    final updatedVariations = item.variations
                                        .map((v) {
                                          return v.copyWith(
                                            isTodayAvailable: newVal,
                                          );
                                        })
                                        .toList();
                                    final updatedItem = item.copyWith(
                                      isTodayAvailable: newVal,
                                      variations: updatedVariations,
                                    );
                                    context.read<MenuItemBloc>().add(
                                      UpdateMenuItem(updatedItem),
                                    );
                                  },
                                  thumbIcon:
                                      WidgetStateProperty.resolveWith<Icon>((
                                        states,
                                      ) {
                                        if (states.contains(
                                          WidgetState.selected,
                                        )) {
                                          return const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          );
                                        }
                                        return const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        );
                                      }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              children: [
                _buildVariationsSection(context, item.variations, isSimple),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodTypeIndicator(String? foodType) {
    final ft = (foodType ?? '').toLowerCase();
    Color color;
    IconData? iconData;
    if (ft.contains('non') || ft.contains('meat') || ft.contains('chicken')) {
      color = Colors.red.shade700;
    } else if (ft.contains('egg')) {
      color = Colors.amber.shade800;
    } else if (ft.contains('vegan')) {
      color = Colors.teal.shade700;
      iconData = Icons.eco;
    } else {
      color = Colors.green.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: iconData != null
          ? Icon(iconData, size: 10, color: color)
          : Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
    );
  }

  Widget _buildCategoryBreadcrumb(
    BuildContext context,
    String? categoryName,
    String? subcategoryName,
  ) {
    if (categoryName == null || categoryName.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(isDark ? 80 : 160),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category_outlined,
            size: 12,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!shared.ResponsiveLayout.isMobile(context) &&
              subcategoryName != null &&
              subcategoryName.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '›',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer.withAlpha(180),
                ),
              ),
            ),
            Flexible(
              child: Text(
                subcategoryName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onPrimaryContainer.withAlpha(220),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariationsSection(
    BuildContext context,
    List<MenuItemVariation> variations,
    bool isSimple,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(
          isDark ? 100 : 180,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Variations (${variations.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (variations.isEmpty)
            Text(
              'No variations defined',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Column(
              children: variations.map((v) {
                final nameStr = v.name?.trim() ?? '';
                final qtyStr = v.quantity != null ? '${v.quantity}' : '';
                final unitStr = v.purchaseUnit ?? '';
                final portionLabel = [
                  qtyStr,
                  unitStr,
                ].where((s) => s.isNotEmpty).join(' ');
                final displayTitle = nameStr.isNotEmpty
                    ? (portionLabel.isNotEmpty
                          ? '$nameStr ($portionLabel)'
                          : nameStr)
                    : (portionLabel.isNotEmpty
                          ? portionLabel
                          : 'Standard Portion');
                final priceLabel = v.sellingPrice?.toStringAsFixed(2);
                final isAvailable = v.isTodayAvailable ?? true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer.withAlpha(
                            120,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 14,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          displayTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (priceLabel != null) ...[
                        Text(
                          priceLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (!isSimple)
                        SizedBox(
                          height: 24,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Switch.adaptive(
                              value: isAvailable,
                              onChanged: (bool newVal) {
                                final updatedVariations = variations.map((
                                  varItem,
                                ) {
                                  final isMatch =
                                      (varItem.id != null &&
                                          varItem.id == v.id) ||
                                      (varItem.hashId != null &&
                                          varItem.hashId == v.hashId) ||
                                      (varItem == v);
                                  if (isMatch) {
                                    return varItem.copyWith(
                                      isTodayAvailable: newVal,
                                    );
                                  }
                                  return varItem;
                                }).toList();

                                final anyAvailable = updatedVariations.any(
                                  (varItem) => varItem.isTodayAvailable ?? true,
                                );

                                final updatedItem = item.copyWith(
                                  isTodayAvailable: anyAvailable,
                                  variations: updatedVariations,
                                );
                                context.read<MenuItemBloc>().add(
                                  UpdateMenuItem(updatedItem),
                                );
                              },
                              thumbIcon: WidgetStateProperty.resolveWith<Icon>((
                                states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  );
                                }
                                return const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                );
                              }),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.withAlpha(30)
                                : Colors.red.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isAvailable
                                  ? Colors.green.shade400
                                  : Colors.red.shade400,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            isAvailable ? 'Available' : 'Unavailable',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isAvailable
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
