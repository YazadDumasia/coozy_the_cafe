import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/kitchen_bloc.dart';

class KitchenScreenActions {
  static void refreshOrders(BuildContext context) {
    context.read<KitchenBloc>().add(const LoadKitchenOrdersEvent());
  }

  static void changeViewMode(BuildContext context, KitchenViewMode mode) {
    context.read<KitchenBloc>().add(ToggleViewModeEvent(mode));
  }

  static void changeStatusFilter(BuildContext context, String filter) {
    context.read<KitchenBloc>().add(FilterStatusChangedEvent(filter));
  }

  static void updateItemStatus(
    BuildContext context, {
    required int orderItemId,
    required String newStatus,
  }) {
    context.read<KitchenBloc>().add(
      UpdateItemStatusEvent(orderItemId: orderItemId, newStatus: newStatus),
    );
  }

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
