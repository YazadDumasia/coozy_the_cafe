import 'package:barcode/barcode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
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
    final cleanCategory = categoryName.trim();
    final cleanSub = subcategoryName?.trim();
    if (cleanSub != null && cleanSub.isNotEmpty) {
      return '$cleanCategory > $cleanSub'.toUpperCase();
    }
    return cleanCategory.toUpperCase();
  }
}

class _BarcodeComputeParams {
  final List<MenuItemBarcodeInfo> barcodeItems;
  final int columnsCount;
  final String? title;
  final Uint8List? fontBytes;
  final Uint8List? boldFontBytes;
  final Uint8List? logoBytes;

  _BarcodeComputeParams({
    required this.barcodeItems,
    required this.columnsCount,
    this.title,
    this.fontBytes,
    this.boldFontBytes,
    this.logoBytes,
  });
}

class MenuItemBarcodePdfGenerator {
  static const String logoAssetPath = 'assets/images/app_logo_clear_bg.png';

  /// Extracts flat list of barcode info items from catalog data, handling individual variations separately.
  static List<MenuItemBarcodeInfo> extractBarcodeItems(
    MenuCatalogData catalog,
  ) {
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
      final payload = item.hashId.isNotEmpty ? item.hashId : 'ITEM_${item.id}';

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
        final payload = variation.hashId.isNotEmpty
            ? variation.hashId
            : 'VAR_${variation.id}';

        final varPrice = variation.sellingPrice ?? item.sellingPrice ?? 0.0;

        result.add(
          MenuItemBarcodeInfo(
            id: item.id,
            name: item.name.isNotEmpty ? item.name : 'Item #${item.id}',
            variationName: variation.name?.isNotEmpty == true
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

  /// Generates printable PDF document containing barcode label stickers asynchronously using Syncfusion.
  static Future<Uint8List> generatePdf({
    required List<MenuItemBarcodeInfo> barcodeItems,
    int columnsCount = 3,
    String? title,
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

    final params = _BarcodeComputeParams(
      barcodeItems: barcodeItems,
      columnsCount: columnsCount,
      title: title,
      fontBytes: fontBytes,
      boldFontBytes: boldFontBytes,
      logoBytes: logoBytes,
    );

    // 2. On web, run directly to avoid web worker postMessage serialization hang; on native, use compute!
    if (kIsWeb) {
      return await _generatePdfInIsolate(params);
    }
    return compute(_generatePdfInIsolate, params);
  }

  /// Entry point for PDF generation using Syncfusion PDF document.
  static Future<Uint8List> _generatePdfInIsolate(
    _BarcodeComputeParams params,
  ) async {
    final int cols = params.columnsCount.clamp(2, 4);

    final document = PdfDocument();
    // A4 dimensions: 595.28 x 841.89 points
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 18;

    // Resolve fonts
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

    final barcodeItems = params.barcodeItems;
    final logoBytes = params.logoBytes;
    PdfBitmap? logoBitmap;
    if (logoBytes != null) {
      try {
        logoBitmap = PdfBitmap(logoBytes);
      } catch (_) {
        logoBitmap = null;
      }
    }

    if (barcodeItems.isEmpty) {
      final page = document.pages.add();
      final textFont = regularFont(14);
      final clientSize = page.getClientSize();
      page.graphics.drawString(
        'No Menu Items Available for Barcode Labels',
        textFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(
          0,
          clientSize.height / 2 - 20,
          clientSize.width,
          40,
        ),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );
      final bytes = Uint8List.fromList(document.saveSync());
      document.dispose();
      return bytes;
    }

    // Determine dimensions and count per page based on columns count
    // Printable width on A4 with 18 margin on each side: 595.28 - 36 = 559.28
    int rowsPerPage;
    double labelWidth;
    double labelHeight;
    const double colSpacing = 8.0;
    const double rowSpacing = 8.0;

    if (cols == 2) {
      rowsPerPage = 5;
      labelWidth = 268;
      labelHeight = 135;
    } else if (cols == 4) {
      rowsPerPage = 6;
      labelWidth = 132;
      labelHeight = 110;
    } else {
      rowsPerPage = 5;
      labelWidth = 178;
      labelHeight = 135;
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
    final headerTitleFont = boldFont(12);
    final headerCountFont = regularFont(9);
    final footerFont = regularFont(8);
    final brownBrush = PdfSolidBrush(PdfColor(78, 52, 46));
    final greyBrush = PdfSolidBrush(PdfColor(117, 117, 117));
    final headerBorderPen = PdfPen(PdfColor(220, 220, 220), width: 0.8);

    for (int pageIdx = 0; pageIdx < pages.length; pageIdx++) {
      final pageItems = pages[pageIdx];
      final page = document.pages.add();
      final graphics = page.graphics;
      final clientSize = page.getClientSize();

      // Top Header
      const double headerHeight = 22;
      graphics.drawString(
        '$docTitle ($cols Columns)',
        headerTitleFont,
        brush: brownBrush,
        bounds: Rect.fromLTWH(0, 0, clientSize.width - 120, headerHeight),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
      );
      graphics.drawString(
        'Total Labels: ${barcodeItems.length}',
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

      // Labels Grid
      const double contentStartY = headerHeight + 10;
      final totalRowWidth = (cols * labelWidth) + ((cols - 1) * colSpacing);
      final double startX = (clientSize.width - totalRowWidth) / 2 > 0
          ? (clientSize.width - totalRowWidth) / 2
          : 0.0;

      for (int itemIdx = 0; itemIdx < pageItems.length; itemIdx++) {
        final row = itemIdx ~/ cols;
        final col = itemIdx % cols;
        final item = pageItems[itemIdx];

        final double x = startX + (col * (labelWidth + colSpacing));
        final double y = contentStartY + (row * (labelHeight + rowSpacing));

        _drawBarcodeLabel(
          graphics: graphics,
          itemInfo: item,
          logoBitmap: logoBitmap,
          bounds: Rect.fromLTWH(x, y, labelWidth, labelHeight),
          cols: cols,
          regularFont: regularFont,
          boldFont: boldFont,
        );
      }

      // Bottom Footer
      final pageNumberText = 'Page ${pageIdx + 1} of ${pages.length}';
      graphics.drawString(
        pageNumberText,
        footerFont,
        brush: greyBrush,
        bounds: Rect.fromLTWH(0, clientSize.height - 14, clientSize.width, 14),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.right,
          lineAlignment: PdfVerticalAlignment.bottom,
        ),
      );
    }

    final bytes = Uint8List.fromList(document.saveSync());
    document.dispose();
    return bytes;
  }

  /// Draws a single compact Barcode Tag sticker card onto the page graphics.
  static void _drawBarcodeLabel({
    required PdfGraphics graphics,
    required MenuItemBarcodeInfo itemInfo,
    required PdfBitmap? logoBitmap,
    required Rect bounds,
    required int cols,
    required PdfFont Function(double size) regularFont,
    required PdfFont Function(double size) boldFont,
  }) {
    final double padding = cols == 4 ? 4.0 : 6.0;
    final innerBounds = Rect.fromLTWH(
      bounds.left + padding,
      bounds.top + padding,
      bounds.width - (padding * 2),
      bounds.height - (padding * 2),
    );

    // 1. Label card background and border with corner radius 10 and primary color 0xffa43c12
    final cardBorderPen = PdfPen(PdfColor(0xa4, 0x3c, 0x12), width: 1.0);
    _drawRoundedRectangle(
      graphics: graphics,
      bounds: bounds,
      radius: 10.0,
      brush: PdfBrushes.white,
      pen: cardBorderPen,
    );

    // 2. Header Row: Logo or Brand + Category badge
    final double headerRowHeight = cols == 4 ? 12.0 : 16.0;
    final headerRect = Rect.fromLTWH(
      innerBounds.left,
      innerBounds.top,
      innerBounds.width,
      headerRowHeight,
    );

    if (logoBitmap != null) {
      final double logoHeight = headerRowHeight;
      final double logoWidth =
          logoHeight * (logoBitmap.width / logoBitmap.height.clamp(1, 9999));
      graphics.drawImage(
        logoBitmap,
        Rect.fromLTWH(headerRect.left, headerRect.top, logoWidth, logoHeight),
      );
    } else {
      final brandFont = boldFont(cols == 4 ? 6.5 : 7.5);
      graphics.drawString(
        'COOZY',
        brandFont,
        brush: PdfSolidBrush(PdfColor(109, 76, 65)),
        bounds: Rect.fromLTWH(
          headerRect.left,
          headerRect.top,
          50,
          headerRowHeight,
        ),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
      );
    }

    // Category badge
    final double catFontSize = cols == 4 ? 4.5 : 5.5;
    final catFont = regularFont(catFontSize);
    final catText = itemInfo.categorySubcategoryDisplay;
    final catSize = catFont.measureString(catText);
    final double maxBadgeWidth =
        innerBounds.width - (logoBitmap != null ? 24.0 : 42.0);
    final badgeWidth = (catSize.width + 8).clamp(20.0, maxBadgeWidth);
    final badgeHeight = (catSize.height + 3).clamp(9.0, 14.0);
    final badgeRect = Rect.fromLTWH(
      innerBounds.right - badgeWidth,
      headerRect.top + ((headerRowHeight - badgeHeight) / 2),
      badgeWidth,
      badgeHeight,
    );

    final badgeBgBrush = PdfSolidBrush(PdfColor(240, 240, 240));
    graphics.drawRectangle(brush: badgeBgBrush, bounds: badgeRect);
    graphics.drawString(
      catText,
      catFont,
      brush: PdfSolidBrush(PdfColor(66, 66, 66)),
      bounds: badgeRect,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
        wordWrap: PdfWordWrapType.none,
      ),
    );

    // 3. Middle: Item Name & Formatted Price with currency
    final double nameFontSize = cols == 4 ? 7.5 : (cols == 2 ? 10.5 : 9.0);
    final double priceFontSize = cols == 4 ? 8.5 : (cols == 2 ? 12.0 : 10.5);
    final nameFont = boldFont(nameFontSize);
    final priceFont = boldFont(priceFontSize);

    final priceStr = core.CurrencyFormatter.format(value: itemInfo.price);
    final priceSize = priceFont.measureString(priceStr);
    final priceWidth = priceSize.width + 4;

    final double namePriceY = headerRect.bottom + 4;
    final double namePriceHeight = cols == 4 ? 22.0 : 26.0;

    // Price drawn on the right
    graphics.drawString(
      priceStr,
      priceFont,
      brush: PdfSolidBrush(PdfColor(62, 39, 35)),
      bounds: Rect.fromLTWH(
        innerBounds.right - priceWidth,
        namePriceY,
        priceWidth,
        namePriceHeight,
      ),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.top,
      ),
    );

    // Item name drawn on the left
    final double nameWidth = innerBounds.width - priceWidth - 4;
    graphics.drawString(
      itemInfo.fullDisplayName,
      nameFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(
        innerBounds.left,
        namePriceY,
        nameWidth,
        namePriceHeight,
      ),
      format: PdfStringFormat(
        lineAlignment: PdfVerticalAlignment.top,
        wordWrap: PdfWordWrapType.word,
      ),
    );

    // 4. Bottom: Code 128 Barcode
    final double barcodeAreaTop = namePriceY + namePriceHeight + 2;
    final double barcodeAreaHeight = innerBounds.bottom - barcodeAreaTop;
    final double barcodeWidth = innerBounds.width * 0.95;

    _drawBarcode(
      graphics: graphics,
      payload: itemInfo.barcodePayload,
      bounds: Rect.fromLTWH(
        innerBounds.left + ((innerBounds.width - barcodeWidth) / 2),
        barcodeAreaTop,
        barcodeWidth,
        barcodeAreaHeight.clamp(20.0, 50.0),
      ),
      fontSize: cols == 4 ? 5.0 : 6.0,
      regularFont: regularFont,
    );
  }

  /// Draws vector Code 128 barcode bars and label text onto [graphics].
  static void _drawBarcode({
    required PdfGraphics graphics,
    required String payload,
    required Rect bounds,
    required double fontSize,
    required PdfFont Function(double size) regularFont,
  }) {
    try {
      final bc = Barcode.code128();
      final elements = bc.make(
        payload,
        width: bounds.width,
        height: bounds.height,
        drawText: true,
        fontHeight: fontSize,
        textPadding: 2,
      );

      final brush = PdfBrushes.black;
      final textFont = regularFont(fontSize);

      for (final elem in elements) {
        if (elem is BarcodeBar) {
          if (elem.black) {
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
        } else if (elem is BarcodeText) {
          graphics.drawString(
            elem.text,
            textFont,
            brush: brush,
            bounds: Rect.fromLTWH(
              bounds.left + elem.left,
              bounds.top + elem.top,
              elem.width,
              elem.height,
            ),
            format: PdfStringFormat(alignment: PdfTextAlignment.center),
          );
        }
      }
    } catch (e) {
      // Fallback: draw text if payload encoding fails
      final fallbackFont = regularFont(fontSize + 1);
      graphics.drawString(
        payload,
        fallbackFont,
        brush: PdfBrushes.black,
        bounds: bounds,
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );
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
    await Printing.layoutPdf(onLayout: (_) async => pdfBytes, name: docName);
  }

  /// Downloads or saves generated Barcode PDF file directly to device storage across Mobile, Desktop & Web.
  static Future<shared.PdfSaveResult> downloadOrSavePdf({
    required List<MenuItemBarcodeInfo> barcodeItems,
    int columnsCount = 3,
    required String docName,
  }) async {
    final pdfBytes = await generatePdf(
      barcodeItems: barcodeItems,
      columnsCount: columnsCount,
    );
    return await shared.PdfSaveHelper.saveAndDownloadPdf(
      bytes: pdfBytes,
      filename: docName,
    );
  }

  /// Shares the generated Barcode PDF file via the system share sheet.
  static Future<void> sharePdf({
    required List<MenuItemBarcodeInfo> barcodeItems,
    int columnsCount = 3,
    required String docName,
    Rect? sharePositionOrigin,
  }) async {
    final pdfBytes = await generatePdf(
      barcodeItems: barcodeItems,
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
