import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/entities/stock_alert.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/entities/auto_reorder_suggestion.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/cubit/stock_alerts_cubit.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/pages/stock_alerts_page/stock_alerts_page_actions.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/pages/stock_alerts_page/widget/stock_alerts_empty_view.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/pages/stock_alerts_page/widget/stock_alert_card.dart';

class StockAlertsPage extends StatefulWidget {
  const StockAlertsPage({super.key});

  @override
  State<StockAlertsPage> createState() => _StockAlertsPageState();
}

class _StockAlertsPageState extends State<StockAlertsPage> {
  late final StockAlertsCubit _cubit;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final ValueNotifier<AlertSeverity?> _severityFilterNotifier;

  @override
  void initState() {
    super.initState();
    _cubit = GetIt.instance<StockAlertsCubit>();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _severityFilterNotifier = ValueNotifier<AlertSeverity?>(null);

    // Initial scan on launch
    _cubit.scanDeficits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _severityFilterNotifier.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<StockAlertsCubit, StockAlertsState>(
        listener: (context, state) {
          if (state is StockAlertsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade700,
              ),
            );
          } else if (state is StockAlertsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Stock Deficit & Reorder Alerts'),
              actions: [
                IconButton(
                  tooltip: 'Scan for Deficits',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () =>
                      StockAlertsPageActions.scanDeficits(context, _cubit),
                ),
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text('1-Click Reorder'),
                  onPressed: () =>
                      StockAlertsPageActions.openReorderSummaryDialog(
                        context: context,
                        cubit: _cubit,
                      ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: Column(
              children: [
                // Filter bar & Search
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                  child: ValueListenableBuilder<AlertSeverity?>(
                    valueListenable: _severityFilterNotifier,
                    builder: (context, activeSeverity, _) {
                      final isMobile = shared.ResponsiveLayout.isMobile(
                        context,
                      );
                      final chips = [
                        FilterChip(
                          label: const Text('All'),
                          selected: activeSeverity == null,
                          onSelected: (_) {
                            _severityFilterNotifier.value = null;
                            _cubit.applyFilter(
                              query: _searchController.text,
                              severity: null,
                            );
                          },
                        ),
                        FilterChip(
                          label: const Text('Out of Stock'),
                          selected: activeSeverity == AlertSeverity.outOfStock,
                          onSelected: (sel) {
                            final sev = sel ? AlertSeverity.outOfStock : null;
                            _severityFilterNotifier.value = sev;
                            _cubit.applyFilter(
                              query: _searchController.text,
                              severity: sev,
                            );
                          },
                        ),
                        FilterChip(
                          label: const Text('Critical'),
                          selected: activeSeverity == AlertSeverity.critical,
                          onSelected: (sel) {
                            final sev = sel ? AlertSeverity.critical : null;
                            _severityFilterNotifier.value = sev;
                            _cubit.applyFilter(
                              query: _searchController.text,
                              severity: sev,
                            );
                          },
                        ),
                        FilterChip(
                          label: const Text('Low Stock'),
                          selected: activeSeverity == AlertSeverity.warning,
                          onSelected: (sel) {
                            final sev = sel ? AlertSeverity.warning : null;
                            _severityFilterNotifier.value = sev;
                            _cubit.applyFilter(
                              query: _searchController.text,
                              severity: sev,
                            );
                          },
                        ),
                      ];

                      final searchField = TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search stock deficit by item...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _cubit.applyFilter(
                                      query: '',
                                      severity: activeSeverity,
                                    );
                                  },
                                )
                              : null,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (val) {
                          _cubit.applyFilter(
                            query: val,
                            severity: activeSeverity,
                          );
                        },
                      );

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            searchField,
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var i = 0; i < chips.length; i++) ...[
                                    chips[i],
                                    if (i < chips.length - 1)
                                      const SizedBox(width: 6),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: searchField),
                          const SizedBox(width: 12),
                          Wrap(spacing: 6, children: chips),
                        ],
                      );
                    },
                  ),
                ),

                // Main Content
                Expanded(
                  child: _buildBody(context, state, isDesktop, isTablet),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    StockAlertsState state,
    bool isDesktop,
    bool isTablet,
  ) {
    if (state is StockAlertsLoading) {
      return const shared.LoadingPage();
    } else if (state is StockAlertsError) {
      return shared.ErrorPage(
        errorMsg: state.errorMessage,
        onPressedRetryButton: () => _cubit.scanDeficits(),
      );
    } else if (state is StockAlertsLoaded) {
      final alerts = state.filteredAlerts;

      if (alerts.isEmpty) {
        return StockAlertsEmptyView(onRefresh: () => _cubit.scanDeficits());
      }

      // Responsive Grid / List Builder adhering to Rule 5 & 9
      final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

      if (crossAxisCount == 1) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: alerts.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return StockAlertCard(
              alert: alert,
              onDismiss: () =>
                  StockAlertsPageActions.dismissAlert(context, _cubit, alert),
              onReorder: () {
                _cubit.reorderBatch([
                  AutoReorderSuggestion(
                    inventoryId: alert.inventoryId,
                    inventoryName: alert.inventoryName,
                    currentStock: alert.currentStock,
                    minThreshold: alert.minThreshold,
                    suggestedReorderQty: alert.deficit > 0
                        ? alert.deficit
                        : 10.0,
                    purchaseUnit: alert.purchaseUnit,
                  ),
                ]);
              },
              onConfigureThreshold: () {
                StockAlertsPageActions.openConfigureThresholdDialog(
                  context: context,
                  cubit: _cubit,
                  inventoryId: alert.inventoryId,
                  itemName: alert.inventoryName,
                  currentMinThreshold: alert.minThreshold,
                  currentReorderQuantity: alert.deficit > 0
                      ? alert.deficit
                      : 10.0,
                );
              },
            );
          },
        );
      } else {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isDesktop ? 1.7 : 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: alerts.length,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return StockAlertCard(
              alert: alert,
              onDismiss: () =>
                  StockAlertsPageActions.dismissAlert(context, _cubit, alert),
              onReorder: () {
                _cubit.reorderBatch([
                  AutoReorderSuggestion(
                    inventoryId: alert.inventoryId,
                    inventoryName: alert.inventoryName,
                    currentStock: alert.currentStock,
                    minThreshold: alert.minThreshold,
                    suggestedReorderQty: alert.deficit > 0
                        ? alert.deficit
                        : 10.0,
                    purchaseUnit: alert.purchaseUnit,
                  ),
                ]);
              },
              onConfigureThreshold: () {
                StockAlertsPageActions.openConfigureThresholdDialog(
                  context: context,
                  cubit: _cubit,
                  inventoryId: alert.inventoryId,
                  itemName: alert.inventoryName,
                  currentMinThreshold: alert.minThreshold,
                  currentReorderQuantity: alert.deficit > 0
                      ? alert.deficit
                      : 10.0,
                );
              },
            );
          },
        );
      }
    }

    return const shared.LoadingPage();
  }
}
