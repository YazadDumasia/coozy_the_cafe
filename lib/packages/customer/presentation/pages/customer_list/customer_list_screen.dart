import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/coozy_shared.dart' as shared;
import '../../bloc/customer_bloc.dart';
import 'customer_list_screen_actions.dart';
import '../../widgets/customer_list/customer_empty_view.dart';
import '../../widgets/customer_list/customer_list_item.dart';
import '../../widgets/customer_list/customer_search_empty_view.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(
      () => CustomerListScreenActions.onScroll(context, _scrollController),
    );
    context.read<CustomerBloc>().add(const LoadCustomers(isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
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
                  shared.LocaleKeys.customersAppBarTitle,
                  track: shared.TrackConstants.customerPageTrack,
                ) ??
                'Customers',
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  CustomerListScreenActions.showAddEditForm(context),
              icon: const Icon(Icons.add),
              tooltip:
                  context.tr(
                    shared.LocaleKeys.addCustomerBtn,
                    track: shared.TrackConstants.customerPageTrack,
                  ) ??
                  'Add Customer',
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
                    shared.LocaleKeys.customersSearchHintText,
                    track: shared.TrackConstants.customerPageTrack,
                  ) ??
                  'Search customers...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (query) {
              CustomerListScreenActions.onSearchChanged(context, query);
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerInitial ||
                  (state is CustomerLoading &&
                      context.read<CustomerBloc>().state is! CustomerLoaded)) {
                return const shared.LoadingPage();
              }

              if (state is CustomerError) {
                return shared.ErrorPage(
                  onPressedRetryButton: () {
                    context.read<CustomerBloc>().add(
                      const LoadCustomers(isRefresh: true),
                    );
                  },
                );
              }

              if (state is CustomerLoaded) {
                if (state.customers.isEmpty) {
                  final isSearching = _searchController.text.trim().isNotEmpty;

                  if (!isSearching) {
                    return CustomerEmptyView(
                      onAddCustomer: () =>
                          CustomerListScreenActions.showAddEditForm(context),
                    );
                  }

                  return CustomerSearchEmptyView(
                    searchQuery: _searchController.text.trim(),
                    onClearSearch: () {
                      _searchController.clear();
                      CustomerListScreenActions.onSearchChanged(context, '');
                    },
                  );
                }

                final isSearching = _searchController.text.trim().isNotEmpty;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<CustomerBloc>().add(
                      const LoadCustomers(isRefresh: true),
                    );
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                          scrollInfo.metrics.maxScrollExtent * 0.9) {
                        context.read<CustomerBloc>().add(
                          const LoadCustomers(isRefresh: false),
                        );
                      }
                      return false;
                    },
                    child: shared.AzListView(
                      key: const PageStorageKey('customerListView'),
                      data: state.customers,
                      itemCount: state.customers.length,
                      susItemHeight: 46,
                      indexBarData: isSearching
                          ? const []
                          : shared.kIndexBarData
                                .where(
                                  (tag) => state.customers.any(
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
                        final customer = state.customers[index];
                        final isLastItem = index == state.customers.length - 1;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 10,
                                bottom: isLastItem && !state.isLoadingMore
                                    ? 10
                                    : 0,
                                left: 10,
                                right: 30,
                              ),
                              child: CustomerListItem(customer: customer),
                            ),
                            if (isLastItem && state.isLoadingMore)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    animating: true,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    radius: 15,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      susItemBuilder: (context, index) {
                        final tag = state.customers[index].getSuspensionTag();
                        return Container(
                          height: 36,
                          width: double.infinity,
                          margin: EdgeInsets.only(top: index == 0 ? 0 : 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            tag,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }

              return SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
