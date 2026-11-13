import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';

import '../../../domain/services/menu_item_barcode_pdf_generator.dart';

class MenuItemBarcodeDialog extends StatefulWidget {
  final MenuItemBarcodeInfo? singleBarcodeInfo;
  final String? filterCategoryName;
  final Uint8List? prebuiltPdfBytes;
  final Map<int, Uint8List>? prebuiltColumnsPdfBytes;

  const MenuItemBarcodeDialog({
    super.key,
    this.singleBarcodeInfo,
    this.filterCategoryName,
    this.prebuiltPdfBytes,
    this.prebuiltColumnsPdfBytes,
  });

  @override
  State<MenuItemBarcodeDialog> createState() => _MenuItemBarcodeDialogState();
}

class _MenuItemBarcodeDialogState extends State<MenuItemBarcodeDialog> {
  final ValueNotifier<Uint8List?> _pdfBytesNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isSharingNotifier = ValueNotifier(false);
  final ValueNotifier<int> _selectedColumnsNotifier = ValueNotifier(2);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier(null);

  List<MenuItemBarcodeInfo> _barcodeItems = [];
  late final Map<int, Uint8List> _columnCache;
  bool _cancelled = false;
  int _generationId = 0;

  @override
  void initState() {
    super.initState();
    _columnCache = <int, Uint8List>{};
    if (widget.singleBarcodeInfo == null && widget.filterCategoryName == null) {
      if (widget.prebuiltColumnsPdfBytes != null) {
        _columnCache.addAll(widget.prebuiltColumnsPdfBytes!);
      }
      if (widget.prebuiltPdfBytes != null) {
        _columnCache[2] = widget.prebuiltPdfBytes!;
      }
    }

    if (_columnCache.containsKey(_selectedColumnsNotifier.value)) {
      _pdfBytesNotifier.value = _columnCache[_selectedColumnsNotifier.value];
      _isLoadingNotifier.value = false;
    } else {
      _loadBarcodePdf();
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    _pdfBytesNotifier.dispose();
    _isLoadingNotifier.dispose();
    _isSavingNotifier.dispose();
    _isSharingNotifier.dispose();
    _selectedColumnsNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadBarcodePdf() async {
    final int myGeneration = ++_generationId;

    if (!mounted || _cancelled) return;
    _isLoadingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 100));
    if (_cancelled || _generationId != myGeneration) return;

    try {
      if (_barcodeItems.isEmpty) {
        if (widget.singleBarcodeInfo != null) {
          _barcodeItems = [widget.singleBarcodeInfo!];
        } else {
          final waiterRepo = core.sl<WaiterOrderPlacementRepository>();
          final catalogRes = await waiterRepo.getActiveMenuCatalog();

          if (_cancelled || _generationId != myGeneration) return;

          catalogRes.fold((failure) => _barcodeItems = [], (catalog) {
            var items = MenuItemBarcodePdfGenerator.extractBarcodeItems(
              catalog,
            );
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
          });
        }
      }

      if (_cancelled || _generationId != myGeneration) return;

      final bytes = await MenuItemBarcodePdfGenerator.generatePdf(
        barcodeItems: _barcodeItems,
        columnsCount: _selectedColumnsNotifier.value,
        title: 'Coozy The Cafe - Menu Item Barcodes',
      );

      if (_cancelled || _generationId != myGeneration || !mounted) return;

      _columnCache[_selectedColumnsNotifier.value] = bytes;
      _pdfBytesNotifier.value = bytes;
      _errorMessageNotifier.value = null;
      _isLoadingNotifier.value = false;
    } catch (e, stack) {
      core.PlatformUtils.debugLog(
        MenuItemBarcodeDialog,
        'Error generating Barcode PDF: $e\n$stack',
      );
      if (!_cancelled && _generationId == myGeneration && mounted) {
        _errorMessageNotifier.value = e.toString();
        _isLoadingNotifier.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titleText = widget.singleBarcodeInfo != null
        ? '${widget.singleBarcodeInfo!.fullDisplayName} Barcode'
        : (widget.filterCategoryName != null
              ? '${widget.filterCategoryName} Barcode Cards'
              : 'Menu Item Barcode Cards');

    final now = DateTime.now();
    final String timeStampStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';

    final String docName = 'Coozy_Menu_Item_Barcodes_$timeStampStr.pdf';

    final isMobile = shared.ResponsiveLayout.isMobile(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          isDesktop ? 16 : (isTablet ? 12 : 0),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: isDesktop
          ? const EdgeInsets.symmetric(horizontal: 40, vertical: 28)
          : isTablet
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          : EdgeInsets.zero,
      child: Container(
        width: isDesktop
            ? screenSize.width * 0.80
            : (isTablet ? screenSize.width * 0.94 : screenSize.width),
        height: isMobile ? screenSize.height : null,
        constraints: BoxConstraints(
          maxHeight: isDesktop
              ? screenSize.height * 0.85
              : (isTablet ? screenSize.height * 0.92 : screenSize.height),
        ),
        padding: EdgeInsets.all(isMobile ? 12 : 20),
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
                        size: isMobile ? 20 : 24,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          titleText,
                          style:
                              (isMobile
                                      ? Theme.of(context).textTheme.titleSmall
                                      : Theme.of(context).textTheme.titleMedium)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),

            // Column Count Configurator Bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: isMobile ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedColumnsNotifier,
                builder: (context, selectedColumns, _) {
                  final segmentList = [
                    ButtonSegment<int>(
                      value: 2,
                      label: Text(isMobile ? '2 Cols' : '2 Columns'),
                      icon: const Icon(Icons.view_column_outlined, size: 16),
                    ),
                    ButtonSegment<int>(
                      value: 3,
                      label: Text(isMobile ? '3 Cols' : '3 Columns'),
                      icon: const Icon(Icons.view_week_outlined, size: 16),
                    ),
                    ButtonSegment<int>(
                      value: 4,
                      label: Text(isMobile ? '4 Cols' : '4 Columns'),
                      icon: const Icon(Icons.grid_view_rounded, size: 16),
                    ),
                  ];

                  void onSelect(Set<int> newSelection) {
                    if (newSelection.isNotEmpty &&
                        newSelection.first != selectedColumns) {
                      final selectedCol = newSelection.first;
                      _selectedColumnsNotifier.value = selectedCol;
                      if (_columnCache.containsKey(selectedCol)) {
                        _pdfBytesNotifier.value = _columnCache[selectedCol];
                        _isLoadingNotifier.value = false;
                      } else {
                        _pdfBytesNotifier.value = null;
                        _isLoadingNotifier.value = true;
                        _loadBarcodePdf();
                      }
                    }
                  }

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Columns Layout:',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<int>(
                            segments: segmentList,
                            selected: {selectedColumns},
                            onSelectionChanged: onSelect,
                            style: const ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Text(
                        'Columns: ',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      SegmentedButton<int>(
                        segments: segmentList,
                        selected: {selectedColumns},
                        onSelectionChanged: onSelect,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // PDF Viewer Area or Loading Animation
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: _isLoadingNotifier,
                builder: (context, isLoading, _) {
                  if (isLoading) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(
                            Theme.of(context).brightness == Brightness.dark
                                ? Assets.lottie.qrcodeDark
                                : Assets.lottie.qrcodeLight,
                            width: isMobile ? 120 : 160,
                            height: isMobile ? 120 : 160,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.tr(
                                  shared.LocaleKeys.commonPleaseWait,
                                  track: shared.TrackConstants.commonTrack,
                                ) ??
                                'Please wait...',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ValueListenableBuilder<String?>(
                    valueListenable: _errorMessageNotifier,
                    builder: (context, errorMessage, _) {
                      if (errorMessage != null) {
                        return Center(
                          child: Text(
                            'Failed to generate barcode PDF: $errorMessage',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        );
                      }

                      return ValueListenableBuilder<Uint8List?>(
                        valueListenable: _pdfBytesNotifier,
                        builder: (context, pdfBytes, _) {
                          if (pdfBytes != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SfPdfViewer.memory(
                                  pdfBytes,
                                  canShowScrollHead: false,
                                  canShowScrollStatus: false,
                                  onDocumentLoadFailed:
                                      (PdfDocumentLoadFailedDetails details) {
                                        core.PlatformUtils.debugLog(
                                          MenuItemBarcodeDialog,
                                          'SfPdfViewer load failed: ${details.error} - ${details.description}',
                                        );
                                      },
                                ),
                              ),
                            );
                          }

                          return Center(
                            child: Text(
                              context.tr(
                                    shared.LocaleKeys.commonErrorMsg,
                                    track: shared.TrackConstants.commonTrack,
                                  ) ??
                                  'Failed to render Barcode PDF preview',
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            ListenableBuilder(
              listenable: Listenable.merge([
                _isSavingNotifier,
                _isSharingNotifier,
                _isLoadingNotifier,
              ]),
              builder: (context, _) {
                final isSaving = _isSavingNotifier.value;
                final isSharing = _isSharingNotifier.value;
                final isLoading = _isLoadingNotifier.value;
                final isBusy = isSaving || isSharing || isLoading;

                Future<void> onPrint() async {
                  try {
                    await MenuItemBarcodePdfGenerator.printOrShareBarcodeCards(
                      barcodeItems: _barcodeItems,
                      columnsCount: _selectedColumnsNotifier.value,
                      docName: docName,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      shared.SnackBarUtils.showError(
                        context,
                        message: 'Failed to print Barcode PDF: $e',
                      );
                    }
                  }
                }

                Future<void> onShare() async {
                  _isSharingNotifier.value = true;
                  try {
                    await MenuItemBarcodePdfGenerator.sharePdf(
                      barcodeItems: _barcodeItems,
                      columnsCount: _selectedColumnsNotifier.value,
                      docName: docName,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      shared.SnackBarUtils.showError(
                        context,
                        message: 'Failed to share Barcode PDF: $e',
                      );
                    }
                  } finally {
                    if (mounted) {
                      _isSharingNotifier.value = false;
                    }
                  }
                }

                Future<void> onDownload() async {
                  _isSavingNotifier.value = true;
                  try {
                    final result =
                        await MenuItemBarcodePdfGenerator.downloadOrSavePdf(
                          barcodeItems: _barcodeItems,
                          columnsCount: _selectedColumnsNotifier.value,
                          docName: docName,
                        );

                    if (!context.mounted) return;

                    if (result.isSuccess) {
                      final String successText = result.isWeb
                          ? 'PDF download started!'
                          : (context.tr(
                                  shared.LocaleKeys.pdfSaveSuccessMsg,
                                  params: {'path': result.filePath ?? docName},
                                  track: shared.TrackConstants.tablePageTrack,
                                ) ??
                                'PDF saved successfully');

                      shared.SnackBarUtils.showSuccess(
                        context,
                        message: successText,
                        duration: const Duration(seconds: 4),
                      );
                    } else {
                      final String errorMsg =
                          result.errorMessage ?? 'Unknown error';
                      shared.SnackBarUtils.showError(
                        context,
                        message:
                            context.tr(
                              shared.LocaleKeys.pdfSaveFailedMsg,
                              params: {'error': errorMsg},
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Failed to save PDF: $errorMsg',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      shared.SnackBarUtils.showError(
                        context,
                        message: 'Failed to save PDF: $e',
                      );
                    }
                  } finally {
                    if (mounted) {
                      _isSavingNotifier.value = false;
                    }
                  }
                }

                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: isBusy ? null : onPrint,
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text('Print Barcode PDF'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isBusy ? null : onShare,
                              icon: isSharing
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.share_rounded, size: 16),
                              label: const Text('Share'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isBusy ? null : onDownload,
                              icon: isSaving
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.download_rounded,
                                      size: 16,
                                    ),
                              label: Text(isSaving ? 'Saving...' : 'Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Wrap(
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
                      onPressed: isBusy ? null : onShare,
                      icon: isSharing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share_rounded),
                      label: const Text('Share PDF'),
                    ),
                    OutlinedButton.icon(
                      onPressed: isBusy ? null : onDownload,
                      icon: isSaving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded),
                      label: Text(
                        isSaving ? 'Saving...' : 'Save / Download PDF',
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: isBusy ? null : onPrint,
                      icon: const Icon(Icons.print_rounded),
                      label: const Text('Print Barcode PDF'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
