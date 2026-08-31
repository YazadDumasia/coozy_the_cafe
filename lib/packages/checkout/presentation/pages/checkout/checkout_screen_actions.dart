import 'package:coozy_the_cafe/packages/waiter_order_placement/waiter_order_placement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/checkout_bloc.dart';
import 'widget/checkout_barcode_scanner_dialog.dart';

mixin CheckoutScreenActions {
  void handleAddItem(BuildContext context) async {
    final orderIdStr = context.read<CheckoutBloc>().state.orderId;
    final orderId = orderIdStr != null ? int.tryParse(orderIdStr) : null;

    await context.push(
      WaiterOrderPlacementRoutes.menuItemPickerRoute,
      extra: orderId,
    );

    if (context.mounted && orderIdStr != null && orderIdStr.isNotEmpty) {
      context.read<CheckoutBloc>().add(CheckoutFetchStarted(orderIdStr));
    }
  }

  void handleBarcodeScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CheckoutBarcodeScannerDialog(
        checkoutBloc: context.read<CheckoutBloc>(),
      ),
    );
  }
}
