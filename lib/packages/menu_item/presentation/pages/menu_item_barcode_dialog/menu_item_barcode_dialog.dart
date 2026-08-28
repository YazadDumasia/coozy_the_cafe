import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import '../../../domain/services/menu_item_barcode_pdf_generator.dart';

class MenuItemBarcodeDialog extends StatefulWidget {
  final MenuItemBarcodeInfo? singleBarcodeInfo;
  final String? filterCategoryName;

  const MenuItemBarcodeDialog({
    super.key,
    this.singleBarcodeInfo,
    this.filterCategoryName,
  });

  @override
  State<MenuItemBarcodeDialog> createState() => _MenuItemBarcodeDialogState();
}

class _MenuItemBarcodeDialogState extends State<MenuItemBarcodeDialog> {
  Uint8List? _pdfBytes;
  List<MenuItemBarcodeInfo> _barcodeItems = [];
  bool _isLoading = true;
  int _selectedColumns = 3;

  @override
  void initState() {
    super.initState();
    _loadBarcodePdf();
  }

  Future<void> _loadBarcodePdf() async {
    setState(() {
      _isLoading = true;
    });

    // Yield execution to UI frame so CircularProgressIndicator starts spinning fluidly
    await Future.delayed(const Duration(milliseconds: 30));

    try {
      if (widget.singleBarcodeInfo != null) {
        _barcodeItems = [widget.singleBarcodeInfo!];
      } else {
        final waiterRepo = core.sl<WaiterOrderPlacementRepository>();
        final catalogRes = await waiterRepo.getActiveMenuCatalog();

        catalogRes.fold(
          (failure) {
            _barcodeItems = [];
          },
          (catalog) {
            var items = MenuItemBarcodePdfGenerator.extractBarcodeItems(
              catalog,
            );
            if (widget.filterCategoryName != null &&
                widget.filterCategoryName!.isNotEmpty) {
              items =
                  items
                      .where(
                        (i) =>
                            i.categoryName.toLowerCase() ==
                            widget.filterCategoryName!.toLowerCase(),
                      )
                      .toList();
            }
            _barcodeItems = items;
          },
        );
      }

      final bytes = await MenuItemBarcodePdfGenerator.generatePdf(
        barcodeItems: _barcodeItems,
        columnsCount: _selectedColumns,
        title: 'Coozy The Cafe - Menu Item Barcodes',
      );

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      core.PlatformUtils.debugLog(
        MenuItemBarcodeDialog,
        'Error generating Barcode PDF: $e\n$stack',
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titleText =
        widget.singleBarcodeInfo != null
            ? '${widget.singleBarcodeInfo!.fullDisplayName} Barcode'
            : (widget.filterCategoryName != null
                ? '${widget.filterCategoryName} Barcode Cards'
                : 'Menu Item Barcode Cards');

    final now = DateTime.now();
    final String timeStampStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';

    final String docName = 'Coozy_Menu_Item_Barcodes_$timeStampStr.pdf';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 750),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Title & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      titleText,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Column Count Configurator Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    'Grid Columns Layout: ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment<int>(
                        value: 2,
                        label: Text('2 Columns'),
                        icon: Icon(Icons.view_column_outlined),
                      ),
                      ButtonSegment<int>(
                        value: 3,
                        label: Text('3 Columns'),
                        icon: Icon(Icons.view_week_outlined),
                      ),
                      ButtonSegment<int>(
                        value: 4,
                        label: Text('4 Columns'),
                        icon: Icon(Icons.grid_view_rounded),
                      ),
                    ],
                    selected: {_selectedColumns},
                    onSelectionChanged: (newSelection) {
                      if (newSelection.isNotEmpty) {
                        setState(() {
                          _selectedColumns = newSelection.first;
                        });
                        _loadBarcodePdf();
                      }
                    },
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),

            // PDF Viewer Container using pdfrx
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _pdfBytes != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PdfViewer.data(
                            _pdfBytes!,
                            sourceName: docName,
                          ),
                        ),
                      )
                      : Center(
                        child: Text(
                          context.tr(
                                shared.LocaleKeys.commonErrorMsg,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Failed to render Menu Barcode PDF preview',
                        ),
                      ),
            ),
            const SizedBox(height: 16),

            // Action Buttons: Close, Save / Download, Print
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.commonClose,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Close',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await MenuItemBarcodePdfGenerator.downloadOrSavePdf(
                        barcodeItems: _barcodeItems,
                        columnsCount: _selectedColumns,
                        docName: docName,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save PDF: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Save / Download PDF'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await MenuItemBarcodePdfGenerator.printOrShareBarcodeCards(
                        barcodeItems: _barcodeItems,
                        columnsCount: _selectedColumns,
                        docName: docName,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to print PDF: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.print_rounded),
                  label: const Text('Print Barcode PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
