import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/active_table_orders_bloc.dart';
import '../navigation/waiter_order_placement_routes.dart';
import 'waiter_order_placement/widget/active_table_order_card.dart';

class WaiterOrderPlacementScreen extends StatelessWidget {
  const WaiterOrderPlacementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ActiveTableOrdersBloc>(
      create: (context) =>
          sl<ActiveTableOrdersBloc>()..add(const LoadActiveTableOrdersEvent()),
      child: const WaiterOrderPlacementView(),
    );
  }
}

class WaiterOrderPlacementView extends StatelessWidget {
  const WaiterOrderPlacementView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Material(
              type: MaterialType.card,
              child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final bool
                    isQrDirectScan = shared.LocalManager.instance.getBoolValue(
                      key: shared.PreferencesKeys.enableQrScannerOrderPlacement,
                    );

                    if (isQrDirectScan) {
                      await context.push('/table-qr-scanner');
                    } else {
                      await context.push(AppRoutePath.tablePickerScreenRoute);
                    }

                    if (context.mounted) {
                      context.read<ActiveTableOrdersBloc>().add(
                        const LoadActiveTableOrdersEvent(),
                      );
                    }
                  },
                  child: Builder(
                    builder: (context) {
                      final bool isQrDirectScan = shared.LocalManager.instance
                          .getBoolValue(
                            key: shared
                                .PreferencesKeys
                                .enableQrScannerOrderPlacement,
                          );

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isQrDirectScan
                                ? Icons.qr_code_scanner_rounded
                                : CupertinoIcons.add_circled_solid,
                            size: 34,
                            color: Colors.green,
                          ),
                          Text(
                            isQrDirectScan
                                ? (context.tr(
                                        shared
                                            .LocaleKeys
                                            .scanQrCodeToPlaceOrder,
                                        track: shared
                                            .TrackConstants
                                            .tablePageTrack,
                                      ) ??
                                      'Scan QR code to place order')
                                : (context.tr(
                                        shared.LocaleKeys.addNewOrderBtnText,
                                        track: shared
                                            .TrackConstants
                                            .tablePageTrack,
                                      ) ??
                                      'Add New Order'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ).inExpandedRow().paddingSymmetric(vertical: 10),
                        ],
                      ).paddingSymmetric(horizontal: 10, vertical: 40);
                    },
                  ),
                ),
              ),
            ).inExpandedRow(),
            Expanded(
              child: BlocBuilder<ActiveTableOrdersBloc, ActiveTableOrdersState>(
                builder: (context, state) {
                  if (state is ActiveTableOrdersLoading ||
                      state is ActiveTableOrdersInitial) {
                    return const shared.LoadingPage();
                  } else if (state is ActiveTableOrdersError) {
                    return shared.ErrorPage(
                      errorMsg: state.message,
                      onPressedRetryButton: () {
                        context.read<ActiveTableOrdersBloc>().add(
                          const LoadActiveTableOrdersEvent(),
                        );
                      },
                    );
                  } else if (state is ActiveTableOrdersLoaded) {
                    final orders = state.orders;

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ActiveTableOrdersBloc>().add(
                          const LoadActiveTableOrdersEvent(),
                        );
                      },
                      child: Scrollbar(
                        interactive: true,
                        child: SingleChildScrollView(
                          primary: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                child: Text(
                                  context.tr(
                                        shared.LocaleKeys.totalTableOrders,
                                        track: shared
                                            .TrackConstants
                                            .menuItemPageTrack,
                                        params: {"count": "${orders.length}"},
                                      ) ??
                                      'Total Table Orders: ${orders.length}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (orders.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: orders.length,
                                  addAutomaticKeepAlives: false,
                                  addRepaintBoundaries: true,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    return ActiveTableOrderCard(
                                      order: order,
                                      onItemTap: () async {
                                        await context.push(
                                          WaiterOrderPlacementRoutes
                                              .menuItemPickerRoute,
                                          extra: {'orderId': order.orderId},
                                        );
                                        if (context.mounted) {
                                          context
                                              .read<ActiveTableOrdersBloc>()
                                              .add(
                                                const LoadActiveTableOrdersEvent(),
                                              );
                                        }
                                      },
                                      onDeleteConfirmed: () {
                                        context
                                            .read<ActiveTableOrdersBloc>()
                                            .add(
                                              DeleteTableOrderEvent(
                                                order.orderId,
                                              ),
                                            );
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
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
