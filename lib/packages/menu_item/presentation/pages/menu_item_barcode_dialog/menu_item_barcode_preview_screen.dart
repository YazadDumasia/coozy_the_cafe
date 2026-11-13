import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/repositories/waiter_order_placement_repository.dart';

import '../../../domain/services/menu_item_barcode_pdf_generator.dart';

class MenuItemBarcodePreviewScreen extends StatefulWidget {
  final MenuItemBarcodeInfo? singleBarcodeInfo;
  final String? filterCategoryName;
  final Uint8List? prebuiltPdfBytes;
  final Map<int, Uint8List>? prebuiltColumnsPdfBytes;

  const MenuItemBarcodePreviewScreen({
    super.key,
    this.singleBarcodeInfo,
    this.filterCategoryName,
    this.prebuiltPdfBytes,
    this.prebuiltColumnsPdfBytes,
  });

  @override
  State<MenuItemBarcodePreviewScreen> createState() =>
      _MenuItemBarcodePreviewScreenState();
}

class _MenuItemBarcodePreviewScreenState
    extends State<MenuItemBarcodePreviewScreen> {
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
      _loadPdf();
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

  Future<void> _loadPdf() async {
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
        MenuItemBarcodePreviewScreen,
        'Error generating Barcode PDF: $e\n$stack',
      );
      if (!_cancelled && _generationId == myGeneration && mounted) {
        _errorMessageNotifier.value = e.toString();
        _isLoadingNotifier.value = false;
      }
    }
  }

  String _buildDocName() {
    final now = DateTime.now();
    final String timeStampStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';

    return 'Coozy_Menu_Item_Barcodes_$timeStampStr.pdf';
  }

  Future<void> _handleShare(String docName) async {
    if (_isSavingNotifier.value ||
        _isSharingNotifier.value ||
        _isLoadingNotifier.value) {
      return;
    }
    _isSharingNotifier.value = true;
    try {
      await MenuItemBarcodePdfGenerator.sharePdf(
        barcodeItems: _barcodeItems,
        columnsCount: _selectedColumnsNotifier.value,
        docName: docName,
      );
    } catch (e) {
      if (mounted) {
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

  Future<void> _handleDownloadOrSave(String docName) async {
    if (_isSavingNotifier.value ||
        _isSharingNotifier.value ||
        _isLoadingNotifier.value) {
      return;
    }
    _isSavingNotifier.value = true;
    try {
      final result = await MenuItemBarcodePdfGenerator.downloadOrSavePdf(
        barcodeItems: _barcodeItems,
        columnsCount: _selectedColumnsNotifier.value,
        docName: docName,
      );

      if (!mounted) return;

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
        final String errorMsg = result.errorMessage ?? 'Unknown error';
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
      if (mounted) {
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

  Future<void> _handlePrint(String docName) async {
    if (_isSavingNotifier.value ||
        _isSharingNotifier.value ||
        _isLoadingNotifier.value) {
      return;
    }
    try {
      await MenuItemBarcodePdfGenerator.printOrShareBarcodeCards(
        barcodeItems: _barcodeItems,
        columnsCount: _selectedColumnsNotifier.value,
        docName: docName,
      );
    } catch (e) {
      if (mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to print Barcode PDF: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String titleText = 'Menu Item Barcode Cards';
    final docName = _buildDocName();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleText,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSharingNotifier,
            builder: (context, isSharing, _) {
              return IconButton(
                tooltip: 'Share Barcodes PDF',
                icon: isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share_rounded),
                onPressed: () => _handleShare(docName),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isSavingNotifier,
            builder: (context, isSaving, _) {
              return IconButton(
                tooltip: 'Save / Download Barcodes PDF',
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                onPressed: () => _handleDownloadOrSave(docName),
              );
            },
          ),
          IconButton(
            tooltip: 'Print Barcodes PDF',
            icon: const Icon(Icons.print_rounded),
            onPressed: () => _handlePrint(docName),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Row(
              children: [
                Text(
                  'Columns:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _selectedColumnsNotifier,
                    builder: (context, selectedColumns, _) {
                      return SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(
                            value: 2,
                            label: Text('2 Cols'),
                            icon: Icon(Icons.view_column_outlined, size: 16),
                          ),
                          ButtonSegment<int>(
                            value: 3,
                            label: Text('3 Cols'),
                            icon: Icon(Icons.view_week_outlined, size: 16),
                          ),
                          ButtonSegment<int>(
                            value: 4,
                            label: Text('4 Cols'),
                            icon: Icon(Icons.grid_view_rounded, size: 16),
                          ),
                        ],
                        selected: {selectedColumns},
                        onSelectionChanged: (newSelection) {
                          if (newSelection.isNotEmpty &&
                              newSelection.first != selectedColumns) {
                            final selectedCol = newSelection.first;
                            _selectedColumnsNotifier.value = selectedCol;
                            if (_columnCache.containsKey(selectedCol)) {
                              _pdfBytesNotifier.value =
                                  _columnCache[selectedCol];
                              _isLoadingNotifier.value = false;
                            } else {
                              _pdfBytesNotifier.value = null;
                              _isLoadingNotifier.value = true;
                              _loadPdf();
                            }
                          }
                        },
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
                          theme.brightness == Brightness.dark
                              ? Assets.lottie.qrcodeDark
                              : Assets.lottie.qrcodeLight,
                          width: 160,
                          height: 160,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr(
                                shared.LocaleKeys.commonPleaseWait,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Please wait...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      );
                    }

                    return ValueListenableBuilder<Uint8List?>(
                      valueListenable: _pdfBytesNotifier,
                      builder: (context, pdfBytes, _) {
                        if (pdfBytes != null) {
                          return SfPdfViewer.memory(
                            pdfBytes,
                            canShowScrollHead: false,
                            canShowScrollStatus: false,
                            onDocumentLoadFailed: (details) {
                              core.PlatformUtils.debugLog(
                                MenuItemBarcodePreviewScreen,
                                'SfPdfViewer load failed: ${details.error} - ${details.description}',
                              );
                            },
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
        ],
      ),
    );
  }
}
