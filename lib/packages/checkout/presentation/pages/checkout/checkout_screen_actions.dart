import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/checkout_bloc.dart';
import 'widget/checkout_barcode_scanner_dialog.dart';

mixin CheckoutScreenActions {
  void handleAddItem(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add New Item clicked')),
    );
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
