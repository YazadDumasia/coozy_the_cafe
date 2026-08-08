import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/coozy_shared.dart' as shared;
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'widgets/customer_list_mobile_layout.dart';
import 'widgets/customer_list_tablet_layout.dart';
import 'widgets/customer_list_desktop_layout.dart';
import 'customer_list_screen_actions.dart';
import '../widgets/customer_list_item.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.customersAppBarTitle,
                track: shared.TrackConstants.customerPageTrack,
              ) ??
              'Customers',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CustomerListScreenActions.showAddEditForm(context),
        child: Icon(Icons.add),
      ),
      body: shared.ResponsiveLayout(
        mobile: CustomerListMobileLayout(bodyWidget: _buildBody()),
        tablet: CustomerListTabletLayout(bodyWidget: _buildBody()),
        desktop: CustomerListDesktopLayout(bodyWidget: _buildBody()),
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
              setState(() {});
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
                return Center(child: CircularProgressIndicator());
              }

              if (state is CustomerError) {
                return Center(child: Text('Error: ${state.message}'));
              }

              if (state is CustomerLoaded) {
                if (state.customers.isEmpty) {
                  return Center(
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.noCustomersFoundMsg,
                            track: shared.TrackConstants.customerPageTrack,
                          ) ??
                          'No customers found.',
                    ),
                  );
                }

                final isSearching = _searchController.text.trim().isNotEmpty;

                return shared.AzListView(
                  data: state.customers,
                  itemCount: state.customers.length,
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
                      color: Theme.of(context)
                          .colorScheme
                          .primary
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
                    return CustomerListItem(customer: customer);
                  },
                  susItemBuilder: (context, index) {
                      final tag = state.customers[index].getSuspensionTag();
                      return Container(
                        height: 36,
                        width: double.infinity,
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
