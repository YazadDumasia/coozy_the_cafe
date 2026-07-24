import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventory_state.dart';
import 'inventory_list_screen_actions.dart';
import 'widgets/inventory_list_item.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  final ValueNotifier<List<shared.AppliedFilterModel>> _appliedFiltersNotifier =
      ValueNotifier([]);

  @override
  void dispose() {
    _searchQueryNotifier.dispose();
    _appliedFiltersNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.inventoryAppbar,
                track: shared.TrackConstants.inventoryPageTrack,
              ) ??
              'Inventory',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_shopping_cart),
            tooltip:
                context.tr(
                  shared.LocaleKeys.inventoryListPageAddPurchaseForItem,
                  track: shared.TrackConstants.inventoryPageTrack,
                ) ??
                'Add Purchase for Item',
            onPressed: () =>
                InventoryListScreenActions.navigateToAddPurchase(context),
          ),
          IconButton(
            icon: Icon(Icons.add),
            tooltip:
                context.tr(
                  shared.LocaleKeys.inventoryListPageAddInventoryItem,
                  track: shared.TrackConstants.inventoryPageTrack,
                ) ??
                'Add Inventory Item',
            onPressed: () =>
                InventoryListScreenActions.navigateToAddInventory(context),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            tooltip:
                context.tr(
                  shared.LocaleKeys.commonFilter,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Filter',
            onPressed: () => InventoryListScreenActions.showFilterBottomSheet(
              context,
              _appliedFiltersNotifier,
            ),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText:
                  context.tr(
                    shared.LocaleKeys.inventoryListPageSearchHint,
                    track: shared.TrackConstants.inventoryPageTrack,
                  ) ??
                  'Search inventory...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (val) {
              _searchQueryNotifier.value = val.toLowerCase();
            },
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: _searchQueryNotifier,
            builder: (context, searchQuery, child) {
              return ValueListenableBuilder<List<shared.AppliedFilterModel>>(
                valueListenable: _appliedFiltersNotifier,
                builder: (context, appliedFilters, child) {
                  return BlocBuilder<InventoryBloc, InventoryState>(
                    builder: (context, state) {
                      if (state is InventoryLoading ||
                          state is InventoryInitial) {
                        return Center(child: CircularProgressIndicator());
                      } else if (state is InventoryLoaded) {
                        var filteredItems = state.items.where((item) {
                          if (searchQuery.isNotEmpty &&
                              !(item.name?.toLowerCase().contains(
                                    searchQuery,
                                  ) ??
                                  false)) {
                            return false;
                          }

                          if (appliedFilters.isNotEmpty) {
                            for (var appliedFilter in appliedFilters) {
                              if (appliedFilter.filterKey == 'status' &&
                                  appliedFilter.applied.isNotEmpty) {
                                var statusKeys = appliedFilter.applied
                                    .map((e) => e.filterKey)
                                    .toList();
                                if (statusKeys.contains('enabled') &&
                                    statusKeys.contains('disabled')) {
                                  // show both
                                } else if (statusKeys.contains('enabled')) {
                                  if (item.isEnabled != true) return false;
                                } else if (statusKeys.contains('disabled')) {
                                  if (item.isEnabled == true) return false;
                                }
                              }
                            }
                          }
                          return true;
                        }).toList();

                        if (filteredItems.isEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                shared.InventoryIcon.borderInventory,
                                size: 150,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                context.tr(
                                      shared
                                          .LocaleKeys
                                          .inventoryListPageNoDataFound,
                                      track: shared
                                          .TrackConstants
                                          .inventoryPageTrack,
                                    ) ??
                                    'No inventory items found.',
                              ),
                            ],
                          ).inExpandedRow(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return InventoryListItem(item: item);
                          },
                        );
                      } else if (state is InventoryError) {
                        return Center(
                          child: Text(
                            '${context.tr(shared.LocaleKeys.commonError, track: shared.TrackConstants.commonTrack) ?? 'Error'}: ${state.message}',
                          ),
                        );
                      }
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              shared.InventoryIcon.borderInventory,
                              size: 150,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.inventoryListPageNoItem,
                                    track: shared
                                        .TrackConstants
                                        .inventoryPageTrack,
                                  ) ??
                                  'No Items',
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
