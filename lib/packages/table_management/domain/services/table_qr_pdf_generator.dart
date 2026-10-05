import 'package:barcode/barcode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../entities/table_info.dart';

class _TableQrComputeParams {
  final List<TableInfo> targetTables;
  final TableInfo? singleTable;
  final int columnsCount;
  final Uint8List? fontBytes;
  final Uint8List? boldFontBytes;
  final Uint8List? logoBytes;

  _TableQrComputeParams({
    required this.targetTables,
    this.singleTable,
    required this.columnsCount,
    this.fontBytes,
    this.boldFontBytes,
    this.logoBytes,
  });
}

class TableQrPdfGenerator {
  static const String logoAssetPath = 'assets/images/app_logo_clear_bg.png';

  /// Generates printable PDF document containing QR cards for the provided list of tables.
  static Future<Uint8List> generatePdf({
    required List<TableInfo> tables,
    TableInfo? singleTable,
    int columnsCount = 2,
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

    final targetTables = singleTable != null ? [singleTable] : tables;

    final params = _TableQrComputeParams(
      targetTables: targetTables,
      singleTable: singleTable,
      columnsCount: columnsCount,
      fontBytes: fontBytes,
      boldFontBytes: boldFontBytes,
      logoBytes: logoBytes,
    );

    // 2. On web, run directly to avoid web worker postMessage serialization hang; on native, use compute!
    if (kIsWeb) {
      return await _generateTableQrPdfInIsolate(params);
    }
    return compute(_generateTableQrPdfInIsolate, params);
  }

  /// Entry point for PDF generation using Syncfusion PDF document.
  static Future<Uint8List> _generateTableQrPdfInIsolate(
    _TableQrComputeParams params,
  ) async {
    final int cols = params.columnsCount.clamp(2, 4);

    final document = PdfDocument();
    document.pageSettings.margins.all = 20;

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

    final logoBytes = params.logoBytes;
    PdfBitmap? logoBitmap;
    if (logoBytes != null) {
      try {
        logoBitmap = PdfBitmap(logoBytes);
      } catch (_) {
        logoBitmap = null;
      }
    }

    final singleTable = params.singleTable;
    final targetTables = params.targetTables;

    if (singleTable != null) {
      // Single Table - Centered on single A5 Landscape page
      document.pageSettings.size = PdfPageSize.a5;
      document.pageSettings.orientation = PdfPageOrientation.landscape;
      final page = document.pages.add();
      final clientSize = page.getClientSize();

      const double cardWidth = 320;
      const double cardHeight = 145;
      final double x = (clientSize.width - cardWidth) / 2;
      final double y = (clientSize.height - cardHeight) / 2;

      _drawTableCard(
        graphics: page.graphics,
        table: singleTable,
        logoBitmap: logoBitmap,
        bounds: Rect.fromLTWH(x, y, cardWidth, cardHeight),
        cols: 2,
        regularFont: regularFont,
        boldFont: boldFont,
      );
    } else {
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.orientation = PdfPageOrientation.portrait;

      int rowsPerPage;
      double cardWidth;
      double cardHeight;
      const double colSpacing = 10.0;
      const double rowSpacing = 10.0;

      if (cols == 2) {
        rowsPerPage = 4;
        cardWidth = 265;
        cardHeight = 125;
      } else if (cols == 4) {
        rowsPerPage = 6;
        cardWidth = 130;
        cardHeight = 92;
      } else {
        // 3 Columns
        rowsPerPage = 5;
        cardWidth = 176;
        cardHeight = 108;
      }

      final int cardsPerPage = cols * rowsPerPage;
      final List<List<TableInfo>> pages = [];
      for (var i = 0; i < targetTables.length; i += cardsPerPage) {
        pages.add(
          targetTables.sublist(
            i,
            i + cardsPerPage > targetTables.length
                ? targetTables.length
                : i + cardsPerPage,
          ),
        );
      }

      final headerTitleFont = boldFont(12);
      final headerCountFont = regularFont(9);
      final footerFont = regularFont(8);
      final brownBrush = PdfSolidBrush(PdfColor(78, 52, 46));
      final greyBrush = PdfSolidBrush(PdfColor(117, 117, 117));
      final headerBorderPen = PdfPen(PdfColor(220, 220, 220), width: 0.8);

      for (int pageIdx = 0; pageIdx < pages.length; pageIdx++) {
        final pageTables = pages[pageIdx];
        final page = document.pages.add();
        final graphics = page.graphics;
        final clientSize = page.getClientSize();

        // Header
        const double headerHeight = 22;
        graphics.drawString(
          'Coozy The Cafe - Dining Table QR Cards ($cols Columns)',
          headerTitleFont,
          brush: brownBrush,
          bounds: Rect.fromLTWH(0, 0, clientSize.width - 120, headerHeight),
          format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
        );
        graphics.drawString(
          'Total Tables: ${targetTables.length}',
          headerCountFont,
          brush: greyBrush,
          bounds: Rect.fromLTWH(clientSize.width - 120, 0, 120, headerHeight),
          format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.middle,
          ),
        );
        graphics.drawLine(
          headerBorderPen,
          const Offset(0, headerHeight + 2),
          Offset(clientSize.width, headerHeight + 2),
        );

        // Grid cards
        const double contentStartY = headerHeight + 10;
        final totalRowWidth = (cols * cardWidth) + ((cols - 1) * colSpacing);
        final double startX = (clientSize.width - totalRowWidth) / 2 > 0
            ? (clientSize.width - totalRowWidth) / 2
            : 0.0;

        for (int itemIdx = 0; itemIdx < pageTables.length; itemIdx++) {
          final row = itemIdx ~/ cols;
          final col = itemIdx % cols;
          final table = pageTables[itemIdx];

          final double x = startX + (col * (cardWidth + colSpacing));
          final double y = contentStartY + (row * (cardHeight + rowSpacing));

          _drawTableCard(
            graphics: graphics,
            table: table,
            logoBitmap: logoBitmap,
            bounds: Rect.fromLTWH(x, y, cardWidth, cardHeight),
            cols: cols,
            regularFont: regularFont,
            boldFont: boldFont,
          );
        }

        // Footer
        final pageNumberText = 'Page ${pageIdx + 1} of ${pages.length}';
        graphics.drawString(
          pageNumberText,
          footerFont,
          brush: greyBrush,
          bounds: Rect.fromLTWH(
            0,
            clientSize.height - 14,
            clientSize.width,
            14,
          ),
          format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.bottom,
          ),
        );
      }
    }

