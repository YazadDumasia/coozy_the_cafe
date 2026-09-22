import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

  /// Export tabular data to PDF document.
  static Future<shared.PdfSaveResult> exportToPdf(
    ReportExportRowData data, {
    required String baseFilename,
  }) async {
    try {
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Coozy The Cafe',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          data.reportTitle,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey800,
                          ),
                        ),
                        if (data.dateRangeStr != null) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Period: ${data.dateRangeStr}',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    pw.Text(
                      'Generated: ${DateTime.now().toString().substring(0, 16)}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.TableHelper.fromTextArray(
                headers: data.headers,
                data: data.rows
                    .map((r) => r.map((c) => c?.toString() ?? '').toList())
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey700,
                ),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  ),
                ),
                oddRowDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                ),
                headerPadding: const pw.EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 6,
                ),
                cellPadding: const pw.EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 6,
                ),
              ),
            ];
          },
        ),
      );

      final bytes = await doc.save();
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
