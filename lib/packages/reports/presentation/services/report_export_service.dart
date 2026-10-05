import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class ReportExportRowData {
  const ReportExportRowData({
    required this.headers,
    required this.rows,
    required this.reportTitle,
    this.dateRangeStr,
  });

  final String reportTitle;
  final String? dateRangeStr;
  final List<String> headers;
  final List<List<dynamic>> rows;
}

class ReportExportService {
  /// Export tabular data to CSV bytes and save to system.
  static Future<shared.PdfSaveResult> exportToCsv(
    ReportExportRowData data, {
    required String baseFilename,
  }) async {
    try {
      final List<List<dynamic>> csvContent = [
        [data.reportTitle],
        if (data.dateRangeStr != null) ['Date Range: ${data.dateRangeStr}'],
        [],
        data.headers,
        ...data.rows,
      ];

      final csvString = csv.encode(csvContent);
      final bytes = Uint8List.fromList(csvString.codeUnits);
      final filename = '$baseFilename.csv';

      return await shared.PdfSaveHelper.saveAndDownloadPdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      return shared.PdfSaveResult.failure(e.toString());
    }
  }

  /// Export tabular data to Excel (.xlsx) using syncfusion_flutter_xlsio.
  static Future<shared.PdfSaveResult> exportToExcel(
    ReportExportRowData data, {
    required String baseFilename,
  }) async {
    try {
      final workbook = xls.Workbook();
      final sheet = workbook.worksheets[0];
      sheet.name = data.reportTitle.length > 31
          ? data.reportTitle.substring(0, 31)
          : data.reportTitle;

      int currentRow = 1;

      // Title
      sheet.getRangeByIndex(currentRow, 1).setText(data.reportTitle);
      sheet.getRangeByIndex(currentRow, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(currentRow, 1).cellStyle.fontSize = 14;
      currentRow++;

      if (data.dateRangeStr != null) {
        sheet
            .getRangeByIndex(currentRow, 1)
            .setText('Date Range: ${data.dateRangeStr}');
        sheet.getRangeByIndex(currentRow, 1).cellStyle.italic = true;
        currentRow++;
      }
      currentRow++; // blank line

      // Headers
      for (int c = 0; c < data.headers.length; c++) {
        final cell = sheet.getRangeByIndex(currentRow, c + 1);
        cell.setText(data.headers[c]);
        cell.cellStyle.bold = true;
        cell.cellStyle.backColor = '#EEEEEE';
      }
      currentRow++;

      // Data Rows
      for (final row in data.rows) {
        for (int c = 0; c < row.length; c++) {
          final cell = sheet.getRangeByIndex(currentRow, c + 1);
          final val = row[c];
          if (val is num) {
            cell.setNumber(val.toDouble());
          } else {
            cell.setText(val?.toString() ?? '');
          }
        }
        currentRow++;
      }

      // Auto-fit columns
      for (int c = 0; c < data.headers.length; c++) {
        sheet.autoFitColumn(c + 1);
      }

      final List<int> bytesList = workbook.saveAsStream();
      workbook.dispose();

      final bytes = Uint8List.fromList(bytesList);
      final filename = '$baseFilename.xlsx';

      return await shared.PdfSaveHelper.saveAndDownloadPdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      return shared.PdfSaveResult.failure(e.toString());
    }
  }

  /// Export tabular data to PDF document using Syncfusion Flutter PDF.
  static Future<shared.PdfSaveResult> exportToPdf(
    ReportExportRowData data, {
    required String baseFilename,
  }) async {
    try {
      final document = PdfDocument();
      document.pageSettings.orientation = PdfPageOrientation.landscape;
      document.pageSettings.margins.all = 24;

      // Load fonts
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

      PdfFont regularFont(double size) => fontBytes != null
          ? PdfTrueTypeFont(fontBytes, size)
          : PdfStandardFont(PdfFontFamily.helvetica, size);

      PdfFont boldFont(double size) => boldFontBytes != null
          ? PdfTrueTypeFont(boldFontBytes, size)
          : (fontBytes != null
                ? PdfTrueTypeFont(fontBytes, size)
                : PdfStandardFont(
                    PdfFontFamily.helvetica,
                    size,
                    style: PdfFontStyle.bold,
                  ));

      final page = document.pages.add();
      final graphics = page.graphics;
      final clientSize = page.getClientSize();

      // Report Header
      graphics.drawString(
        'Coozy The Cafe',
        boldFont(16),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, 0, clientSize.width - 150, 20),
      );
      graphics.drawString(
        'Generated: ${DateTime.now().toString().substring(0, 16)}',
        regularFont(8.5),
        brush: PdfSolidBrush(PdfColor(117, 117, 117)),
        bounds: Rect.fromLTWH(clientSize.width - 150, 0, 150, 16),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );

      graphics.drawString(
        data.reportTitle,
        boldFont(12),
        brush: PdfSolidBrush(PdfColor(55, 71, 79)),
        bounds: Rect.fromLTWH(0, 22, clientSize.width, 16),
      );

      double startY = 42;
      if (data.dateRangeStr != null) {
        graphics.drawString(
          'Period: ${data.dateRangeStr}',
          regularFont(9),
          brush: PdfSolidBrush(PdfColor(97, 97, 97)),
          bounds: Rect.fromLTWH(0, startY, clientSize.width, 14),
        );
        startY += 18;
      } else {
        startY += 4;
      }

      // Draw Grid Table
      final grid = PdfGrid();
      grid.style.font = regularFont(8.5);

      if (data.headers.isNotEmpty) {
        grid.columns.add(count: data.headers.length);
        final headerRow = grid.headers.add(1)[0];
        headerRow.style.font = boldFont(9);
        headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(69, 90, 100));
        headerRow.style.textBrush = PdfBrushes.white;

        for (int c = 0; c < data.headers.length; c++) {
          headerRow.cells[c].value = data.headers[c];
        }

        for (final rowData in data.rows) {
          final gridRow = grid.rows.add();
          for (int c = 0; c < rowData.length; c++) {
            if (c < grid.columns.count) {
              gridRow.cells[c].value = rowData[c]?.toString() ?? '';
            }
          }
        }

        // Apply alternating row style
        for (int r = 0; r < grid.rows.count; r++) {
          if (r % 2 == 1) {
            grid.rows[r].style.backgroundBrush = PdfSolidBrush(
              PdfColor(245, 245, 245),
            );
          }
        }

        grid.draw(page: page, bounds: Rect.fromLTWH(0, startY, 0, 0));
      }

      final bytes = Uint8List.fromList(document.saveSync());
      document.dispose();
      final filename = '$baseFilename.pdf';

      return await shared.PdfSaveHelper.saveAndDownloadPdf(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      return shared.PdfSaveResult.failure(e.toString());
    }
  }
}
