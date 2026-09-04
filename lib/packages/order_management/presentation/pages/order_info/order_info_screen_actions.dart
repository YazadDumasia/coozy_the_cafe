import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/order_management_bloc.dart';

class OrderInfoScreenActions {
  OrderInfoScreenActions._();

  static void onUpdateStatus(
    BuildContext context, {
    required int orderId,
    required String status,
  }) {
    context.read<OrderManagementBloc>().add(
          UpdateOrderStatusEvent(
            orderId: orderId,
            status: status,
          ),
        );
    Navigator.of(context).pop();
  }

  static void onInvoiceInfo(
    BuildContext context, {
    required int orderId,
  }) {
    // Action handler for Invoice Info navigation / details for later development
  }
}
