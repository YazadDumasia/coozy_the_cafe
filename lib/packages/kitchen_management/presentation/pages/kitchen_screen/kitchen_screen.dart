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
            const Icon(Icons.kitchen_outlined),
            const SizedBox(width: 8),
            Text(
              context.tr(shared.LocaleKeys.kitchenDisplaySystem) ??
                  'Kitchen Display System',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: () => KitchenScreenActions.refreshOrders(context),
          ),
          BlocBuilder<KitchenBloc, KitchenState>(
            builder: (context, state) {
              if (state is! KitchenLoadedState) return const SizedBox.shrink();
              return SegmentedButton<KitchenViewMode>(
                segments: const [
                  ButtonSegment(
                    value: KitchenViewMode.tickets,
                    icon: Icon(Icons.receipt_long),
                    label: Text('Tickets'),
                  ),
                  ButtonSegment(
                    value: KitchenViewMode.aggregated,
                    icon: Icon(Icons.restaurant_menu),
                    label: Text('Summary'),
                  ),
                ],
                selected: {state.viewMode},
                onSelectionChanged: (selection) {
                  KitchenScreenActions.changeViewMode(context, selection.first);
                },
              );
            },
          ),
          const SizedBox(width: 16),
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
            if (state.viewMode == KitchenViewMode.aggregated) {
              return KitchenSummaryView(items: state.aggregatedItems);
            }

            final orders = state.filteredOrders;

            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 72,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All Kitchen Orders Prepared!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No pending orders in queue.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          KitchenScreenActions.refreshOrders(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Kitchen Queue'),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
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
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return KitchenTicketCard(
                      order: order,
                      onItemStatusChanged: (orderItemId, newStatus) {
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
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
