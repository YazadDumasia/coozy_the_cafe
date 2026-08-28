import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../entities/table_info.dart';

class _TableQrComputeParams {
  final List<TableInfo> targetTables;
  final TableInfo? singleTable;
  final int columnsCount;
  final pw.Font? ttfFont;
  final pw.Font? ttfBoldFont;
  final Uint8List? logoBytes;

  _TableQrComputeParams({
    required this.targetTables,
    this.singleTable,
    required this.columnsCount,
    this.ttfFont,
    this.ttfBoldFont,
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

    final targetTables = singleTable != null ? [singleTable] : tables;

    final params = _TableQrComputeParams(
      targetTables: targetTables,
      singleTable: singleTable,
      columnsCount: columnsCount,
      ttfFont: ttfFont,
      ttfBoldFont: ttfBoldFont,
      logoBytes: logoBytes,
    );

    // 2. On web, run directly to avoid web worker postMessage serialization hang; on native, use compute!
    if (kIsWeb) {
      return await _generateTableQrPdfInIsolate(params);
    }
    return compute(_generateTableQrPdfInIsolate, params);
  }

  /// Entry point for PDF generation.
  static Future<Uint8List> _generateTableQrPdfInIsolate(_TableQrComputeParams params) async {
    final int cols = params.columnsCount.clamp(2, 4);

    final docTheme = pw.ThemeData.withFont(
      base: params.ttfFont,
      bold: params.ttfBoldFont,
    );

    final pdf = pw.Document(theme: docTheme);
    final logoBytes = params.logoBytes;
    final singleTable = params.singleTable;
    final targetTables = params.targetTables;

    if (singleTable != null) {
      // Single Table - Centered on single A5 Landscape page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5.landscape,
          theme: docTheme,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Center(
              child: _buildTableCard(
                table: singleTable,
                logoBytes: logoBytes,
                cardWidth: 320,
                cardHeight: 135,
                cols: 2,
              ),
            );
          },
        ),
      );
    } else {
      // Determine dimensions and count per page based on columns count
      int rowsPerPage;
      double cardWidth;
      double cardHeight;

      if (cols == 2) {
        rowsPerPage = 3;
        cardWidth = 260;
        cardHeight = 120;
      } else if (cols == 4) {
        rowsPerPage = 5;
        cardWidth = 130;
        cardHeight = 90;
      } else {
        // 3 Columns
        rowsPerPage = 4;
        cardWidth = 175;
        cardHeight = 105;
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

    for (final pageTables in pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: docTheme,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            final List<List<TableInfo>> rows = [];
            for (var j = 0; j < pageTables.length; j += cols) {
              rows.add(
                pageTables.sublist(
                  j,
                  j + cols > pageTables.length ? pageTables.length : j + cols,
                ),
              );
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Coozy The Cafe - Dining Table QR Cards ($cols Columns)',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.brown900,
                        ),
                      ),
                      pw.Text(
                        'Total Tables: ${targetTables.length}',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                  pw.SizedBox(height: 10),
                  pw.Column(
                    children: rows.map((rowTables) {
                      final List<pw.Widget> rowWidgets = [];
                      for (int c = 0; c < cols; c++) {
                        if (c < rowTables.length) {
                          rowWidgets.add(
                            _buildTableCard(
                              table: rowTables[c],
                              logoBytes: logoBytes,
                              cardWidth: cardWidth,
                              cardHeight: cardHeight,
                              cols: cols,
                            ),
                          );
                        } else {
                          rowWidgets.add(
                            pw.SizedBox(width: cardWidth, height: cardHeight),
                          );
                        }
                      }

                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 10),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: rowWidgets,
                        ),
                      );
                    }).toList(),
                  ),
                  pw.Spacer(),
                  pw.Footer(
                    trailing: pw.Text(
                      'Page ${context.pageNumber} of ${context.pagesCount}',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }
    }

    return await pdf.save();
  }

  /// Builds a single horizontal QR card matching Burger King / King's Table format.
  static pw.Widget _buildTableCard({
    required TableInfo table,
    Uint8List? logoBytes,
    required double cardWidth,
    required double cardHeight,
    int cols = 2,
  }) {
    final String tableNumDisplay =
        table.tableNo?.isNotEmpty == true
            ? table.tableNo!
            : (table.id != null ? '${table.id}' : '1');

    final String qrPayload = 'coozy_table:${table.id ?? tableNumDisplay}';

    final double logoHeight = cols == 4 ? 20 : (cols == 3 ? 24 : 28);
    final double tableNumFontSize = cols == 4 ? 16 : (cols == 3 ? 20 : 24);
    final double qrSize = cols == 4 ? 42 : (cols == 3 ? 48 : 56);
    final double scanTextFontSize = cols == 4 ? 6.5 : (cols == 3 ? 7.5 : 8);

    return pw.Container(
      width: cardWidth,
      height: cardHeight,
      padding: pw.EdgeInsets.all(cols == 4 ? 6 : 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey400, width: 1.1),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Left Section: Logo & Table Info
          pw.Expanded(
            flex: 12,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoBytes != null)
                  pw.Container(
                    height: logoHeight,
                    child: pw.Image(
                      pw.MemoryImage(logoBytes),
                      fit: pw.BoxFit.contain,
                    ),
                  )
                else
                  pw.Text(
                    'Coozy The Cafe',
                    style: pw.TextStyle(
                      fontSize: cols == 4 ? 9 : 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.brown800,
                    ),
                  ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Table No.',
                  style: pw.TextStyle(
                    fontSize: cols == 4 ? 7.5 : 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey800,
                  ),
                ),
                pw.Text(
                  tableNumDisplay,
                  style: pw.TextStyle(
                    fontSize: tableNumFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                if (table.tableLabel != null && table.tableLabel!.isNotEmpty)
                  pw.Text(
                    table.tableLabel!,
                    style: const pw.TextStyle(
                      fontSize: 6.5,
                      color: PdfColors.grey700,
                    ),
                    maxLines: 1,
                  ),
              ],
            ),
          ),

          // Center: Vertical Line Separator
          pw.Container(
            width: 1.2,
            height: cardHeight * 0.78,
            color: PdfColors.grey700,
            margin: const pw.EdgeInsets.symmetric(horizontal: 4),
          ),

          // Right Section: QR Code & Call to Action
          pw.Expanded(
            flex: 13,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 0.7),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(3),
                    ),
                  ),
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrPayload,
                    drawText: false,
                    width: qrSize,
                    height: qrSize,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Scan QR code to\nplace order',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: scanTextFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: docName,
    );
  }

  /// Downloads or saves the generated PDF file directly across Mobile & Web.
  static Future<void> downloadOrSavePdf({
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
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: docName,
    );
  }
}