    final bytes = Uint8List.fromList(document.saveSync());
    document.dispose();
    return bytes;
  }

  /// Draws a single horizontal QR card onto [graphics].
  static void _drawTableCard({
    required PdfGraphics graphics,
    required TableInfo table,
    required PdfBitmap? logoBitmap,
    required Rect bounds,
    required int cols,
    required PdfFont Function(double size) regularFont,
    required PdfFont Function(double size) boldFont,
  }) {
    final String tableNumDisplay = table.tableNo?.isNotEmpty == true
        ? table.tableNo!
        : (table.id != null ? '${table.id}' : '1');

    final String qrPayload = 'coozy_table:${table.id ?? tableNumDisplay}';

    final double padding = cols == 4 ? 6 : 10;
    final innerBounds = Rect.fromLTWH(
      bounds.left + padding,
      bounds.top + padding,
      bounds.width - (padding * 2),
      bounds.height - (padding * 2),
    );

    // 1. Card container and border with corner radius 10 and primary color 0xffa43c12
    final cardBorderPen = PdfPen(PdfColor(0xa4, 0x3c, 0x12), width: 1.0);
    _drawRoundedRectangle(
      graphics: graphics,
      bounds: bounds,
      radius: 10.0,
      brush: PdfBrushes.white,
      pen: cardBorderPen,
    );

    // 2. Layout split: Left (Table Info) and Right (QR code)
    final double leftWidth = innerBounds.width * 0.52;
    final double rightWidth = innerBounds.width * 0.44;
    final double separatorX = innerBounds.left + leftWidth + 4;

    // Divider Line
    final divPen = PdfPen(PdfColor(220, 220, 220), width: 0.8);
    graphics.drawLine(
      divPen,
      Offset(separatorX, innerBounds.top + 4),
      Offset(separatorX, innerBounds.bottom - 4),
    );

    // Left Section
    final double logoHeight = cols == 4 ? 16 : (cols == 3 ? 20 : 24);
    if (logoBitmap != null) {
      final double logoWidth =
          logoHeight * (logoBitmap.width / logoBitmap.height.clamp(1, 9999));
      graphics.drawImage(
        logoBitmap,
        Rect.fromLTWH(innerBounds.left, innerBounds.top, logoWidth, logoHeight),
      );
    } else {
      final brandFont = boldFont(cols == 4 ? 8 : 10);
      graphics.drawString(
        'Coozy The Cafe',
        brandFont,
        brush: PdfSolidBrush(PdfColor(109, 76, 65)),
        bounds: Rect.fromLTWH(
          innerBounds.left,
          innerBounds.top,
          leftWidth,
          logoHeight,
        ),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
      );
    }

    final double labelY = innerBounds.top + logoHeight + 4;
    final tableLabelFont = boldFont(cols == 4 ? 7.0 : 8.5);
    graphics.drawString(
      'Table No.',
      tableLabelFont,
      brush: PdfSolidBrush(PdfColor(66, 66, 66)),
      bounds: Rect.fromLTWH(innerBounds.left, labelY, leftWidth, 12),
    );

    final double numY = labelY + 12;
    final tableNumFont = boldFont(cols == 4 ? 16 : (cols == 3 ? 20 : 24));
    graphics.drawString(
      tableNumDisplay,
      tableNumFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(innerBounds.left, numY, leftWidth, 26),
    );

    if (table.tableLabel != null && table.tableLabel!.isNotEmpty) {
      final descFont = regularFont(cols == 4 ? 5.5 : 6.5);
      graphics.drawString(
        table.tableLabel!,
        descFont,
        brush: PdfSolidBrush(PdfColor(117, 117, 117)),
        bounds: Rect.fromLTWH(innerBounds.left, numY + 26, leftWidth, 12),
        format: PdfStringFormat(wordWrap: PdfWordWrapType.word),
      );
    }

    // Right Section: QR Code & Call to Action (Vertically and Horizontally Centered)
    final double rightLeft = separatorX + 6;
    final double qrSize = cols == 4 ? 38 : (cols == 3 ? 46 : 54);
    final double scanTextFontSize = cols == 4 ? 5.5 : (cols == 3 ? 6.5 : 7.5);
    final scanFont = boldFont(scanTextFontSize);
    const double qrToScanSpacing = 3.0;
    final double scanTextHeight = scanTextFontSize * 2.4; // 2 lines of text
    final double totalRightContentHeight =
        qrSize + qrToScanSpacing + scanTextHeight;

    // Center vertically within innerBounds
    final double rightStartY =
        innerBounds.top +
        ((innerBounds.height - totalRightContentHeight) / 2).clamp(
          2.0,
          innerBounds.height,
        );
    final double qrX = rightLeft + ((rightWidth - qrSize) / 2);
    final double qrY = rightStartY;

    _drawQrCode(
      graphics: graphics,
      payload: qrPayload,
      bounds: Rect.fromLTWH(qrX, qrY, qrSize, qrSize),
    );

    // Call to action text below QR
    final scanY = qrY + qrSize + qrToScanSpacing;
    graphics.drawString(
      'Scan QR code to\nplace order',
      scanFont,
      brush: PdfSolidBrush(PdfColor(33, 33, 33)),
      bounds: Rect.fromLTWH(
        rightLeft,
        scanY,
        rightWidth,
        (innerBounds.bottom - scanY).clamp(scanTextHeight, innerBounds.height),
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.top,
      ),
    );
  }

  /// Draws vector QR code modules onto [graphics].
  static void _drawQrCode({
    required PdfGraphics graphics,
    required String payload,
    required Rect bounds,
  }) {
    try {
      final qr = Barcode.qrCode();
      final elements = qr.make(
        payload,
        width: bounds.width,
        height: bounds.height,
      );

      final brush = PdfBrushes.black;
      for (final elem in elements) {
        if (elem is BarcodeBar && elem.black) {
          graphics.drawRectangle(
            brush: brush,
            bounds: Rect.fromLTWH(
              bounds.left + elem.left,
              bounds.top + elem.top,
              elem.width,
              elem.height,
            ),
          );
        }
      }
    } catch (_) {
      // Fallback border
      final pen = PdfPen(PdfColor(150, 150, 150));
      graphics.drawRectangle(pen: pen, bounds: bounds);
    }
  }

  /// Draws a rectangle with rounded corners using [PdfPath].
  static void _drawRoundedRectangle({
    required PdfGraphics graphics,
    required Rect bounds,
    required double radius,
    PdfBrush? brush,
    PdfPen? pen,
  }) {
    final double r = radius.clamp(
      0.0,
      (bounds.width < bounds.height ? bounds.width : bounds.height) / 2,
    );
    final double d = r * 2;
    final path = PdfPath();

    // Top-left arc
    path.addArc(Rect.fromLTWH(bounds.left, bounds.top, d, d), 180, 90);
    // Top line
    path.addLine(
      Offset(bounds.left + r, bounds.top),
      Offset(bounds.right - r, bounds.top),
    );
    // Top-right arc
    path.addArc(Rect.fromLTWH(bounds.right - d, bounds.top, d, d), 270, 90);
    // Right line
    path.addLine(
      Offset(bounds.right, bounds.top + r),
      Offset(bounds.right, bounds.bottom - r),
    );
    // Bottom-right arc
    path.addArc(
      Rect.fromLTWH(bounds.right - d, bounds.bottom - d, d, d),
      0,
      90,
    );
    // Bottom line
    path.addLine(
      Offset(bounds.right - r, bounds.bottom),
      Offset(bounds.left + r, bounds.bottom),
    );
    // Bottom-left arc
    path.addArc(Rect.fromLTWH(bounds.left, bounds.bottom - d, d, d), 90, 90);
    // Left line & close
    path.addLine(
      Offset(bounds.left, bounds.bottom - r),
      Offset(bounds.left, bounds.top + r),
    );
    path.closeFigure();

    graphics.drawPath(path, pen: pen, brush: brush);
  }

  /// Displays the interactive print/preview screen using `printing`.
  static Future<void> printOrShareTableCards({
    required List<TableInfo> tables,
    TableInfo? singleTable,
    int columnsCount = 2,
    required String docName,
  }) async {
    final pdfBytes = await generatePdf(
      tables: tables,
      singleTable: singleTable,
      columnsCount: columnsCount,
    );
    await Printing.layoutPdf(onLayout: (_) async => pdfBytes, name: docName);
  }

  /// Downloads or saves the generated PDF file directly to device storage across Mobile, Desktop & Web.
  static Future<shared.PdfSaveResult> downloadOrSavePdf({
    required List<TableInfo> tables,
    TableInfo? singleTable,
    int columnsCount = 2,
    required String docName,
  }) async {
    final pdfBytes = await generatePdf(
      tables: tables,
      singleTable: singleTable,
      columnsCount: columnsCount,
    );
    return await shared.PdfSaveHelper.saveAndDownloadPdf(
      bytes: pdfBytes,
      filename: docName,
    );
  }

  /// Shares the generated PDF file via the system share sheet.
  static Future<void> sharePdf({
    required List<TableInfo> tables,
    TableInfo? singleTable,
    int columnsCount = 2,
    required String docName,
    Rect? sharePositionOrigin,
  }) async {
    final pdfBytes = await generatePdf(
      tables: tables,
      singleTable: singleTable,
      columnsCount: columnsCount,
    );
    final result = await shared.PdfSaveHelper.saveAndDownloadPdf(
      bytes: pdfBytes,
      filename: docName,
    );
    await shared.PdfSaveHelper.sharePdfFile(
      filePath: result.filePath ?? docName,
      filename: docName,
      fallbackBytes: pdfBytes,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Checks and requests storage permission on mobile platforms (Android).
  static Future<bool> requestStoragePermission() async {
    return await shared.PdfSaveHelper.requestStoragePermission();
  }

  /// Alias for [requestStoragePermission].
  static Future<bool> checkPdfStoragePermission() async {
    return await shared.PdfSaveHelper.checkPdfStoragePermission();
  }
}
