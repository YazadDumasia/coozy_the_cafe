import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'purchase_list_screen_actions.dart';
import '../../widgets/purchase_list/purchase_empty_view.dart';
import '../../widgets/purchase_list/purchase_list_item.dart';

import 'dart:async';
import 'package:coozy_the_cafe/packages/purchase/presentation/bloc/purchase_list_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  final _scrollController = ScrollController();
  Timer? _debounce;
  final ValueNotifier<List<shared.AppliedFilterModel>> _appliedFiltersNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _appliedFiltersNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PurchaseListBloc>().add(const LoadPurchases());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<PurchaseListBloc>().add(
        LoadPurchases(isRefresh: true, searchQuery: query),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.purchaseHistory,
                  track: shared.TrackConstants.purchasePageTrack,
                ) ??
                'Purchases History',
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              tooltip:
                  context.tr(
                    shared.LocaleKeys.commonFilter,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Filter',
              onPressed: () {
                _showFilterBottomSheet(context);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => PurchaseListScreenActions.onAddPurchaseTap(context),
          child: Icon(Icons.add),
        ),
        body: _buildBody(context),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
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
                _appliedFiltersNotifier.value = applied;
              },
              filters: [
                shared.FilterListModel(
                  filterKey: 'transaction_type',
                  title:
                      context.tr(
                        shared.LocaleKeys.purchaseTransactionType,
                        track: shared.TrackConstants.purchasePageTrack,
                      ) ??
                      'Transaction Type',
                  type: shared.FilterType.checkboxList,
                  previousApplied: _appliedFiltersNotifier.value
                      .where((e) => e.filterKey == 'transaction_type')
                      .expand((e) => e.applied)
                      .toList(),
                  filterOptions: [
                    shared.FilterItemModel(
                      filterKey: 'increment',
                      filterTitle:
                          context.tr(
                            shared.LocaleKeys.purchaseIncrement,
                            track: shared.TrackConstants.purchasePageTrack,
                          ) ??
                          'Increment',
                    ),
                    shared.FilterItemModel(
                      filterKey: 'decrement',
                      filterTitle:
                          context.tr(
                            shared.LocaleKeys.purchaseDecrement,
                            track: shared.TrackConstants.purchasePageTrack,
                          ) ??
                          'Decrement',
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

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<PurchaseListBloc, PurchaseListState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.purchaseSummary != null)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.blue.shade100,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                context.tr(
                                      shared.LocaleKeys.commonDailyDuration,
                                      track: shared.TrackConstants.commonTrack,
                                    ) ??
                                    'Daily',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                state.purchaseSummary!.dailyTotal
                                    .toStringAsFixed(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: Colors.green.shade100,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                context.tr(
                                      shared.LocaleKeys.commonWeeklyDuration,
                                      track: shared.TrackConstants.commonTrack,
                                    ) ??
                                    'Weekly',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                state.purchaseSummary!.weeklyTotal
                                    .toStringAsFixed(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        color: Colors.orange.shade100,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                context.tr(
                                      shared.LocaleKeys.commonMonthlyDuration,
                                      track: shared.TrackConstants.commonTrack,
                                    ) ??
                                    'Monthly',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                state.purchaseSummary!.monthlyTotal
                                    .toStringAsFixed(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText:
                      context.tr(
                        shared.LocaleKeys.purchaseSearchPurchases,
                        track: shared.TrackConstants.purchasePageTrack,
                      ) ??
                      'Search purchases...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<shared.AppliedFilterModel>>(
                valueListenable: _appliedFiltersNotifier,
                builder: (context, appliedFilters, child) {
                  return Builder(
                    builder: (context) {
                      var filteredPurchases = state.purchases;
                      if (appliedFilters.isNotEmpty) {
                        for (var appliedFilter in appliedFilters) {
                          if (appliedFilter.filterKey == 'transaction_type' &&
                              appliedFilter.applied.isNotEmpty) {
                            var types = appliedFilter.applied
                                .map((e) => e.filterKey)
                                .toList();
                            filteredPurchases = filteredPurchases.where((
                              record,
                            ) {
                              if (types.contains('increment') &&
                                  types.contains('decrement')) {
                                return true;
                              }
                              if (types.contains('increment')) {
                                return (record.purchaseQty ?? 0) > 0;
                              }
                              if (types.contains('decrement')) {
                                return (record.purchaseQty ?? 0) < 0;
                              }
                              return true;
                            }).toList();
                          }
                        }
                      }

                      if (filteredPurchases.isEmpty) {
                        if (state.isLoading) {
                          return const shared.LoadingPage();
                        }
                        if (state.errorMessage != null) {
                          return shared.ErrorPage(
                            onPressedRetryButton: () {
                              context.read<PurchaseListBloc>().add(
                                    const LoadPurchases(isRefresh: true),
                                  );
                            },
                          );
                        }
                        return const PurchaseEmptyView();
                      }

                      final showPaginationLoader =
                          !state.hasReachedMax && appliedFilters.isEmpty;

                      return Scrollbar(
                        interactive: true,
                        radius: const Radius.circular(10.0),
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          primary: false,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            primary: false,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            itemCount: showPaginationLoader
                                ? filteredPurchases.length + 1
                                : filteredPurchases.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index >= filteredPurchases.length) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final record = filteredPurchases[index];
                              return PurchaseListItem(record: record);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
