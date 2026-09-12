import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';
import '../../../domain/services/invoice_pdf_generator.dart';
import '../../widgets/invoice_pdf_preview_dialog/invoice_pdf_preview_dialog.dart';

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

  static Future<void> onOpenPdf(
    BuildContext context, {
    InvoiceDetailsEntity? details,
    String? filePath,
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

    if (!kIsWeb && filePath != null && filePath.isNotEmpty) {
      try {
        final openResult = await OpenFilex.open(
          filePath,
          type: 'application/pdf',
        );
        if (openResult.type == ResultType.done) {
          return;
        }
      } catch (e) {
        core.PlatformUtils.debugLog(
          InvoiceDetailScreenActions,
          'OpenFilex failed, falling back to in-app preview: $e',
        );
      }
    }

    // Fallback or Web: display in-app preview dialog using pdfrx
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (dialogCtx) => InvoicePdfPreviewDialog(
          details: invoiceDetails,
          filePath: filePath,
        ),
      );
    }
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
        final String fileName = (result.filePath != null && !result.isWeb)
            ? result.filePath!.split(Platform.pathSeparator).last
            : '';
        final String successTitle = result.isWeb
            ? (context.tr(
                  shared.LocaleKeys.invoiceDownloadSuccessWeb,
                  track: shared.TrackConstants.invoicePageTrack,
                ) ??
                'Invoice PDF downloaded!')
            : (context.tr(
                  shared.LocaleKeys.invoiceDownloadSuccess,
                  track: shared.TrackConstants.invoicePageTrack,
                ) ??
                'Invoice PDF saved successfully!');

        final openLabel = context.tr(
              shared.LocaleKeys.invoiceActionOpen,
              track: shared.TrackConstants.invoicePageTrack,
            ) ??
            'Open';

        final shareLabel = context.tr(
              shared.LocaleKeys.invoiceActionShare,
              track: shared.TrackConstants.invoicePageTrack,
            ) ??
            'Share';

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.greenAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        successTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (fileName.isNotEmpty)
                        Text(
                          fileName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onOpenPdf(
                      context,
                      details: invoiceDetails,
                      filePath: result.filePath,
                    );
                  },
                  child: Text(
                    openLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    InvoicePdfGenerator.sharePdf(
                      details: invoiceDetails,
                    );
                  },
                  child: Text(
                    shareLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
