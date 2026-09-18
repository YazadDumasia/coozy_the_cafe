import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/cash_flow_bloc.dart';
import '../../../domain/entities/expenditure_entity.dart';
import 'widget/cash_flow_summary_card.dart';
import 'widget/cash_flow_timeline_view.dart';
import 'widget/cash_flow_bottom_actions.dart';
import 'widget/cash_flow_empty_view.dart';
import '../category_selection_screen/category_selection_screen.dart';

class CashFlowScreen extends StatefulWidget {
  const CashFlowScreen({super.key});

  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    context.read<CashFlowBloc>().add(const LoadCashFlowData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openDateFilterDialog(DateTime currentStart, DateTime currentEnd) async {
    final result = await shared.DateRangeFilterDialog.showFullScreen(
      context: context,
      initialFromDate: currentStart,
      initialToDate: currentEnd,
    );

    if (result != null && mounted) {
      final s = result.fromDate;
      final e = result.toDate;
      final startStr = DateUtil.localFormatDateTime(s, 'dd MMM yyyy') ?? '';
      final endStr = DateUtil.localFormatDateTime(e, 'dd MMM yyyy') ?? '';
      context.read<CashFlowBloc>().add(
        ChangeDateRangeFilter(
          startDate: s,
          endDate: e,
          dateRangeLabel: '$startStr - $endStr',
        ),
      );
    }
  }

  void _navigatePreviousWeek(DateTime currentStart, DateTime currentEnd) {
    final s = currentStart.subtract(const Duration(days: 7));
    final e = currentEnd.subtract(const Duration(days: 7));
    final startStr = DateUtil.localFormatDateTime(s, 'dd MMM yyyy') ?? '';
    final endStr = DateUtil.localFormatDateTime(e, 'dd MMM yyyy') ?? '';
    context.read<CashFlowBloc>().add(
      ChangeDateRangeFilter(
        startDate: s,
        endDate: e,
        dateRangeLabel: '$startStr - $endStr',
      ),
    );
  }

  void _navigateNextWeek(DateTime currentStart, DateTime currentEnd) {
    final s = currentStart.add(const Duration(days: 7));
    final e = currentEnd.add(const Duration(days: 7));
    final startStr = DateUtil.localFormatDateTime(s, 'dd MMM yyyy') ?? '';
    final endStr = DateUtil.localFormatDateTime(e, 'dd MMM yyyy') ?? '';
    context.read<CashFlowBloc>().add(
      ChangeDateRangeFilter(
        startDate: s,
        endDate: e,
        dateRangeLabel: '$startStr - $endStr',
      ),
    );
  }

  Future<void> _openCategoryPicker(String type) async {
    final result = await Navigator.of(context).push<ExpenditureEntity>(
      MaterialPageRoute(
        builder: (_) => CategorySelectionScreen(initialType: type),
      ),
    );

    if (result != null && mounted) {
      context.read<CashFlowBloc>().add(AddTransactionSubmitted(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop();
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              context.tr(
                    shared.LocaleKeys.expenditureAppbarTitle,
                    track: shared.TrackConstants.expenditurePageTrack,
                  ) ??
                  'Cash Flow',
            ),
          ),

          body: BlocBuilder<CashFlowBloc, CashFlowState>(
            builder: (context, state) {
              if (state is CashFlowLoading) {
                return const shared.LoadingPage();
              }

              if (state is CashFlowError) {
                return shared.ErrorPage(
                  errorMsg: state.message,
                  onPressedRetryButton: () => context.read<CashFlowBloc>().add(
                    const LoadCashFlowData(),
                  ),
                );
              }

              if (state is CashFlowLoaded) {
                return Column(
                  children: [
                    // Top Date Navigator Bar matching Screenshot 1
                    Container(
                      color: theme.cardColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, size: 30),
                                color: colorScheme.primary,
                                onPressed: () => _navigatePreviousWeek(
                                  state.startDate,
                                  state.endDate,
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _openDateFilterDialog(
                                    state.startDate,
                                    state.endDate,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: colorScheme.primary,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          state.dateRangeLabel,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, size: 30),
                                color: colorScheme.primary,
                                onPressed: () => _navigateNextWeek(
                                  state.startDate,
                                  state.endDate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Main Content
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<CashFlowBloc>().add(
                            LoadCashFlowData(
                              startDate: state.startDate,
                              endDate: state.endDate,
                            ),
                          );
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (state.groupedTransactions.isEmpty) {
                              return SingleChildScrollView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Net Cash Flow Summary Card
                                      CashFlowSummaryCard(
                                        netCashFlow: state.summary.netCashFlow,
                                        totalIncome: state.summary.totalIncome,
                                        totalExpense:
                                            state.summary.totalExpense,
                                      ),
                                      // Centered empty state
                                      const Expanded(
                                        child: CashFlowEmptyView(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return SingleChildScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Center(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Net Cash Flow Summary Card
                                    CashFlowSummaryCard(
                                      netCashFlow: state.summary.netCashFlow,
                                      totalIncome: state.summary.totalIncome,
                                      totalExpense: state.summary.totalExpense,
                                    ),
                                    // Grouped Timeline of Transactions
                                    CashFlowTimelineView(
                                      groupedTransactions:
                                          state.groupedTransactions,
                                      dailyIncomeTotals:
                                          state.dailyIncomeTotals,
                                      dailyExpenseTotals:
                                          state.dailyExpenseTotals,
                                      hasReachedMax: state.hasReachedMax,
                                      isLoadingMore: state.isLoadingMore,
                                      scrollController: _scrollController,
                                      onLoadMore: () {
                                        context.read<CashFlowBloc>().add(
                                          const LoadMoreCashFlowData(),
                                        );
                                      },
                                      onItemDelete: (item) {
                                        if (item.id != null) {
                                          context.read<CashFlowBloc>().add(
                                            DeleteTransactionSubmitted(
                                              item.id!,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Sticky Bottom Income / Expense Action Bar
                    CashFlowBottomActions(
                      onIncomeTap: () => _openCategoryPicker('INCOME'),
                      onExpenseTap: () => _openCategoryPicker('EXPENSE'),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ), // Scaffold
    ); // PopScope
  }
}
