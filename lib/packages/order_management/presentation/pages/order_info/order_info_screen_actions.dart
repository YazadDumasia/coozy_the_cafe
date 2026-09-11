import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../bloc/order_management_bloc.dart';
import 'package:coozy_the_cafe/packages/invoice_management/invoice_management.dart';

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
    required String orderHashId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => GetIt.instance<InvoiceManagementBloc>(),
          child: InvoiceDetailScreen(orderHashId: orderHashId),
        ),
      ),
    );
  }

  static void onShareOrder(
    BuildContext context, {
    required int orderId,
  }) {
    // Action handler for Share Order functionality for later development
  }
}
