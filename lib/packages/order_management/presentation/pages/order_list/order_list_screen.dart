import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;


import '../../bloc/order_management_bloc.dart';
import 'order_list_screen_actions.dart';
import 'widget/order_card_widget.dart';
import 'widget/order_date_range_picker_bar.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _scrollController.addListener(_onScroll);

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderManagementBloc>().add(
              const LoadOrdersEvent(isRefresh: true),
            );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      context.read<OrderManagementBloc>().add(const LoadMoreOrdersEvent());
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        OrderListScreenActions.onSearchQueryChanged(context, value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.orderManagementOrderListTitle,
                  track: shared.TrackConstants.orderManagementPageTrack,
                ) ??
                'Order Management',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: context.tr(
                    shared.LocaleKeys.orderManagementRefreshOrders,
                    track: shared.TrackConstants.orderManagementPageTrack,
                  ) ??
                  'Refresh',
              onPressed: () {
                context.read<OrderManagementBloc>().add(
                      const LoadOrdersEvent(isRefresh: true),
                    );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: context.tr(
                        shared.LocaleKeys.orderManagementSearchOrdersHint,
                        track: shared.TrackConstants.orderManagementPageTrack,
                      ) ??
                      'Search orders by ID, table, or customer...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Date Range Picker Bar
            BlocBuilder<OrderManagementBloc, OrderManagementState>(
              builder: (context, state) {
                DateTimeRange? range;
                if (state is OrderManagementLoadedState) {
                  range = state.dateRange;
                }
                return OrderDateRangePickerBar(
                  selectedDateRange: range,
                  onPickDateRange: () =>
                      OrderListScreenActions.onPickDateRange(context),
                  onClearDateRange: () =>
                      OrderListScreenActions.onClearDateRange(context),
                );
              },
            ),

            // Filter Chips
            BlocBuilder<OrderManagementBloc, OrderManagementState>(
              builder: (context, state) {
                String activeStatus = 'all';
                if (state is OrderManagementLoadedState) {
                  activeStatus = state.selectedStatus;
                }

                final filterOptions = [
                  ('all', 'All'),
                  ('newOrder', 'New'),
                  ('inProgress', 'In Progress'),
                  ('completed', 'Completed'),
                  ('cancelled', 'Cancelled'),
                ];

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: filterOptions.map((opt) {
                      final isSelected = activeStatus.toLowerCase() == opt.$1.toLowerCase();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(opt.$2),
                          onSelected: (_) {
                            OrderListScreenActions.onStatusFilterChanged(
                              context,
                              opt.$1,
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Main Order List Body
            Expanded(
              child: BlocBuilder<OrderManagementBloc, OrderManagementState>(
                builder: (context, state) {
                  if (state is OrderManagementLoadingState) {
                    return const shared.LoadingPage();
                  }

                  if (state is OrderManagementErrorState) {
                    return shared.ErrorPage(
                      errorMsg: state.message,
                      onPressedRetryButton: () {
                        context.read<OrderManagementBloc>().add(
                              const LoadOrdersEvent(isRefresh: true),
                            );
                      },
                    );
                  }


                  if (state is OrderManagementLoadedState) {
                    if (state.orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: colorScheme.onSurfaceVariant.withAlpha(120),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.orderManagementNoOrdersFound,
                                    track: shared
                                        .TrackConstants.orderManagementPageTrack,
                                  ) ??
                                  'No orders found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                context.tr(
                                      shared.LocaleKeys.orderManagementNoOrdersFoundSubtitle,
                                      track: shared
                                          .TrackConstants.orderManagementPageTrack,
                                    ) ??
                                    'Try adjusting your search query, status filter, or date range.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<OrderManagementBloc>().add(
                              const LoadOrdersEvent(isRefresh: true),
                            );
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                        itemCount: state.hasReachedMax
                            ? state.orders.length
                            : state.orders.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= state.orders.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            );
                          }
                          final order = state.orders[index];
                          return OrderCardWidget(
                            order: order,
                            onTap: () {
                              OrderListScreenActions.onOrderCardTap(
                                context,
                                order,
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
