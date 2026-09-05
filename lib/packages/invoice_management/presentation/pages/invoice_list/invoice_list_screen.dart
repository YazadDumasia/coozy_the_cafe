import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/invoice_management_bloc.dart';
import 'invoice_list_screen_actions.dart';
import 'widget/invoice_card_widget.dart';
import 'widget/invoice_date_header_widget.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  late final ScrollController _scrollController;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.invoiceListTitle,
                  track: shared.TrackConstants.invoicePageTrack,
                ) ??
                'Receipts',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
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
            if (state is InvoiceManagementLoadingState) {
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Action for filter selection modal
          },
          backgroundColor: colorScheme.primary,
          icon: const Icon(Icons.filter_list, color: Colors.white),
          label: Text(
            context.tr(
                  shared.LocaleKeys.invoiceFilterAll,
                  track: shared.TrackConstants.invoicePageTrack,
                ) ??
                'FILTER : ALL',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
