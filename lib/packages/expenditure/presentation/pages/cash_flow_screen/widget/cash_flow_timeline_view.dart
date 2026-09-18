import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../../domain/entities/expenditure_entity.dart';
import 'cash_flow_empty_view.dart';
import 'cash_flow_timeline_item.dart';

class CashFlowTimelineView extends StatefulWidget {
  final Map<String, List<ExpenditureEntity>> groupedTransactions;
  final Map<String, double> dailyIncomeTotals;
  final Map<String, double> dailyExpenseTotals;
  final Function(ExpenditureEntity)? onItemDelete;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final ScrollController? scrollController;

  const CashFlowTimelineView({
    super.key,
    required this.groupedTransactions,
    required this.dailyIncomeTotals,
    required this.dailyExpenseTotals,
    this.onItemDelete,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.scrollController,
  });

  @override
  State<CashFlowTimelineView> createState() => _CashFlowTimelineViewState();
}

class _CashFlowTimelineViewState extends State<CashFlowTimelineView> {
  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(CashFlowTimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;
    if (currentScroll >= maxScroll - 250) {
      if (!widget.hasReachedMax && !widget.isLoadingMore) {
        widget.onLoadMore?.call();
      }
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      if (notification.metrics.pixels >=
          notification.metrics.maxScrollExtent - 250) {
        if (!widget.hasReachedMax && !widget.isLoadingMore) {
          widget.onLoadMore?.call();
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final incomeColor = isDark
        ? Colors.greenAccent[400]!
        : const Color(0xFF2E7D32);
    final expenseColor = isDark
        ? Colors.redAccent[200]!
        : const Color(0xFFD32F2F);
    final connectorColor = colorScheme.outlineVariant.withValues(alpha: 0.5);

    // ── Empty state ────────────────────────────────────────────────────
    if (widget.groupedTransactions.isEmpty) {
      return const CashFlowEmptyView();
    }

    final dateKeys = widget.groupedTransactions.keys.toList();
    final bool showBottomLoader = !widget.hasReachedMax;
    final int totalCount = dateKeys.length + (showBottomLoader ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: TimelineTheme(
        data: TimelineThemeData(
          nodePosition: 0,
          indicatorPosition: 0.5,
          indicatorTheme: const IndicatorThemeData(size: 24),
          connectorTheme: ConnectorThemeData(
            color: connectorColor,
            thickness: 2.0,
            space: 24,
          ),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCount,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemBuilder: (context, dateIndex) {
            // Bottom infinite loading tile connected to timeline
            if (dateIndex == dateKeys.length) {
              return TimelineTile(
                nodeAlign: TimelineNodeAlign.start,
                node: TimelineNode(
                  indicator: OutlinedDotIndicator(
                    color: colorScheme.primary,
                    size: 14,
                    borderWidth: 2,
                  ),
                  startConnector: SolidLineConnector(
                    color: connectorColor,
                    thickness: 2.0,
                    space: 24,
                  ),
                  endConnector: null,
                ),
                contents: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 12, bottom: 24),
                  child: widget.isLoadingMore
                      ? Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.expenditureLoadingEarlier,
                                    track: shared
                                        .TrackConstants
                                        .expenditurePageTrack,
                                  ) ??
                                  'Loading earlier transactions...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        )
                      : InkWell(
                          onTap: widget.onLoadMore,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.tr(
                                        shared.LocaleKeys.expenditureLoadMore,
                                        track: shared
                                            .TrackConstants
                                            .expenditurePageTrack,
                                      ) ??
                                      'Load more transactions',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              );
            }

            final dateKey = dateKeys[dateIndex];
            final items = widget.groupedTransactions[dateKey] ?? [];
            final dayIncome = widget.dailyIncomeTotals[dateKey] ?? 0.0;
            final dayExpense = widget.dailyExpenseTotals[dateKey] ?? 0.0;
            final isLastGroup =
                (dateIndex == dateKeys.length - 1) && !showBottomLoader;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date header tile ──────────────────────────────────────
                TimelineTile(
                  nodeAlign: TimelineNodeAlign.start,
                  contents: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 16,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateKey.contains('(Today)')
                                ? '${dateKey.replaceAll(' (Today)', '')} (${context.tr(shared.LocaleKeys.commonToday, track: shared.TrackConstants.commonTrack) ?? 'Today'})'
                                : dateKey,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (dayIncome > 0) ...[
                          Text(
                            '+ ${core.CurrencyFormatter.format(value: dayIncome)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: incomeColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (dayExpense > 0)
                          Text(
                            '- ${core.CurrencyFormatter.format(value: dayExpense)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: expenseColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  node: TimelineNode(
                    indicator: DotIndicator(
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    // No connector above the first group's date header
                    startConnector: dateIndex == 0
                        ? null
                        : SolidLineConnector(
                            color: connectorColor,
                            thickness: 2.0,
                            space: 24,
                          ),
                    // Connect down to first item
                    endConnector: items.isEmpty
                        ? null
                        : SolidLineConnector(
                            color: connectorColor,
                            thickness: 2.0,
                            space: 24,
                          ),
                  ),
                ),

                // ── Item tiles ────────────────────────────────────────────
                ...List.generate(items.length, (i) {
                  final isLastItem = isLastGroup && i == items.length - 1;
                  return CashFlowTimelineItem(
                    item: items[i],
                    isLast: isLastItem,
                    onDelete: () => widget.onItemDelete?.call(items[i]),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
