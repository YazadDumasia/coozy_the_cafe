import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';
import '../../../domain/services/invoice_pdf_generator.dart';

class InvoiceDetailScreenActions {
  static void onReturn(BuildContext context, InvoiceDetailsEntity details) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Return requested')),
    );
  }

  static void onDelete(
    BuildContext context,
    int invoiceId, {
    bool fromCheckout = false,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Receipt'),
        content: const Text(
          'Are you sure you want to delete this receipt? This will soft delete the invoice and its linked order.',
        ),
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
              if (fromCheckout) {
                context.go(core.AppRoutePath.homeRoute);
              } else if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go(core.AppRoutePath.homeRoute);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Future<bool?> onEdit(
    BuildContext context,
    InvoiceDetailsEntity details,
  ) async {
    final result = await context.push<bool>(
      core.AppRoutePath.invoiceEditRoute(details.invoice.id),
      extra: details,
    );
    if (result == true && context.mounted) {
      if (details.invoice.id > 0) {
        context.read<InvoiceManagementBloc>().add(
              LoadInvoiceDetailsEvent(details.invoice.id),
            );
      } else if (details.invoice.hashId.isNotEmpty) {
        context.read<InvoiceManagementBloc>().add(
              LoadInvoiceDetailsByHashIdEvent(details.invoice.hashId),
            );
      }
      return true;
    }
    return null;
  }

  static InvoiceDetailsEntity? _resolveDetails(
    BuildContext context,
    InvoiceDetailsEntity? details,
  ) {
    if (details != null) return details;
    final state = context.read<InvoiceManagementBloc>().state;
    if (state is InvoiceManagementLoadedState) {
      return state.selectedInvoiceDetails;
    }
    return null;
  }

  static Future<void> onShare(
    BuildContext context, {
    InvoiceDetailsEntity? details,
    Rect? sharePositionOrigin,
  }) async {
    final invoiceDetails = _resolveDetails(context, details);
    if (invoiceDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for invoice details to load.'),
        ),
      );
      return;
    }

    try {
      await InvoicePdfGenerator.sharePdf(
        details: invoiceDetails,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share invoice PDF: $e')),
        );
      }
    }
  }

  static Future<void> onSendSms(
    BuildContext context, {
    InvoiceDetailsEntity? details,
  }) async {
    final invoiceDetails = _resolveDetails(context, details);
    if (invoiceDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for invoice details to load.'),
        ),
      );
      return;
    }

    final summary = _buildInvoiceTextSummary(invoiceDetails);
    final receiptNo = invoiceDetails.invoice.hashId.isNotEmpty
        ? invoiceDetails.invoice.hashId
        : 'MD-${invoiceDetails.invoice.id}';

    await SharePlus.instance.share(
      ShareParams(
        text: summary,
        subject: 'Receipt $receiptNo - Coozy The Cafe',
      ),
    );
  }

  static Future<void> onWhatsApp(
    BuildContext context, {
    InvoiceDetailsEntity? details,
  }) async {
    final invoiceDetails = _resolveDetails(context, details);
    if (invoiceDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for invoice details to load.'),
        ),
      );
      return;
    }

    final summary = _buildInvoiceTextSummary(invoiceDetails);
    final receiptNo = invoiceDetails.invoice.hashId.isNotEmpty
        ? invoiceDetails.invoice.hashId
        : 'MD-${invoiceDetails.invoice.id}';

    await SharePlus.instance.share(
      ShareParams(
        text: summary,
        subject: 'Receipt $receiptNo - Coozy The Cafe',
      ),
    );
  }

  static Future<void> onDownload(
    BuildContext context, {
    InvoiceDetailsEntity? details,
  }) async {
    final invoiceDetails = _resolveDetails(context, details);
    if (invoiceDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for invoice details to load.'),
        ),
      );
      return;
    }

    try {
      final result = await InvoicePdfGenerator.downloadOrSavePdf(
        details: invoiceDetails,
      );

      if (!context.mounted) return;

      if (result.isSuccess) {
        final String successText = result.isWeb
            ? 'Invoice PDF download started!'
            : 'Invoice PDF saved: ${result.filePath}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successText),
            duration: const Duration(seconds: 4),
            action: (!result.isWeb && result.filePath != null)
                ? SnackBarAction(
                    label: 'Share',
                    onPressed: () {
                      InvoicePdfGenerator.sharePdf(details: invoiceDetails);
                    },
                  )
                : null,
          ),
        );
      } else {
        final String errorMsg = result.errorMessage ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save invoice PDF: $errorMsg')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save invoice PDF: $e')),
        );
      }
    }
  }

  static Future<void> onPrint(
    BuildContext context, {
    InvoiceDetailsEntity? details,
  }) async {
    final invoiceDetails = _resolveDetails(context, details);
    if (invoiceDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for invoice details to load.'),
        ),
      );
      return;
    }

    try {
      await InvoicePdfGenerator.printPdf(details: invoiceDetails);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to print invoice: $e')),
        );
      }
    }
  }

  static String _buildInvoiceTextSummary(InvoiceDetailsEntity details) {
    final inv = details.invoice;
    final receiptNo = inv.hashId.isNotEmpty ? inv.hashId : 'MD-${inv.id}';
    final buffer = StringBuffer();
    buffer.writeln('COOZY THE CAFE - INVOICE');
    buffer.writeln('Receipt No: $receiptNo');
    if (inv.createdDate != null) {
      buffer.writeln(
        'Date: ${core.DateUtil.localFormat(inv.createdDate, 'dd MMM yyyy - hh:mm a') ?? inv.createdDate}',
      );
    }
    if (details.tableName != null && details.tableName!.isNotEmpty) {
      buffer.writeln('Table: ${details.tableName}');
    }
    buffer.writeln('----------------------');
    for (final item in details.items) {
      buffer.writeln(
        '${item.itemName} x${item.quantity} = ${core.CurrencyFormatter.format(value: item.totalPrice)}',
      );
    }
    buffer.writeln('----------------------');
    buffer.writeln('Subtotal: ${core.CurrencyFormatter.format(value: inv.totalCost)}');
    if (inv.discountAmount > 0) {
      buffer.writeln('Discount: -${core.CurrencyFormatter.format(value: inv.discountAmount)}');
    }
    if (inv.taxCost > 0) {
      buffer.writeln('Tax: +${core.CurrencyFormatter.format(value: inv.taxCost)}');
    }
    buffer.writeln('Grand Total: ${core.CurrencyFormatter.format(value: inv.netPaymentAmount)}');
    buffer.writeln('Payment: ${inv.paymentMethodName ?? 'Cash'}');
    buffer.writeln('Thank you for visiting Coozy The Cafe!');
    return buffer.toString();
  }
}
