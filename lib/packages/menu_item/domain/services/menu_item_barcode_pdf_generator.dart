import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/menu_catalog_data.dart';

class MenuItemBarcodeInfo {
  final int id;
  final String name;
  final String? variationName;
  final String categoryName;
  final String? subcategoryName;
  final double price;
  final String barcodePayload;

  MenuItemBarcodeInfo({
    required this.id,
    required this.name,
    this.variationName,
    required this.categoryName,
    this.subcategoryName,
    required this.price,
    required this.barcodePayload,
  });

  String get fullDisplayName =>
      variationName != null && variationName!.isNotEmpty
          ? '$name ($variationName)'
          : name;

  String get categorySubcategoryDisplay {
    if (subcategoryName != null && subcategoryName!.isNotEmpty) {
      return '$categoryName > $subcategoryName'.toUpperCase();
    }
    return categoryName.toUpperCase();
  }
}

class _BarcodeComputeParams {
  final List<MenuItemBarcodeInfo> barcodeItems;
  final int columnsCount;
  final String? title;
  final pw.Font? ttfFont;
  final pw.Font? ttfBoldFont;
  final Uint8List? logoBytes;

  _BarcodeComputeParams({
    required this.barcodeItems,
    required this.columnsCount,
    this.title,
    this.ttfFont,
    this.ttfBoldFont,
    this.logoBytes,
  });
}

class MenuItemBarcodePdfGenerator {
  static const String logoAssetPath = 'assets/images/app_logo_clear_bg.png';

  /// Extracts flat list of barcode info items from catalog data, handling individual variations separately.
  static List<MenuItemBarcodeInfo> extractBarcodeItems(MenuCatalogData catalog) {
    final List<MenuItemBarcodeInfo> result = [];

    for (final categoryData in catalog.categoryDataList) {
      final categoryName = categoryData.category.name ?? 'Category';

      // 1. Uncategorized items in category
      for (final itemWithVar in categoryData.uncategorizedItems) {
        _addBarcodeInfosForItem(
          result: result,
          categoryName: categoryName,
          subcategoryName: null,
          itemWithVar: itemWithVar,
        );
      }

      // 2. Subcategory items
      for (final subcat in categoryData.subcategories) {
        final subcatItems = categoryData.subcategoryItems[subcat.id] ?? [];
        for (final itemWithVar in subcatItems) {
          _addBarcodeInfosForItem(
            result: result,
            categoryName: categoryName,
            subcategoryName: subcat.name,
            itemWithVar: itemWithVar,
          );
        }
      }
    }

    return result;
  }

  static void _addBarcodeInfosForItem({
    required List<MenuItemBarcodeInfo> result,
    required String categoryName,
    required String? subcategoryName,
    required MenuItemWithVariations itemWithVar,
  }) {
    final item = itemWithVar.item;
    final variations = itemWithVar.variations;

    if (variations.isEmpty) {
      final payload =
          item.hashId.isNotEmpty
              ? item.hashId
              : 'ITEM_${item.id}';

      result.add(
        MenuItemBarcodeInfo(
          id: item.id,
          name: item.name.isNotEmpty ? item.name : 'Item #${item.id}',
          variationName: null,
          categoryName: categoryName,
          subcategoryName: subcategoryName,
          price: item.sellingPrice ?? 0.0,
          barcodePayload: payload,
        ),
      );
    } else {
      for (final variation in variations) {
        final payload =
            variation.hashId.isNotEmpty
                ? variation.hashId
                : 'VAR_${variation.id}';

        final varPrice = variation.sellingPrice ?? item.sellingPrice ?? 0.0;

        result.add(
          MenuItemBarcodeInfo(
            id: item.id,
            name: item.name.isNotEmpty ? item.name : 'Item #${item.id}',
            variationName:
                variation.name?.isNotEmpty == true
                    ? variation.name!
                    : 'Variation #${variation.id}',
            categoryName: categoryName,
            subcategoryName: subcategoryName,
            price: varPrice,
            barcodePayload: payload,
          ),
        );
      }
    }
  }

