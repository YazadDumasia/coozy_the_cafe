import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../../bloc/order_management_bloc.dart';
import '../../../domain/entities/order_management_entity.dart';

class OrderListScreenActions {
  OrderListScreenActions._();

  static Future<void> onPickDateRange(BuildContext context) async {
    final state = context.read<OrderManagementBloc>().state;
    DateTimeRange? initialRange;
    if (state is OrderManagementLoadedState) {
      initialRange = state.dateRange;
    }

    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: initialRange,
    );

    if (pickedRange != null && context.mounted) {
      context.read<OrderManagementBloc>().add(
            SelectDateRangeEvent(pickedRange),
          );
    }
  }

  static void onClearDateRange(BuildContext context) {
    context.read<OrderManagementBloc>().add(
          const SelectDateRangeEvent(null),
        );
  }

  static void onStatusFilterChanged(BuildContext context, String status) {
    context.read<OrderManagementBloc>().add(
          ChangeStatusFilterEvent(status),
        );
  }

  static void onSearchQueryChanged(BuildContext context, String query) {
    context.read<OrderManagementBloc>().add(
          LoadOrdersEvent(isRefresh: true, searchQuery: query),
        );
  }

  static void onOrderCardTap(BuildContext context, OrderManagementEntity order) {
    context.push(
      AppRoutePath.orderInfoRoute(order.id),
      extra: order,
    );
  }

}
