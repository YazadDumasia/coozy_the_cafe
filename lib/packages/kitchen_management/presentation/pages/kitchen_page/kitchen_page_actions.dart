import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/kitchen_bloc.dart';

/// User action handlers and BLoC event triggers for the Kitchen display screen.
class KitchenPageActions {
  /// Reloads active kitchen orders from the database.
  static void refreshOrders(BuildContext context) {
    context.read<KitchenBloc>().add(const LoadKitchenOrdersEvent());
  }

  /// Switches the kitchen layout mode (e.g. grid vs list).
  static void changeViewMode(BuildContext context, KitchenViewMode mode) {
    context.read<KitchenBloc>().add(ToggleViewModeEvent(mode));
  }

  /// Filters kitchen orders based on processing status (pending, preparing, ready).
  static void changeStatusFilter(BuildContext context, String filter) {
    context.read<KitchenBloc>().add(FilterStatusChangedEvent(filter));
  }

  /// Updates status for an individual kitchen order line item.
  static void updateItemStatus(
    BuildContext context, {
    required int orderItemId,
    required String newStatus,
  }) {
    context.read<KitchenBloc>().add(
      UpdateItemStatusEvent(orderItemId: orderItemId, newStatus: newStatus),
    );
  }

  /// Advances or bumps all pending line items for an entire order to [newStatus].
  static void bumpOrder(
    BuildContext context, {
    required int orderId,
    required String newStatus,
  }) {
    context.read<KitchenBloc>().add(
      BumpAllOrderItemsEvent(orderId: orderId, newStatus: newStatus),
    );
  }
}
