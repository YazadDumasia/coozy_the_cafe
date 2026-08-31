import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../bloc/kitchen_bloc.dart';
import 'kitchen_screen_actions.dart';
import 'widget/kitchen_summary_view.dart';
import 'widget/kitchen_ticket_card.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  @override
  void initState() {
    super.initState();
    KitchenScreenActions.refreshOrders(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // const Icon(Icons.kitchen_outlined),
            // const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr(shared.LocaleKeys.kitchenDisplaySystem, track: shared.TrackConstants.orderPageTrack) ??
                    'Kitchen Display System',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip:
                context.tr(shared.LocaleKeys.kitchenRefreshOrders, track: shared.TrackConstants.orderPageTrack) ??
                'Refresh Orders',
            onPressed: () => KitchenScreenActions.refreshOrders(context),
          ),
        ],
      ),
      body: BlocBuilder<KitchenBloc, KitchenState>(
        builder: (context, state) {
          if (state is KitchenLoadingState || state is KitchenInitialState) {
            return const shared.LoadingPage();
          } else if (state is KitchenErrorState) {
            return shared.ErrorPage(
              errorMsg: state.message,
              onPressedRetryButton: () =>
                  KitchenScreenActions.refreshOrders(context),
            );
          } else if (state is KitchenLoadedState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<KitchenViewMode>(
                          segments: [
                            ButtonSegment(
                              value: KitchenViewMode.tickets,
                              icon: const Icon(Icons.receipt_long),
                              label: Text(
                                context.tr(
                                      shared.LocaleKeys.kitchenViewTickets,
                                    ) ??
                                    'Tickets',
                              ),
                            ),
                            ButtonSegment(
                              value: KitchenViewMode.aggregated,
                              icon: const Icon(Icons.restaurant),
                              label: Text(
                                context.tr(
                                      shared.LocaleKeys.kitchenViewSummary,
                                    ) ??
                                    'Summary',
                              ),
                            ),
                          ],
                          selected: {state.viewMode},
                          onSelectionChanged: (selected) {
                            if (selected.isNotEmpty) {
                              KitchenScreenActions.changeViewMode(
                                context,
                                selected.first,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.viewMode == KitchenViewMode.aggregated
                      ? KitchenSummaryView(items: state.aggregatedItems)
                      : (state.filteredOrders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 72,
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .kitchenAllOrdersPreparedTitle,
                                              ) ??
                                              'All Kitchen Orders Prepared!',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        )
                                        .inExpandedRow(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                        )
                                        .paddingSymmetric(horizontal: 10),
                                    const SizedBox(height: 8),
                                    Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .kitchenNoPendingOrdersSubtitle,
                                              ) ??
                                              'No pending orders in queue.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                          textAlign: TextAlign.center,
                                        )
                                        .inExpandedRow(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                        )
                                        .paddingSymmetric(horizontal: 10),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          KitchenScreenActions.refreshOrders(
                                            context,
                                          ),
                                      icon: const Icon(Icons.refresh),
                                      label: Text(
                                        context.tr(
                                              shared
                                                  .LocaleKeys
                                                  .kitchenRefreshQueueBtn,
                                            ) ??
                                            'Refresh Kitchen Queue',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount = 1;
                                  if (constraints.maxWidth > 1200) {
                                    crossAxisCount = 4;
                                  } else if (constraints.maxWidth > 800) {
                                    crossAxisCount = 3;
                                  } else if (constraints.maxWidth > 550) {
                                    crossAxisCount = 2;
                                  }

                                  return MasonryGridView.count(
                                    padding: const EdgeInsets.all(16),
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    itemCount: state.filteredOrders.length,
                                    itemBuilder: (context, index) {
                                      final order = state.filteredOrders[index];
                                      return KitchenTicketCard(
                                        order: order,
                                        onItemStatusChanged:
                                            (orderItemId, newStatus) {
                                              KitchenScreenActions.updateItemStatus(
                                                context,
                                                orderItemId: orderItemId,
                                                newStatus: newStatus,
                                              );
                                            },
                                        onBumpOrder: (orderId, newStatus) {
                                          KitchenScreenActions.bumpOrder(
                                            context,
                                            orderId: orderId,
                                            newStatus: newStatus,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              )),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
