import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventroy_bloc/inventory_bloc.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventroy_bloc/inventory_event.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/bloc/inventroy_bloc/inventory_state.dart';
import 'inventory_list_screen_actions.dart';
import '../../widgets/inventory_list/inventory_empty_view.dart';
import '../../widgets/inventory_list/inventory_list_item.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  final ValueNotifier<List<shared.AppliedFilterModel>> _appliedFiltersNotifier =
      ValueNotifier([]);

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    _appliedFiltersNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,

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
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
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
                          return const InventoryEmptyView();
                        }

                        // Re-sort and re-stamp suspension flags on the
                        // filtered subset so letter headers are always correct.
                        shared.SuspensionUtil.sortListBySuspensionTag(
                          filteredItems,
                        );
                        shared.SuspensionUtil.setShowSuspensionStatus(
                          filteredItems,
                        );

                        final isSearching = searchQuery.isNotEmpty;

                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<InventoryBloc>().add(
                              LoadInventoryItems(),
                            );
                          },
                          child: shared.AzListView(
                            key: const PageStorageKey('inventoryListView'),
                            data: filteredItems,
                            itemCount: filteredItems.length,
                            susItemHeight: 46,
                            indexBarData: isSearching
                                ? const []
                                : shared.kIndexBarData
                                      .where(
                                        (tag) => filteredItems.any(
                                          (e) => e.getSuspensionTag() == tag,
                                        ),
                                      )
                                      .toList(),

                            indexBarOptions: shared.IndexBarOptions(
                              needRebuild: true,
                              selectItemDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              selectTextStyle: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              indexHintWidth: 64,
                              indexHintHeight: 64,
                              indexHintDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.92),
                                shape: BoxShape.circle,
                              ),
                              indexHintTextStyle: TextStyle(
                                fontSize: 28.0,
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              indexHintAlignment: Alignment.centerRight,
                              indexHintOffset: const Offset(-40, 0),
                            ),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isLastItem =
                                  index == filteredItems.length - 1;
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: 10,
                                  bottom: isLastItem ? 10 : 0,
                                  left: 10,
                                  right: 30,
                                ),
                                child: InventoryListItem(
                                  key: ValueKey('item_$index'),
                                  item: item,
                                ),
                              );
                            },
                            susItemBuilder: (context, index) {
                              final tag = filteredItems[index]
                                  .getSuspensionTag();
                              return Container(
                                height: 36,
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                  top: index == 0 ? 0 : 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  tag,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              );
                            },
                          ),
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
