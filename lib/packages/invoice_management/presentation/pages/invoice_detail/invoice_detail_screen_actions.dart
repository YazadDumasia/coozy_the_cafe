import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';

class InvoiceDetailScreenActions {
  static void onReturn(BuildContext context, InvoiceDetailsEntity details) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Return requested')),
    );
  }

  static void onDelete(BuildContext context, int invoiceId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Receipt'),
        content: const Text('Are you sure you want to delete this receipt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<InvoiceManagementBloc>()
                  .add(DeleteInvoiceEvent(invoiceId));
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void onEdit(BuildContext context, InvoiceDetailsEntity details) {
    context.push(
      AppRoutePath.invoiceAddOrEditScreenRoute,
      extra: details,
    );
  }

  static void onShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing invoice receipt...')),
    );
  }

  static void onSendSms(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending SMS receipt...')),
    );
  }

  static void onWhatsApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending via WhatsApp...')),
    );
  }

  static void onDownload(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading PDF...')),
    );
  }

  static void onPrint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Printing receipt...')),
    );
  }
}
