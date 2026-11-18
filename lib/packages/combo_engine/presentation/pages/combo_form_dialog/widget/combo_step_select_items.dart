import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item_variation.dart';

import '../../../../domain/entities/combo_item.dart';
import '../../../../domain/usecases/combo_usecases.dart';
import 'menu_item_search_selector.dart';
import 'selected_bundle_items_table.dart';

class ComboStepSelectItems extends StatelessWidget {
  final SearchMenuItemsForComboUseCase searchUseCase;
  final GetMenuItemsCountForComboUseCase countUseCase;
  final ValueNotifier<List<ComboItem>> selectedItemsNotifier;
  final Function(MenuItem item, MenuItemVariation? variation)
  onMenuItemSelected;
  final Function(int index, int newQuantity) onQuantityChanged;
  final Function(int index) onRemoveItem;

  const ComboStepSelectItems({
    super.key,
    required this.searchUseCase,
    required this.countUseCase,
    required this.selectedItemsNotifier,
    required this.onMenuItemSelected,
    required this.onQuantityChanged,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useHorizontalSplit = isDesktop || constraints.maxWidth >= 760;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instruction banner with live counter
              ValueListenableBuilder<List<ComboItem>>(
                valueListenable: selectedItemsNotifier,
                builder: (context, items, _) {
                  final count = items.length;
                  final isValid = count >= 2;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isValid
                          ? colorScheme.primaryContainer.withValues(alpha: 0.25)
                          : colorScheme.errorContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isValid
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isValid
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline_rounded,
                          color: isValid
                              ? colorScheme.primary
                              : colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isValid
                                ? (context.tr(
                                        shared
                                            .LocaleKeys
                                            .comboFormDialogItemsSelectedCount,
                                        track: shared
                                            .TrackConstants
                                            .comboPageTrack,
                                        params: {'count': count.toString()},
                                      ) ??
                                      '$count items selected in this bundle.')
                                : (context.tr(
                                        shared
                                            .LocaleKeys
                                            .comboFormDialogItemsRequiredHint,
                                        track: shared
                                            .TrackConstants
                                            .comboPageTrack,
                                        params: {'count': count.toString()},
                                      ) ??
                                      'Select at least 2 items to bundle ($count/2 selected).'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isValid
                                  ? colorScheme.onSurface
                                  : colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isValid
                                ? colorScheme.primary
                                : colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.comboFormDialogItemsBadge,
                                  track: shared.TrackConstants.comboPageTrack,
                                  params: {'count': count.toString()},
                                ) ??
                                '$count / 2+ items',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Content area: 2 columns on wide screens, stacked on small
              Expanded(
                child: useHorizontalSplit
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left side: Menu items catalog selector
                          Expanded(
                            flex: 5,
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: MenuItemSearchSelector(
                                searchUseCase: searchUseCase,
                                countUseCase: countUseCase,
                                onItemSelected: onMenuItemSelected,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Right side: Selected items list with quantities
                          Expanded(
                            flex: 5,
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: ValueListenableBuilder<List<ComboItem>>(
                                  valueListenable: selectedItemsNotifier,
                                  builder: (context, items, _) {
                                    return SelectedBundleItemsTable(
                                      items: items,
                                      onQuantityChanged: onQuantityChanged,
                                      onRemoveItem: onRemoveItem,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: MenuItemSearchSelector(
                                searchUseCase: searchUseCase,
                                countUseCase: countUseCase,
                                onItemSelected: onMenuItemSelected,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            flex: 4,
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ValueListenableBuilder<List<ComboItem>>(
                                  valueListenable: selectedItemsNotifier,
                                  builder: (context, items, _) {
                                    return SelectedBundleItemsTable(
                                      items: items,
                                      onQuantityChanged: onQuantityChanged,
                                      onRemoveItem: onRemoveItem,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