  /// Generates printable PDF document containing barcode label stickers asynchronously.
  static Future<Uint8List> generatePdf({
    required List<MenuItemBarcodeInfo> barcodeItems,
    int columnsCount = 3,
    String? title,
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

    final params = _BarcodeComputeParams(
      barcodeItems: barcodeItems,
      columnsCount: columnsCount,
      title: title,
      ttfFont: ttfFont,
      ttfBoldFont: ttfBoldFont,
      logoBytes: logoBytes,
    );

    // 2. On web, run directly to avoid web worker postMessage serialization hang; on native, use compute!
    if (kIsWeb) {
      return await _generatePdfInIsolate(params);
    }
    return compute(_generatePdfInIsolate, params);
  }

  /// Entry point for PDF generation.
  static Future<Uint8List> _generatePdfInIsolate(_BarcodeComputeParams params) async {
    final int cols = params.columnsCount.clamp(2, 4);

    final docTheme = pw.ThemeData.withFont(
      base: params.ttfFont,
      bold: params.ttfBoldFont,
    );

    final pdf = pw.Document(theme: docTheme);
    final logoBytes = params.logoBytes;
    final barcodeItems = params.barcodeItems;
    final ttfFont = params.ttfFont;

    if (barcodeItems.isEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: docTheme,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(
                'No Menu Items Available for Barcode Labels',
                style: const pw.TextStyle(fontSize: 14),
              ),
            );
          },
        ),
      );
      return await pdf.save();
    }

    // Determine dimensions and count per page based on columns count
    int rowsPerPage;
    double labelWidth;
    double labelHeight;

    if (cols == 2) {
      rowsPerPage = 5;
      labelWidth = 262;
      labelHeight = 120;
    } else if (cols == 4) {
      rowsPerPage = 6;
      labelWidth = 130;
      labelHeight = 96;
    } else {
      rowsPerPage = 5;
      labelWidth = 175;
      labelHeight = 120;
    }

    final int labelsPerPage = cols * rowsPerPage;

    final List<List<MenuItemBarcodeInfo>> pages = [];
    for (var i = 0; i < barcodeItems.length; i += labelsPerPage) {
      pages.add(
        barcodeItems.sublist(
          i,
          i + labelsPerPage > barcodeItems.length
              ? barcodeItems.length
              : i + labelsPerPage,
        ),
      );
    }

    final docTitle = params.title ?? 'Coozy The Cafe - Product Barcode Labels';

    for (final pageItems in pages) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: docTheme,
          margin: const pw.EdgeInsets.all(18),
          build: (pw.Context context) {
            final List<List<MenuItemBarcodeInfo>> rows = [];
            for (var j = 0; j < pageItems.length; j += cols) {
              rows.add(
                pageItems.sublist(
                  j,
                  j + cols > pageItems.length ? pageItems.length : j + cols,
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
                        '$docTitle ($cols Columns)',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.brown900,
                        ),
                      ),
                      pw.Text(
                        'Total Labels: ${barcodeItems.length}',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Column(
                  children: rows.map((rowItems) {
                    final List<pw.Widget> rowWidgets = [];
                    for (int c = 0; c < cols; c++) {
                      if (c < rowItems.length) {
                        rowWidgets.add(
                          _buildSmallBarcodeLabel(
                            itemInfo: rowItems[c],
                            logoBytes: logoBytes,
                            labelWidth: labelWidth,
                            labelHeight: labelHeight,
                            cols: cols,
                            font: ttfFont,
                          ),
                        );
                      } else {
                        rowWidgets.add(
                          pw.SizedBox(width: labelWidth, height: labelHeight),
                        );
                      }
                    }

                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
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

    return await pdf.save();
  }

  /// Builds a small compact Barcode Tag / Label sticker adjusted for column count.
  static pw.Widget _buildSmallBarcodeLabel({
    required MenuItemBarcodeInfo itemInfo,
    Uint8List? logoBytes,
    required double labelWidth,
    required double labelHeight,
    required int cols,
    pw.Font? font,
  }) {
    final priceStr = '\$${itemInfo.price.toStringAsFixed(2)}';

    final double nameFontSize = cols == 4 ? 7.5 : (cols == 2 ? 11 : 9.5);
    final double priceFontSize = cols == 4 ? 9 : (cols == 2 ? 13 : 11);
    final double barcodeHeight = cols == 4 ? 28 : 36;
    final double categoryFontSize = cols == 4 ? 4.5 : 5.5;

    return pw.Container(
      width: labelWidth,
      height: labelHeight,
      padding: pw.EdgeInsets.all(cols == 4 ? 5 : 7),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // Header: Logo / Brand + Category Badge
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoBytes != null)
                pw.Container(
                  height: cols == 4 ? 12 : 16,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                )
              else
                pw.Text(
                  'COOZY',
                  style: pw.TextStyle(
                    fontSize: cols == 4 ? 6 : 7.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown800,
                  ),
                ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 1,
                ),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
                child: pw.Text(
                  itemInfo.categorySubcategoryDisplay,
                  style: pw.TextStyle(
                    fontSize: categoryFontSize,
                    color: PdfColors.grey800,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),

          // Middle: Item Name & Price
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  itemInfo.fullDisplayName,
                  style: pw.TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                  maxLines: 2,
                ),
              ),
              pw.SizedBox(width: 3),
              pw.Text(
                priceStr,
                style: pw.TextStyle(
                  fontSize: priceFontSize,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.brown900,
                ),
              ),
            ],
          ),

          // Bottom: Code 128 Barcode Widget
          pw.Center(
            child: pw.Container(
              height: barcodeHeight,
              width: labelWidth * 0.90,
              alignment: pw.Alignment.center,
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: itemInfo.barcodePayload,
                drawText: true,
                textStyle: pw.TextStyle(
                  font: font,
                  fontSize: cols == 4 ? 4.5 : 5.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays interactive print preview screen using `printing`.
  static Future<void> printOrShareBarcodeCards({
    required List<MenuItemBarcodeInfo> barcodeItems,
    int columnsCount = 3,
    required String docName,
  }) async {
    final pdfBytes = await generatePdf(
      barcodeItems: barcodeItems,
      columnsCount: columnsCount,
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: docName,
    );
  }

  /// Downloads or saves generated Barcode PDF file across Mobile & Web.
  static Future<void> downloadOrSavePdf({
    required List<MenuItemBarcodeInfo> barcodeItems,
    int columnsCount = 3,
    required String docName,
  }) async {
    final pdfBytes = await generatePdf(
      barcodeItems: barcodeItems,
      columnsCount: columnsCount,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: docName,
    );
  }
}
