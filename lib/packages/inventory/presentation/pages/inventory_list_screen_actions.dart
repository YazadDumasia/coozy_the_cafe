import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventory_event.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/pages/widgets/adjust_stock_dialog.dart';

class InventoryListScreenActions {
  static Future<void> navigateToAddPurchase(BuildContext context) async {
    final selectedItem = await context.push<InventoryItem?>(
      '${core.AppRoutePath.inventoryListScreenRoute}/${core.AppRoutePath.inventoryPickerPageRoute}',
    );
    if (selectedItem != null && context.mounted) {
      context.push(
        core.AppRoutePath.addPurchaseScreenRoute.replaceFirst(
          ':id',
          selectedItem.id.toString(),
        ),
        extra: selectedItem,
      );
    }
  }

  static void navigateToAddInventory(BuildContext context) {
    context.push(core.AppRoutePath.addNewInventoryScreenRoute);
  }

  static void showAdjustStockDialog(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AdjustStockDialog(item: item);
      },
    );
  }

  static void showFilterBottomSheet(
    BuildContext context,
    ValueNotifier<List<shared.AppliedFilterModel>> appliedFiltersNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: shared.FilterWidget(
            filterProps: shared.FilterProps(
              title:
                  context.tr(
                    shared.LocaleKeys.commonFilters,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Filters',
              onFilterChange: (applied) {
                appliedFiltersNotifier.value = applied;
              },
              filters: [
                shared.FilterListModel(
                  filterKey: 'status',
                  title:
                      context.tr(
                        shared.LocaleKeys.inventoryListPageStatus,
                        track: shared.TrackConstants.inventoryPageTrack,
                      ) ??
                      'Status',
                  type: shared.FilterType.checkboxList,
                  previousApplied: appliedFiltersNotifier.value
                      .where((e) => e.filterKey == 'status')
                      .expand((e) => e.applied)
                      .toList(),
                  filterOptions: [
                    shared.FilterItemModel(
                      filterKey: 'enabled',
                      filterTitle:
                          context.tr(
                            shared.LocaleKeys.inventoryListPageEnabled,
                            track: shared.TrackConstants.inventoryPageTrack,
                          ) ??
                          'Enabled',
                    ),
                    shared.FilterItemModel(
                      filterKey: 'disabled',
                      filterTitle:
                          context.tr(
                            shared.LocaleKeys.inventoryListPageDisabled,
                            track: shared.TrackConstants.inventoryPageTrack,
                          ) ??
                          'Disabled',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void handleItemAction(
    BuildContext context,
    InventoryItem item,
    String value,
  ) {
    if (value == 'enable') {
      context.read<InventoryBloc>().add(
        UpdateInventoryItem(item.copyWith(isEnabled: true)),
      );
    } else if (value == 'disable') {
      context.read<InventoryBloc>().add(
        UpdateInventoryItem(item.copyWith(isEnabled: false)),
      );
    } else if (value == 'edit') {
      context
          .push(
            core.AppRoutePath.updateInventoryScreenRoute.replaceFirst(
              ':id',
              item.id.toString(),
            ),
            extra: item,
          )
          .then((_) {
            if (context.mounted) {
              context.read<InventoryBloc>().add(LoadInventoryItems());
            }
          });
    } else if (value == 'update') {
      context
          .push(
            core.AppRoutePath.addPurchaseScreenRoute.replaceFirst(
              ':id',
              item.id.toString(),
            ),
            extra: item,
          )
          .then((_) {
            if (context.mounted) {
              context.read<InventoryBloc>().add(LoadInventoryItems());
            }
          });
    } else if (value == 'adjust') {
      showAdjustStockDialog(context, item);
    } else if (value == 'delete') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            context.tr(
                  shared.LocaleKeys.inventoryDeleteDialogTitleText,
                  track: shared.TrackConstants.inventoryPageTrack,
                ) ??
                'Delete Inventory Item?',
          ),
          content: Text(
            context.tr(
                  shared.LocaleKeys.inventoryDeleteDialogContentText,
                  track: shared.TrackConstants.inventoryPageTrack,
                ) ??
                'Are you sure you want to delete this item?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonCancel,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<InventoryBloc>().add(
                  DeleteInventoryItem(
                    item.id!,
                    onSuccess: () {
                      if (context.mounted) {
                        shared.DialogUtils.showAutoDismissDialog(
                          context: context,
                          title:
                              context.tr(
                                shared.LocaleKeys.commonSuccess,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Success',
                          descriptions:
                              context.tr(
                                shared.LocaleKeys.crudSuccessDelete,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Record deleted successfully.',
                          titleIcon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                        );
                      }
                    },
                    onError: (error) {
                      if (context.mounted) {
                        shared.DialogUtils.showAutoDismissDialog(
                          context: context,
                          title:
                              context.tr(
                                shared.LocaleKeys.commonError,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Error',
                          descriptions: error.isNotEmpty
                              ? error
                              : (context.tr(
                                      shared.LocaleKeys.commonErrorMsg,
                                      track: shared.TrackConstants.commonTrack,
                                    ) ??
                                    'An error occurred.'),
                          titleIcon: const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 50,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonDelete,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Delete',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }
}
