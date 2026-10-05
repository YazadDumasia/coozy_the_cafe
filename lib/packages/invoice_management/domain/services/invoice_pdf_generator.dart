import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../entities/invoice_management_entity.dart';

class _InvoicePdfComputeParams {
  final InvoiceEntity invoice;
  final List<InvoiceItemEntity> items;
  final String? tableName;
  final Uint8List? fontBytes;
  final Uint8List? boldFontBytes;
  final Uint8List? logoBytes;

  _InvoicePdfComputeParams({
    required this.invoice,
    required this.items,
    this.tableName,
    this.fontBytes,
    this.boldFontBytes,
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
    Uint8List? fontBytes;
    Uint8List? boldFontBytes;
    try {
      final fontByteData = await rootBundle.load(
        'assets/font/BwAletaNo10/BwAletaNo10_Regular.ttf',
      );
      fontBytes = fontByteData.buffer.asUint8List();
      final boldFontByteData = await rootBundle.load(
        'assets/font/BwAletaNo10/BwAletaNo10_Bold.ttf',
      );
      boldFontBytes = boldFontByteData.buffer.asUint8List();
    } catch (_) {
      fontBytes = null;
      boldFontBytes = null;
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
      fontBytes: fontBytes,
      boldFontBytes: boldFontBytes,
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
    final inv = params.invoice;
    final items = params.items;
    final tableName = (params.tableName != null && params.tableName!.isNotEmpty)
        ? params.tableName!
        : (inv.orderId != null ? 'Table ${inv.orderId}' : 'Dine-In');

    final String receiptNo = inv.hashId.isNotEmpty
        ? inv.hashId
        : 'MD-${inv.id}';

    final String createdDateStr = inv.createdDate != null
        ? (core.DateUtil.localFormat(
                inv.createdDate,
                'dd MMM yyyy - hh:mm a',
              ) ??
              '')
        : '';

    // Calculate approximate receipt height
    // Base height for logo, header, meta, breakdown, and footer: ~260 pt
    // Items: ~16 pt per item
    // Taxes/discounts/charges: ~14 pt per item
    int breakdownRowsCount = 3;
    if (inv.paymentMethodDetails != null &&
        inv.paymentMethodDetails!.isNotEmpty) {
      try {
        final detailsMap =
            jsonDecode(inv.paymentMethodDetails!) as Map<String, dynamic>;
        final taxList = (detailsMap['taxDetails'] as List<dynamic>?) ?? [];
        final chargeList =
            (detailsMap['chargeDetails'] as List<dynamic>?) ?? [];
        final discountList =
            (detailsMap['discountDetails'] as List<dynamic>?) ?? [];
        breakdownRowsCount +=
            taxList.length + chargeList.length + discountList.length;
      } catch (_) {}
    }
    if (inv.cashReceived != null && inv.cashReceived! > 0) {
      breakdownRowsCount += 2;
    }

    final double calculatedHeight =
        (280 + (items.length * 16) + (breakdownRowsCount * 14))
            .toDouble()
            .clamp(450.0, 3000.0);

    // 80mm roll receipt: 80mm = ~226.77 points
    final document = PdfDocument();
    document.pageSettings.size = Size(226.77, calculatedHeight);
    document.pageSettings.margins.all = 10;

    final page = document.pages.add();
    final graphics = page.graphics;
    final clientSize = page.getClientSize();

    PdfFont regularFont(double size) => params.fontBytes != null
        ? PdfTrueTypeFont(params.fontBytes!, size)
        : PdfStandardFont(PdfFontFamily.helvetica, size);

    PdfFont boldFont(double size) => params.boldFontBytes != null
        ? PdfTrueTypeFont(params.boldFontBytes!, size)
        : (params.fontBytes != null
              ? PdfTrueTypeFont(params.fontBytes!, size)
              : PdfStandardFont(
                  PdfFontFamily.helvetica,
                  size,
                  style: PdfFontStyle.bold,
                ));

    final greyPen = PdfPen(PdfColor(200, 200, 200), width: 0.6);
    final darkPen = PdfPen(PdfColor(33, 33, 33), width: 0.8);
    final greyBrush = PdfSolidBrush(PdfColor(117, 117, 117));

    double currentY = 0;

    // 1. Logo
    if (params.logoBytes != null) {
      try {
        final logoBitmap = PdfBitmap(params.logoBytes!);
        const double logoH = 40;
        final double logoW =
            logoH * (logoBitmap.width / logoBitmap.height.clamp(1, 9999));
        final double logoX = (clientSize.width - logoW) / 2;
        graphics.drawImage(
          logoBitmap,
          Rect.fromLTWH(logoX, currentY, logoW, logoH),
        );
        currentY += logoH + 4;
      } catch (_) {}
    }

    // 2. Cafe Title & Header
    graphics.drawString(
      'COOZY THE CAFE',
      boldFont(12),
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(0, currentY, clientSize.width, 16),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentY += 16;

    graphics.drawString(
      'Shop 24, Marvella business hub, pal adajan',
      regularFont(7.5),
      brush: greyBrush,
      bounds: Rect.fromLTWH(0, currentY, clientSize.width, 12),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentY += 12;

    graphics.drawString(
      '+919725002491',
      regularFont(7.5),
      brush: greyBrush,
      bounds: Rect.fromLTWH(0, currentY, clientSize.width, 12),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentY += 14;

    // Divider
    graphics.drawLine(
      greyPen,
      Offset(0, currentY),
      Offset(clientSize.width, currentY),
    );
    currentY += 4;

    // 3. Receipt Meta Info
    void drawMeta(String label, String value, {bool isBold = false}) {
      graphics.drawString(
        label,
        regularFont(7.5),
        brush: greyBrush,
        bounds: Rect.fromLTWH(0, currentY, 80, 12),
      );
      graphics.drawString(
        value,
        isBold ? boldFont(7.5) : regularFont(7.5),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(80, currentY, clientSize.width - 80, 12),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      currentY += 12;
    }

    drawMeta('Receipt No:', receiptNo, isBold: true);
    if (createdDateStr.isNotEmpty) drawMeta('Date:', createdDateStr);
    drawMeta('Table / Order:', tableName);
    drawMeta('Payment Mode:', inv.paymentMethodName ?? 'Cash');
    if (inv.customerName != null && inv.customerName!.isNotEmpty) {
      drawMeta('Customer:', inv.customerName!);
    }
    if (inv.phoneNumber != null && inv.phoneNumber!.isNotEmpty) {
      drawMeta('Phone:', inv.phoneNumber!);
    }

    currentY += 4;
    graphics.drawLine(
      greyPen,
      Offset(0, currentY),
      Offset(clientSize.width, currentY),
    );
    currentY += 4;

    // 4. Items Table Header
    final headerBgRect = Rect.fromLTWH(0, currentY, clientSize.width, 14);
    graphics.drawRectangle(
      brush: PdfSolidBrush(PdfColor(238, 238, 238)),
      bounds: headerBgRect,
    );
    final thFont = boldFont(7.5);

    graphics.drawString(
      'Item',
      thFont,
      bounds: Rect.fromLTWH(2, currentY + 1, 95, 12),
    );
    graphics.drawString(
      'Price',
      thFont,
      bounds: Rect.fromLTWH(97, currentY + 1, 45, 12),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    graphics.drawString(
      'Qty',
      thFont,
      bounds: Rect.fromLTWH(142, currentY + 1, 20, 12),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    graphics.drawString(
      'Total',
      thFont,
      bounds: Rect.fromLTWH(162, currentY + 1, clientSize.width - 164, 12),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    currentY += 16;

    // 5. Items List
    final itemFont = regularFont(7.5);
    if (items.isEmpty) {
      graphics.drawString(
        'No items recorded',
        itemFont,
        brush: greyBrush,
        bounds: Rect.fromLTWH(2, currentY, clientSize.width, 12),
      );
      currentY += 14;
    } else {
      for (final item in items) {
        final priceStr = core.CurrencyFormatter.format(value: item.unitPrice);
        final totalStr = core.CurrencyFormatter.format(value: item.totalPrice);

        graphics.drawString(
          item.itemName,
          itemFont,
          bounds: Rect.fromLTWH(2, currentY, 95, 12),
          format: PdfStringFormat(wordWrap: PdfWordWrapType.word),
        );
        graphics.drawString(
          priceStr,
          itemFont,
          bounds: Rect.fromLTWH(97, currentY, 45, 12),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
        );
        graphics.drawString(
          '${item.quantity}',
          itemFont,
          bounds: Rect.fromLTWH(142, currentY, 20, 12),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
        );
        graphics.drawString(
          totalStr,
          itemFont,
          bounds: Rect.fromLTWH(162, currentY, clientSize.width - 164, 12),
          format: PdfStringFormat(alignment: PdfTextAlignment.right),
        );
        currentY += 14;
      }
    }

    currentY += 2;
    graphics.drawLine(
      greyPen,
      Offset(0, currentY),
      Offset(clientSize.width, currentY),
    );
    currentY += 4;

    // 6. Subtotal & Breakdown Rows
    void drawAmountRow(String label, double amount, {bool showSign = false}) {
      final isNegative = amount < 0;
      final String formattedAmount;
      if (!showSign) {
        formattedAmount = core.CurrencyFormatter.format(value: amount.abs());
      } else {
        formattedAmount = isNegative
            ? '-${core.CurrencyFormatter.format(value: amount.abs())}'
            : (amount > 0
                  ? '+${core.CurrencyFormatter.format(value: amount)}'
                  : core.CurrencyFormatter.format(value: amount));
      }

      graphics.drawString(
        label,
        regularFont(7.5),
        brush: greyBrush,
        bounds: Rect.fromLTWH(0, currentY, 100, 12),
      );
      graphics.drawString(
        formattedAmount,
        regularFont(7.5),
        brush: isNegative
            ? PdfSolidBrush(PdfColor(46, 125, 50))
            : PdfBrushes.black,
        bounds: Rect.fromLTWH(100, currentY, clientSize.width - 100, 12),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      currentY += 12;
    }

    drawAmountRow('Subtotal:', inv.totalCost);

    if (inv.paymentMethodDetails != null &&
        inv.paymentMethodDetails!.isNotEmpty) {
      try {
        final detailsMap =
            jsonDecode(inv.paymentMethodDetails!) as Map<String, dynamic>;
        final taxList = (detailsMap['taxDetails'] as List<dynamic>?) ?? [];
        final chargeList =
            (detailsMap['chargeDetails'] as List<dynamic>?) ?? [];
        final discountList =
            (detailsMap['discountDetails'] as List<dynamic>?) ?? [];

        for (final d in discountList) {
          final amt = (d['amount'] as num?)?.toDouble() ?? 0.0;
          if (amt > 0) {
            drawAmountRow('${d['name'] ?? 'Discount'}:', -amt, showSign: true);
          }
        }
        for (final t in taxList) {
          final amt = (t['amount'] as num?)?.toDouble() ?? 0.0;
          if (amt > 0) {
            drawAmountRow('${t['name'] ?? 'Tax'}:', amt, showSign: true);
          }
        }
        for (final c in chargeList) {
          final amt = (c['amount'] as num?)?.toDouble() ?? 0.0;
          if (amt > 0) {
            drawAmountRow(
              '${c['name'] ?? 'Extra Charge'}:',
              amt,
              showSign: true,
            );
          }
        }
      } catch (_) {}
    } else {
      if (inv.discountAmount > 0) {
        drawAmountRow('Discount:', -inv.discountAmount, showSign: true);
      }
      if (inv.taxCost > 0) drawAmountRow('Tax:', inv.taxCost, showSign: true);
    }

    currentY += 2;
    graphics.drawLine(
      darkPen,
      Offset(0, currentY),
      Offset(clientSize.width, currentY),
    );
    currentY += 4;

    // 7. Grand Total
    final gtFont = boldFont(10.5);
    final gtStr = core.CurrencyFormatter.format(value: inv.netPaymentAmount);
    graphics.drawString(
      'Grand Total:',
      gtFont,
      bounds: Rect.fromLTWH(0, currentY, 90, 16),
    );
    graphics.drawString(
      gtStr,
      gtFont,
      bounds: Rect.fromLTWH(90, currentY, clientSize.width - 90, 16),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    currentY += 18;

    graphics.drawLine(
      greyPen,
      Offset(0, currentY),
      Offset(clientSize.width, currentY),
    );
    currentY += 4;

    // Cash Breakdown if available
    if (inv.cashReceived != null && inv.cashReceived! > 0) {
      drawAmountRow('Cash Received:', inv.cashReceived!);
      if (inv.changeAmount != null && inv.changeAmount! > 0) {
        drawAmountRow('Change Returned:', inv.changeAmount!);
      }
      currentY += 2;
      graphics.drawLine(
        greyPen,
        Offset(0, currentY),
        Offset(clientSize.width, currentY),
      );
      currentY += 4;
    }

    // 8. Footer Message
    currentY += 8;
    graphics.drawString(
      'Thank you for visiting Coozy The Cafe!',
      boldFont(7.5),
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(0, currentY, clientSize.width, 12),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    currentY += 12;

    graphics.drawString(
      'Have a wonderful day!',
      regularFont(7.0),
      brush: greyBrush,
      bounds: Rect.fromLTWH(0, currentY, clientSize.width, 12),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    final bytes = Uint8List.fromList(document.saveSync());
    document.dispose();
    return bytes;
  }

  /// Prints the invoice receipt directly via the system printing dialog.
  static Future<void> printPdf({
    required InvoiceDetailsEntity details,
    String? docName,
    Uint8List? bytes,
  }) async {
    final receiptNo = details.invoice.hashId.isNotEmpty
        ? details.invoice.hashId
        : 'MD-${details.invoice.id}';
    final name = docName ?? 'Invoice_$receiptNo.pdf';
    final pdfBytes = bytes ?? await generatePdf(details: details);

    await Printing.layoutPdf(onLayout: (_) async => pdfBytes, name: name);
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
    String? filePath,
    Uint8List? bytes,
    Rect? sharePositionOrigin,
  }) async {
    final receiptNo = details.invoice.hashId.isNotEmpty
        ? details.invoice.hashId
        : 'MD-${details.invoice.id}';
    final pdfBytes =
        bytes ??
        (filePath == null ? await generatePdf(details: details) : null);

    await shared.PdfSaveHelper.shareInvoice(
      bytes: pdfBytes,
      invoiceNumber: receiptNo,
      filePath: filePath,
      sharePositionOrigin: sharePositionOrigin,
    );
  }
}
