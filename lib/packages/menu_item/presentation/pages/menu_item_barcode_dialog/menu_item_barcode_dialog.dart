import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';
import '../../../domain/services/menu_item_barcode_pdf_generator.dart';

/// Monotonically increasing counter used to generate unique source-name keys
/// for [PdfDocumentRefData], ensuring each dialog instance gets its own
/// isolated document (no sharing via the [PdfDocumentRef._listenables] cache).
int _docRefCounter = 0;

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
  bool _isSaving = false;
  bool _isSharing = false;
  int _selectedColumns = 3;

  /// Set to true in dispose() so in-flight async work aborts cleanly.
  bool _cancelled = false;

  /// Incremented each time a new generation starts; guards against stale
  /// results from a previous run being applied after the column count changes.
  int _generationId = 0;

  // ---------------------------------------------------------------------------
  // PDF engine resource ownership
  // ---------------------------------------------------------------------------

  /// Each completed generation gets a unique [sourceName] so pdfrx never
  /// shares/caches this document with another dialog or generation.
  /// The unique key ensures [PdfDocumentRef._listenables] treats each
  /// generation as a distinct document — so autoDispose removes it from the
  /// cache when the [PdfViewer] widget is unmounted (i.e. dialog dismissed).
  String? _pdfSourceName;

  @override
  void initState() {
    super.initState();
    _loadBarcodePdf();
  }

  @override
  void dispose() {
    _cancelled = true;
    super.dispose();
  }

  Future<void> _loadBarcodePdf() async {
    // Claim a generation slot; later steps check against this to discard
    // results from superseded runs (e.g. rapid column-count changes).
    final int myGeneration = ++_generationId;

    if (!mounted || _cancelled) return;
    setState(() => _isLoading = true);

    // Yield to the UI thread so the spinner appears immediately.
    await Future.delayed(const Duration(milliseconds: 30));
    if (_cancelled || _generationId != myGeneration) return;

    try {
      if (widget.singleBarcodeInfo != null) {
        _barcodeItems = [widget.singleBarcodeInfo!];
      } else {
        final waiterRepo = core.sl<WaiterOrderPlacementRepository>();
        final catalogRes = await waiterRepo.getActiveMenuCatalog();

        // Abort if the dialog was dismissed while we were fetching the catalog.
        if (_cancelled || _generationId != myGeneration) return;

        catalogRes.fold(
          (failure) => _barcodeItems = [],
          (catalog) {
            var items = MenuItemBarcodePdfGenerator.extractBarcodeItems(catalog);
            if (widget.filterCategoryName != null &&
                widget.filterCategoryName!.isNotEmpty) {
              items = items
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

      // Abort before the expensive PDF rendering step if already cancelled.
      if (_cancelled || _generationId != myGeneration) return;

      final bytes = await MenuItemBarcodePdfGenerator.generatePdf(
        barcodeItems: _barcodeItems,
        columnsCount: _selectedColumns,
        title: 'Coozy The Cafe - Menu Item Barcodes',
      );

      // Final guard: do not update state if dismissed after rendering finished.
      if (_cancelled || _generationId != myGeneration || !mounted) return;

      // Assign a unique source name so pdfrx doesn't share/cache this document
      // with any other PdfViewer instance. With autoDispose:true (default),
      // the engine worker is released when PdfViewer leaves the tree.
      final uniqueSourceName = 'barcode_pdf_${++_docRefCounter}';

      setState(() {
        _pdfBytes = bytes;
        _pdfSourceName = uniqueSourceName;
        _isLoading = false;
      });
    } catch (e, stack) {
      core.PlatformUtils.debugLog(
        MenuItemBarcodeDialog,
        'Error generating Barcode PDF: $e\n$stack',
      );
      if (!_cancelled && _generationId == myGeneration && mounted) {
        setState(() => _isLoading = false);
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          titleText,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
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
                  Flexible(
                    flex: 0,
                    child: Text(
                      'Columns:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(
                          value: 2,
                          label: Text('2'),
                          icon: Icon(Icons.view_column_outlined, size: 16),
                        ),
                        ButtonSegment<int>(
                          value: 3,
                          label: Text('3'),
                          icon: Icon(Icons.view_week_outlined, size: 16),
                        ),
                        ButtonSegment<int>(
                          value: 4,
                          label: Text('4'),
                          icon: Icon(Icons.grid_view_rounded, size: 16),
                        ),
                      ],
                      selected: {_selectedColumns},
                      onSelectionChanged: (newSelection) {
                        if (newSelection.isNotEmpty &&
                            newSelection.first != _selectedColumns) {
                          setState(() {
                            _selectedColumns = newSelection.first;
                            _pdfBytes = null;
                            _pdfSourceName = null;
                            _isLoading = true;
                          });
                          _loadBarcodePdf();
                        }
                      },
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
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
                            sourceName: _pdfSourceName!,
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
                  onPressed:
                      (_isSaving || _isSharing || _isLoading)
                          ? null
                          : () async {
                            setState(() => _isSharing = true);
                            try {
                              await MenuItemBarcodePdfGenerator.sharePdf(
                                barcodeItems: _barcodeItems,
                                columnsCount: _selectedColumns,
                                docName: docName,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to share PDF: $e'),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isSharing = false);
                              }
                            }
                          },
                  icon:
                      _isSharing
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.share_rounded),
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.pdfShareBtn,
                          track: shared.TrackConstants.tablePageTrack,
                        ) ??
                        'Share PDF',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed:
                      (_isSaving || _isSharing || _isLoading)
                          ? null
                          : () async {
                            setState(() => _isSaving = true);
                            try {
                              final result =
                                  await MenuItemBarcodePdfGenerator.downloadOrSavePdf(
                                    barcodeItems: _barcodeItems,
                                    columnsCount: _selectedColumns,
                                    docName: docName,
                                  );

                              if (!context.mounted) return;

                              if (result.isSuccess) {
                                final String successText =
                                    result.isWeb
                                        ? 'PDF download started!'
                                        : (context.tr(
                                              shared.LocaleKeys.pdfSaveSuccessMsg,
                                              params: {
                                                'path':
                                                    result.filePath ?? docName,
                                              },
                                              track:
                                                  shared
                                                      .TrackConstants
                                                      .tablePageTrack,
                                            ) ??
                                            'PDF saved successfully: ${result.filePath}');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(successText),
                                    duration: const Duration(seconds: 4),
                                    action:
                                        (!result.isWeb &&
                                                result.filePath != null)
                                            ? SnackBarAction(
                                              label:
                                                  context.tr(
                                                    shared
                                                        .LocaleKeys
                                                        .pdfShareBtn,
                                                    track:
                                                        shared
                                                            .TrackConstants
                                                            .tablePageTrack,
                                                  ) ??
                                                  'Share',
                                              onPressed: () {
                                                MenuItemBarcodePdfGenerator.sharePdf(
                                                  barcodeItems: _barcodeItems,
                                                  columnsCount:
                                                      _selectedColumns,
                                                  docName: docName,
                                                );
                                              },
                                            )
                                            : null,
                                  ),
                                );
                              } else {
                                final String errorMsg =
                                    result.errorMessage ?? 'Unknown error';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.tr(
                                            shared.LocaleKeys.pdfSaveFailedMsg,
                                            params: {'error': errorMsg},
                                            track:
                                                shared
                                                    .TrackConstants
                                                    .tablePageTrack,
                                          ) ??
                                          'Failed to save PDF: $errorMsg',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to save PDF: $e'),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isSaving = false);
                              }
                            }
                          },
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.download_rounded),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save / Download PDF',
                  ),
                ),
                ElevatedButton.icon(
                  onPressed:
                      (_isSaving || _isSharing || _isLoading)
                          ? null
                          : () async {
                            try {
                              await MenuItemBarcodePdfGenerator.printOrShareBarcodeCards(
                                barcodeItems: _barcodeItems,
                                columnsCount: _selectedColumns,
                                docName: docName,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to print PDF: $e'),
                                  ),
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
