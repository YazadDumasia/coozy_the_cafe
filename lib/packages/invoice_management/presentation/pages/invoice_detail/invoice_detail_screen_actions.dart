import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/settings/coozy_settings.dart'
    as settings;

import '../../bloc/invoice_management_bloc.dart';
import '../../../domain/entities/invoice_management_entity.dart';
import '../../../domain/services/invoice_pdf_generator.dart';
import '../../../domain/services/invoice_share_service.dart';
import '../../widgets/invoice_pdf_preview_dialog/invoice_pdf_preview_dialog.dart';

class InvoiceDetailScreenActions {
  static void onReturn(BuildContext context, InvoiceDetailsEntity details) {
    shared.SnackBarUtils.showInfo(context, message: 'Return requested');
  }

  static Future<void> onDelete(
    BuildContext context,
    int invoiceId, {
    bool fromCheckout = false,
  }) async {
    final bool? isConfirmed =
        await shared.DialogUtils.showConfirmationDialog<bool>(
          context: context,
          title:
              context.tr(
                shared.LocaleKeys.commonDelete,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Delete Receipt',
          content: 'Are you sure you want to delete this receipt? This will soft delete the invoice and its linked order.',
          cancelText:
              context.tr(
                shared.LocaleKeys.commonCancel,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Cancel',
          confirmText:
              context.tr(
                shared.LocaleKeys.commonDelete,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Delete',
        );

    if (isConfirmed == true && context.mounted) {
      context.read<InvoiceManagementBloc>().add(DeleteInvoiceEvent(invoiceId));
      if (fromCheckout) {
        context.go(core.AppRoutePath.homeRoute);
      } else if (Navigator.of(context).canPop()) {
        context.pop();
      } else {
        context.go(core.AppRoutePath.homeRoute);
      }
    }
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
      shared.SnackBarUtils.showWarning(
        context,
        message: 'Please wait for invoice details to load.',
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
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to share invoice PDF: $e',
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
      shared.SnackBarUtils.showWarning(
        context,
        message: 'Please wait for invoice details to load.',
      );
      return;
    }

    final summary = await InvoiceShareService.instance.buildShareMessage(invoiceDetails);
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
      shared.SnackBarUtils.showWarning(
        context,
        message: 'Please wait for invoice details to load.',
      );
      return;
    }

    final summary = await InvoiceShareService.instance.buildShareMessage(invoiceDetails);
    final phone = invoiceDetails.invoice.phoneNumber?.trim() ?? '';
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanPhone.isNotEmpty) {
      try {
        final whatsappUri = Uri.parse(
          'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(summary)}',
        );
        if (await canLaunchUrl(whatsappUri)) {
          final launched = await launchUrl(
            whatsappUri,
            mode: LaunchMode.externalApplication,
          );
          if (launched) return;
        }
      } catch (_) {}
    }

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

  static Future<void> onPreviewPdf(
    BuildContext context, {
    InvoiceDetailsEntity? details,
  }) async {
    final invoiceDetails = _resolveDetails(context, details);
    if (invoiceDetails == null) {
      shared.SnackBarUtils.showWarning(
        context,
        message: 'Please wait for invoice details to load.',
      );
      return;
    }

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogCtx) =>
            InvoicePdfPreviewDialog(details: invoiceDetails),
      );
    }
  }

  static Future<void> onOpenPdf(
    BuildContext context, {
    InvoiceDetailsEntity? details,
    String? filePath,
  }) async {
    final invoiceDetails = _resolveDetails(context, details);
    if (invoiceDetails == null) {
      shared.SnackBarUtils.showWarning(
        context,
        message: 'Please wait for invoice details to load.',
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

    // Fallback or Web: display in-app preview dialog using SfPdfViewer
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: true,
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
      shared.SnackBarUtils.showWarning(
        context,
        message: 'Please wait for invoice details to load.',
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

        final openLabel =
            context.tr(
              shared.LocaleKeys.invoiceActionOpen,
              track: shared.TrackConstants.invoicePageTrack,
            ) ??
            'Open';

        final shareLabel =
            context.tr(
              shared.LocaleKeys.invoiceActionShare,
              track: shared.TrackConstants.invoicePageTrack,
            ) ??
            'Share';

        shared.SnackBarUtils.showActionNotification(
          context,
          title: successTitle,
          subtitle: fileName.isNotEmpty ? fileName : null,
          duration: const Duration(seconds: 6),
          actions: [
            shared.SnackBarActionItem(
              label: openLabel,
              textColor: Colors.amberAccent,
              onPressed: () {
                onOpenPdf(
                  context,
                  details: invoiceDetails,
                  filePath: result.filePath,
                );
              },
            ),
            shared.SnackBarActionItem(
              label: shareLabel,
              textColor: Colors.white,
              onPressed: () {
                InvoicePdfGenerator.sharePdf(details: invoiceDetails);
              },
            ),
          ],
        );
      } else {
        final String errorMsg = result.errorMessage ?? 'Unknown error';
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to save invoice PDF: $errorMsg',
        );
      }
    } catch (e) {
      if (context.mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to save invoice PDF: $e',
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
      shared.SnackBarUtils.showWarning(
        context,
        message: 'Please wait for invoice details to load.',
      );
      return;
    }

    try {
      final config = await settings.ThermalPrinterService.instance
          .getPrinterConfig(
            stationKey: shared.PreferencesKeys.customerReceiptPrinterConfig,
          );

      if (config.type == settings.ThermalPrinterType.systemSpooler) {
        await InvoicePdfGenerator.printPdf(details: invoiceDetails);
      } else {
        final bytes =
            await settings.EscPosTicketBuilder.buildCustomerReceiptBytes(
              details: invoiceDetails,
              paperSize: config.paperSize,
            );
        final success = await settings.ThermalPrinterService.instance
            .printBytesWithConfig(
              config: config,
              bytes: bytes,
              jobName: 'Receipt ${invoiceDetails.invoice.hashId}',
            );
        if (context.mounted) {
          if (success) {
            shared.SnackBarUtils.showSuccess(
              context,
              message: 'Receipt sent to thermal printer successfully!',
            );
          } else {
            shared.SnackBarUtils.showError(
              context,
              message: 'Failed to send receipt to thermal printer.',
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to print invoice: $e',
        );
      }
    }
  }
}
