import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/invoice_management_bloc.dart';
import 'invoice_list_screen_actions.dart';
import 'widget/invoice_card_widget.dart';
import 'widget/invoice_date_header_widget.dart';
import 'widget/invoice_list_active_filters_row.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  late final ScrollController _scrollController;
  final ValueNotifier<List<shared.AppliedFilterModel>> _appliedFiltersNotifier =
      ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceManagementBloc>().add(
              const LoadInvoicesEvent(isRefresh: true),
            );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _appliedFiltersNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      context.read<InvoiceManagementBloc>().add(const LoadMoreInvoicesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.invoiceListTitle,
                  track: shared.TrackConstants.invoicePageTrack,
                ) ??
                'Invoices',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            BlocBuilder<InvoiceManagementBloc, InvoiceManagementState>(
              builder: (context, state) {
                final paymentModes = state is InvoiceManagementLoadedState
                    ? state.paymentModes
                    : const <PaymentMode>[];
                return ValueListenableBuilder<List<shared.AppliedFilterModel>>(
                  valueListenable: _appliedFiltersNotifier,
                  builder: (context, appliedFilters, _) {
                    final hasFilters = appliedFilters.isNotEmpty;
                    return IconButton(
                      icon: Badge(
                        isLabelVisible: hasFilters,
                        child: const Icon(Icons.filter_list),
                      ),
                      tooltip: context.tr(
                            shared.LocaleKeys.commonFilter,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Filter',
                      onPressed: () {
                        InvoiceListScreenActions.openFilterBottomSheet(
                          context: context,
                          appliedFiltersNotifier: _appliedFiltersNotifier,
                          paymentModes: paymentModes,
                        );
                      },
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: context.tr(
                    shared.LocaleKeys.commonRefresh,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Refresh',
              onPressed: () {
                context.read<InvoiceManagementBloc>().add(
                      const LoadInvoicesEvent(isRefresh: true),
                    );
              },
            ),
          ],
        ),
        body: BlocConsumer<InvoiceManagementBloc, InvoiceManagementState>(
          listener: (context, state) {
            if (state is InvoiceManagementLoadedState &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            if (state is InvoiceManagementLoadingState ||
                state is InvoiceManagementInitialState) {
              return const shared.LoadingPage();
            } else if (state is InvoiceManagementErrorState) {
              return shared.ErrorPage(
                errorMsg: state.message,
                onPressedRetryButton: () {
                  context.read<InvoiceManagementBloc>().add(
                        const LoadInvoicesEvent(isRefresh: true),
                      );
                },
              );
            } else if (state is InvoiceManagementLoadedState) {
              final invoices = state.invoices;

              return Column(
                children: [
                  InvoiceDateHeaderWidget(dateRange: state.dateRange),
                  ValueListenableBuilder<List<shared.AppliedFilterModel>>(
                    valueListenable: _appliedFiltersNotifier,
                    builder: (context, appliedFilters, _) {
                      return InvoiceListActiveFiltersRow(
                        appliedFilters: appliedFilters,
                        onRemoveAppliedFilterKey: (key) {
                          InvoiceListScreenActions.removeAppliedFilterKey(
                            context: context,
                            appliedFiltersNotifier: _appliedFiltersNotifier,
                            filterKey: key,
                          );
                        },
                        onClearAll: () {
                          InvoiceListScreenActions.clearAllFilters(
                            context: context,
                            appliedFiltersNotifier: _appliedFiltersNotifier,
                          );
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: invoices.isEmpty
                        ? Center(
                            child: Text(
                              context.tr(
                                    shared.LocaleKeys.commonNoDataFoundMsg,
                                    track: shared.TrackConstants.commonTrack,
                                  ) ??
                                  'No Receipts Found',
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            addAutomaticKeepAlives: false,
                            addRepaintBoundaries: true,
                            itemCount: invoices.length +
                                (state.isFetchingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= invoices.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final invoice = invoices[index];
                              return InvoiceCardWidget(
                                invoice: invoice,
                                onTap: () {
                                  InvoiceListScreenActions.onInvoiceTapped(
                                    context,
                                    invoice,
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
