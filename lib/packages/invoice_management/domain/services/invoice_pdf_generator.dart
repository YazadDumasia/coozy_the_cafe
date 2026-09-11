import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../entities/invoice_management_entity.dart';

class _InvoicePdfComputeParams {
  final InvoiceEntity invoice;
  final List<InvoiceItemEntity> items;
  final String? tableName;
  final pw.Font? ttfFont;
  final pw.Font? ttfBoldFont;
  final Uint8List? logoBytes;

  _InvoicePdfComputeParams({
    required this.invoice,
    required this.items,
    this.tableName,
    this.ttfFont,
    this.ttfBoldFont,
    this.logoBytes,
  });
}

/// Service for generating, saving, printing, and sharing cafe invoice/receipt PDFs.
class InvoicePdfGenerator {
  static const String logoAssetPath = 'assets/images/app_logo_clear_bg.png';

  /// Generates a printable PDF receipt for the given [details].
  static Future<Uint8List> generatePdf({
    required InvoiceDetailsEntity details,
  }) async {
    // 1. Pre-load fonts and logo bytes asynchronously
    pw.Font? ttfFont;
    pw.Font? ttfBoldFont;
    try {
      ttfFont = await PdfGoogleFonts.openSansRegular();
      ttfBoldFont = await PdfGoogleFonts.openSansBold();
    } catch (_) {
      try {
        final fontByteData = await rootBundle.load(
          'assets/font/BwAletaNo10/BwAletaNo10_Regular.ttf',
        );
        ttfFont = pw.Font.ttf(fontByteData);
        final boldFontByteData = await rootBundle.load(
          'assets/font/BwAletaNo10/BwAletaNo10_Bold.ttf',
        );
        ttfBoldFont = pw.Font.ttf(boldFontByteData);
      } catch (_) {
        ttfFont = null;
        ttfBoldFont = null;
      }
    }

    Uint8List? logoBytes;
    try {
      final ByteData data = await rootBundle.load(logoAssetPath);
      logoBytes = data.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    final params = _InvoicePdfComputeParams(
      invoice: details.invoice,
      items: details.items,
      tableName: details.tableName,
      ttfFont: ttfFont,
      ttfBoldFont: ttfBoldFont,
      logoBytes: logoBytes,
    );

    // On web, run directly to avoid web worker postMessage serialization hang; on native, use compute!
    if (kIsWeb) {
      return await _generateInvoicePdfInIsolate(params);
    }
    return compute(_generateInvoicePdfInIsolate, params);
  }

  static Future<Uint8List> _generateInvoicePdfInIsolate(
    _InvoicePdfComputeParams params,
  ) async {
    final docTheme = pw.ThemeData.withFont(
      base: params.ttfFont,
      bold: params.ttfBoldFont,
    );

    final pdf = pw.Document(theme: docTheme);
    final inv = params.invoice;
    final items = params.items;
    final tableName = (params.tableName != null && params.tableName!.isNotEmpty)
        ? params.tableName!
        : (inv.orderId != null ? 'Table ${inv.orderId}' : 'Dine-In');

    final String receiptNo =
        inv.hashId.isNotEmpty ? inv.hashId : 'MD-${inv.id}';

    final String createdDateStr = inv.createdDate != null
        ? (core.DateUtil.localFormat(
              inv.createdDate,
              'dd MMM yyyy - hh:mm a',
            ) ??
            '')
        : '';

    // Standard 80mm roll receipt page format
    const pageFormat = PdfPageFormat.roll80;

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Logo
              if (params.logoBytes != null)
                pw.Center(
                  child: pw.Container(
                    width: 48,
                    height: 48,
                    child: pw.Image(
                      pw.MemoryImage(params.logoBytes!),
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
              pw.SizedBox(height: 4),

              // Cafe Title
              pw.Center(
                child: pw.Text(
                  'COOZY THE CAFE',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Shop 24, Marvella business hub, pal adajan',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '+919725002491',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 4),

              // Receipt Meta Rows
              _buildMetaRow('Receipt No:', receiptNo, isBold: true),
              if (createdDateStr.isNotEmpty)
                _buildMetaRow('Date:', createdDateStr),
              _buildMetaRow('Table / Order:', tableName),
              _buildMetaRow('Payment Mode:', inv.paymentMethodName ?? 'Cash'),
              if (inv.customerName != null && inv.customerName!.isNotEmpty)
                _buildMetaRow('Customer:', inv.customerName!),
              if (inv.phoneNumber != null && inv.phoneNumber!.isNotEmpty)
                _buildMetaRow('Phone:', inv.phoneNumber!),

              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 4),

              // Items Header
              pw.Container(
                color: PdfColors.grey200,
                padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Price',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'Qty',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Total',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2),

              // Items List
              if (items.isEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(
                    'No items recorded',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                )
              else
                ...items.map(
                  (item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(
                            item.itemName,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            core.CurrencyFormatter.format(value: item.unitPrice),
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            '${item.quantity}',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            core.CurrencyFormatter.format(value: item.totalPrice),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 2),

              // Subtotal
              _buildAmountRow('Subtotal:', inv.totalCost),

              // Taxes, Discounts, Extra Charges breakdown
              if (inv.paymentMethodDetails != null &&
                  inv.paymentMethodDetails!.isNotEmpty) ...[
                () {
                  try {
                    final detailsMap = jsonDecode(inv.paymentMethodDetails!)
                        as Map<String, dynamic>;
                    final taxList =
                        (detailsMap['taxDetails'] as List<dynamic>?) ?? [];
                    final chargeList =
                        (detailsMap['chargeDetails'] as List<dynamic>?) ?? [];
                    final discountList =
                        (detailsMap['discountDetails'] as List<dynamic>?) ?? [];

                    return pw.Column(
                      children: [
                        ...discountList
                            .where((d) =>
                                ((d['amount'] as num?)?.toDouble() ?? 0.0) > 0)
                            .map((d) {
                          final name = d['name'] ?? 'Discount';
                          final amt =
                              (d['amount'] as num?)?.toDouble() ?? 0.0;
                          return _buildAmountRow('$name:', -amt);
                        }),
                        ...taxList
                            .where((t) =>
                                ((t['amount'] as num?)?.toDouble() ?? 0.0) > 0)
                            .map((t) {
                          final name = t['name'] ?? 'Tax';
                          final amt =
                              (t['amount'] as num?)?.toDouble() ?? 0.0;
                          return _buildAmountRow('$name:', amt);
                        }),
                        ...chargeList
                            .where((c) =>
                                ((c['amount'] as num?)?.toDouble() ?? 0.0) > 0)
                            .map((c) {
                          final name = c['name'] ?? 'Extra Charge';
                          final amt =
                              (c['amount'] as num?)?.toDouble() ?? 0.0;
                          return _buildAmountRow('$name:', amt);
                        }),
                      ],
                    );
                  } catch (_) {
                    return pw.SizedBox.shrink();
                  }
                }(),
              ] else ...[
                if (inv.discountAmount > 0)
                  _buildAmountRow('Discount:', -inv.discountAmount),
                if (inv.taxCost > 0) _buildAmountRow('Tax:', inv.taxCost),
              ],

              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.8, color: PdfColors.black),
              pw.SizedBox(height: 2),

              // Grand Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Grand Total:',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    core.CurrencyFormatter.format(value: inv.netPaymentAmount),
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.SizedBox(height: 2),

              // Cash Breakdown if available
              if (inv.cashReceived != null && inv.cashReceived! > 0) ...[
                _buildAmountRow('Cash Received:', inv.cashReceived!),
                if (inv.changeAmount != null && inv.changeAmount! > 0)
                  _buildAmountRow('Change Returned:', inv.changeAmount!),
                pw.SizedBox(height: 2),
                pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              ],

              pw.SizedBox(height: 8),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for visiting Coozy The Cafe!',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Have a wonderful day!',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildMetaRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountRow(String label, double amount) {
    final isNegative = amount < 0;
    final formattedAmount = isNegative
        ? '-${core.CurrencyFormatter.format(value: amount.abs())}'
        : (amount > 0
            ? '+${core.CurrencyFormatter.format(value: amount)}'
            : core.CurrencyFormatter.format(value: amount));

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
          pw.Text(
            formattedAmount,
            style: pw.TextStyle(
              fontSize: 8,
              color: isNegative ? PdfColors.green800 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Prints the invoice receipt directly via the system printing dialog.
  static Future<void> printPdf({
    required InvoiceDetailsEntity details,
    String? docName,
  }) async {
    final receiptNo = details.invoice.hashId.isNotEmpty
        ? details.invoice.hashId
        : 'MD-${details.invoice.id}';
    final name = docName ?? 'Invoice_$receiptNo.pdf';
    final pdfBytes = await generatePdf(details: details);

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: name,
    );
  }

  /// Downloads or saves the generated invoice PDF to device storage.
  static Future<shared.PdfSaveResult> downloadOrSavePdf({
    required InvoiceDetailsEntity details,
    String? docName,
  }) async {
    final receiptNo = details.invoice.hashId.isNotEmpty
        ? details.invoice.hashId
        : 'MD-${details.invoice.id}';
    final pdfBytes = await generatePdf(details: details);

    return await shared.PdfSaveHelper.saveInvoicePdf(
      bytes: pdfBytes,
      invoiceNumber: receiptNo,
    );
  }

  /// Shares the generated invoice PDF via the system share sheet.
  static Future<void> sharePdf({
    required InvoiceDetailsEntity details,
    Rect? sharePositionOrigin,
  }) async {
    final receiptNo = details.invoice.hashId.isNotEmpty
        ? details.invoice.hashId
        : 'MD-${details.invoice.id}';
    final pdfBytes = await generatePdf(details: details);

    await shared.PdfSaveHelper.shareInvoice(
      bytes: pdfBytes,
      invoiceNumber: receiptNo,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
