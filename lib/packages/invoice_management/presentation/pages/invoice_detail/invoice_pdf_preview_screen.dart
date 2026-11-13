import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/settings/domain/services/thermal_printer_service.dart';
import 'package:coozy_the_cafe/packages/settings/domain/services/esc_pos_ticket_builder.dart';
import 'package:coozy_the_cafe/packages/settings/domain/entities/thermal_printer_config.dart';

import '../../../domain/entities/invoice_management_entity.dart';
import '../../../domain/services/invoice_pdf_generator.dart';
import '../../widgets/invoice_pdf_preview_dialog/invoice_pdf_preview_dialog.dart';
import 'invoice_detail_screen_actions.dart';

class InvoicePdfPreviewScreen extends StatefulWidget {
  final InvoiceDetailsEntity details;
  final String? filePath;
  final Uint8List? prebuiltThermalBytes;
  final Uint8List? prebuiltA4Bytes;

  const InvoicePdfPreviewScreen({
    super.key,
    required this.details,
    this.filePath,
    this.prebuiltThermalBytes,
    this.prebuiltA4Bytes,
  });

  @override
  State<InvoicePdfPreviewScreen> createState() =>
      _InvoicePdfPreviewScreenState();
}

class _InvoicePdfPreviewScreenState extends State<InvoicePdfPreviewScreen> {
  final ValueNotifier<Uint8List?> _thermalBytesNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _thermalFilePathNotifier = ValueNotifier(null);
  File? _thermalTempFile;

  final ValueNotifier<Uint8List?> _a4BytesNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _a4FilePathNotifier = ValueNotifier(null);
  File? _a4TempFile;

  final ValueNotifier<bool> _isThermalLoadedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isA4LoadedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier(null);

  final ValueNotifier<InvoicePreviewFormat> _selectedFormatNotifier =
      ValueNotifier(InvoicePreviewFormat.thermal80mm);
  final ValueNotifier<bool> _isPrintingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.prebuiltThermalBytes != null) {
      _thermalBytesNotifier.value = widget.prebuiltThermalBytes;
      _isThermalLoadedNotifier.value = true;
      _isLoadingNotifier.value = false;
    }
    if (widget.prebuiltA4Bytes != null) {
      _a4BytesNotifier.value = widget.prebuiltA4Bytes;
      _isA4LoadedNotifier.value = true;
    }
    _preloadAllFormats();
  }

  @override
  void dispose() {
    _deleteCachedFiles();
    _thermalBytesNotifier.dispose();
    _thermalFilePathNotifier.dispose();
    _a4BytesNotifier.dispose();
    _a4FilePathNotifier.dispose();
    _isThermalLoadedNotifier.dispose();
    _isA4LoadedNotifier.dispose();
    _isLoadingNotifier.dispose();
    _errorMessageNotifier.dispose();
    _selectedFormatNotifier.dispose();
    _isPrintingNotifier.dispose();
    super.dispose();
  }

  Future<void> _preloadAllFormats() async {
    final thermalFuture = () async {
      try {
        if (!kIsWeb && widget.filePath != null && widget.filePath!.isNotEmpty) {
          final file = File(widget.filePath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            return (bytes: bytes, path: file.path, tempFile: null as File?);
          }
        }

        final bytes =
            widget.prebuiltThermalBytes ??
            await InvoicePdfGenerator.generatePdf(
              details: widget.details,
              isA4Format: false,
              is58mm: false,
            );

        if (!kIsWeb) {
          final tempFile = await _writeTempPdf(
            bytes: bytes,
            formatSuffix: 'thermal80',
          );
          return (bytes: bytes, path: tempFile.path, tempFile: tempFile);
        } else {
          return (bytes: bytes, path: null as String?, tempFile: null as File?);
        }
      } catch (e) {
        core.PlatformUtils.debugLog(
          InvoicePdfPreviewScreen,
          'Error preloading thermal PDF: $e',
        );
        rethrow;
      }
    }();

    final a4Future = () async {
      try {
        final bytes =
            widget.prebuiltA4Bytes ??
            await InvoicePdfGenerator.generatePdf(
              details: widget.details,
              isA4Format: true,
              is58mm: false,
            );

        if (!kIsWeb) {
          final tempFile = await _writeTempPdf(
            bytes: bytes,
            formatSuffix: 'a4',
          );
          return (bytes: bytes, path: tempFile.path, tempFile: tempFile);
        } else {
          return (bytes: bytes, path: null as String?, tempFile: null as File?);
        }
      } catch (e) {
        core.PlatformUtils.debugLog(
          InvoicePdfPreviewScreen,
          'Error preloading A4 PDF: $e',
        );
        return null;
      }
    }();

    try {
      final thermalResult = await thermalFuture;
      if (mounted) {
        _thermalBytesNotifier.value = thermalResult.bytes;
        _thermalFilePathNotifier.value = thermalResult.path;
        _thermalTempFile = thermalResult.tempFile;
        _isThermalLoadedNotifier.value = true;
        _isLoadingNotifier.value = false;
      }
    } catch (e) {
      if (mounted) {
        _errorMessageNotifier.value = e.toString();
        _isLoadingNotifier.value = false;
      }
    }

    final a4Result = await a4Future;
    if (mounted && a4Result != null) {
      _a4BytesNotifier.value = a4Result.bytes;
      _a4FilePathNotifier.value = a4Result.path;
      _a4TempFile = a4Result.tempFile;
      _isA4LoadedNotifier.value = true;
    }
  }

  Future<File> _writeTempPdf({
    required Uint8List bytes,
    required String formatSuffix,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final cleanHash = widget.details.invoice.hashId.isNotEmpty
        ? widget.details.invoice.hashId.replaceAll(RegExp(r'[^\w\-]'), '_')
        : '${widget.details.invoice.id}';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(
      '${tempDir.path}/invoice_${cleanHash}_${formatSuffix}_$timestamp.pdf',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> _deleteCachedFiles() async {
    if (kIsWeb) return;
    try {
      if (_thermalTempFile != null && await _thermalTempFile!.exists()) {
        await _thermalTempFile!.delete();
      }
      if (_a4TempFile != null && await _a4TempFile!.exists()) {
        await _a4TempFile!.delete();
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        InvoicePdfPreviewScreen,
        'Error deleting temp invoice PDFs: $e',
      );
    }
  }

  Future<void> _handleThermalPrint() async {
    if (_isPrintingNotifier.value) return;
    _isPrintingNotifier.value = true;
    try {
      final config = await ThermalPrinterService.instance.getPrinterConfig(
        stationKey: shared.PreferencesKeys.customerReceiptPrinterConfig,
      );

      final hasPrinter =
          (config.type == ThermalPrinterType.network &&
              config.ipAddress.isNotEmpty) ||
          (config.type == ThermalPrinterType.bluetooth &&
              config.bluetoothAddress.isNotEmpty);

      if (hasPrinter) {
        final bytes = await EscPosTicketBuilder.buildCustomerReceiptBytes(
          details: widget.details,
          paperSize: config.paperSize,
        );
        final success = await ThermalPrinterService.instance.printBytes(
          stationKey: shared.PreferencesKeys.customerReceiptPrinterConfig,
          bytes: bytes,
        );
        if (mounted) {
          if (success) {
            shared.SnackBarUtils.showSuccess(
              context,
              message: 'Receipt printed successfully on thermal printer!',
            );
          } else {
            shared.SnackBarUtils.showWarning(
              context,
              message:
                  'Thermal printer unreachable. Falling back to system print.',
            );
            await InvoicePdfGenerator.printPdf(
              details: widget.details,
              bytes:
                  _selectedFormatNotifier.value ==
                      InvoicePreviewFormat.thermal80mm
                  ? _thermalBytesNotifier.value
                  : _a4BytesNotifier.value,
            );
          }
        }
      } else {
        await InvoicePdfGenerator.printPdf(
          details: widget.details,
          bytes:
              _selectedFormatNotifier.value == InvoicePreviewFormat.thermal80mm
              ? _thermalBytesNotifier.value
              : _a4BytesNotifier.value,
        );
      }
    } finally {
      if (mounted) {
        _isPrintingNotifier.value = false;
      }
    }
  }

  Future<void> _handleShare() async {
    await InvoiceDetailScreenActions.onShare(context, details: widget.details);
  }

  Future<void> _handleDownload() async {
    await InvoiceDetailScreenActions.onDownload(
      context,
      details: widget.details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final receiptNo = widget.details.invoice.hashId.isNotEmpty
        ? widget.details.invoice.hashId
        : 'MD-${widget.details.invoice.id}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr(
                    shared.LocaleKeys.invoicePreviewBillTitle,
                    track: shared.TrackConstants.invoicePageTrack,
                  ) ??
                  'Invoice Preview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              receiptNo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_outlined),
            onPressed: _handleShare,
          ),
          IconButton(
            tooltip: 'Download',
            icon: const Icon(Icons.download_rounded),
            onPressed: _handleDownload,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isPrintingNotifier,
            builder: (context, isPrinting, _) {
              return IconButton(
                tooltip: 'Print',
                icon: isPrinting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.print_rounded),
                onPressed: isPrinting ? null : _handleThermalPrint,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Format Picker Segmented Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            child: Row(
              children: [
                Text(
                  'Format:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<InvoicePreviewFormat>(
                    valueListenable: _selectedFormatNotifier,
                    builder: (context, selectedFormat, _) {
                      return SegmentedButton<InvoicePreviewFormat>(
                        segments: const [
                          ButtonSegment<InvoicePreviewFormat>(
                            value: InvoicePreviewFormat.thermal80mm,
                            label: Text('Thermal 80mm'),
                            icon: Icon(Icons.receipt_long_rounded, size: 16),
                          ),
                          ButtonSegment<InvoicePreviewFormat>(
                            value: InvoicePreviewFormat.a4Invoice,
                            label: Text('A4 Document'),
                            icon: Icon(Icons.description_outlined, size: 16),
                          ),
                        ],
                        selected: {selectedFormat},
                        onSelectionChanged: (newSelection) {
                          if (newSelection.isNotEmpty) {
                            _selectedFormatNotifier.value = newSelection.first;
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
          // PDF Display
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isLoadingNotifier,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ValueListenableBuilder<String?>(
                  valueListenable: _errorMessageNotifier,
                  builder: (context, errorMessage, _) {
                    if (errorMessage != null) {
                      return Center(
                        child: Text(
                          'Failed to generate invoice: $errorMessage',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      );
                    }

                    return ListenableBuilder(
                      listenable: Listenable.merge([
                        _selectedFormatNotifier,
                        _thermalBytesNotifier,
                        _thermalFilePathNotifier,
                        _a4BytesNotifier,
                        _a4FilePathNotifier,
                        _isThermalLoadedNotifier,
                        _isA4LoadedNotifier,
                      ]),
                      builder: (context, _) {
                        final selectedFormat = _selectedFormatNotifier.value;
                        final activeBytes =
                            selectedFormat == InvoicePreviewFormat.thermal80mm
                            ? _thermalBytesNotifier.value
                            : _a4BytesNotifier.value;
                        final activeFilePath =
                            selectedFormat == InvoicePreviewFormat.thermal80mm
                            ? _thermalFilePathNotifier.value
                            : _a4FilePathNotifier.value;
                        final isFormatLoaded =
                            selectedFormat == InvoicePreviewFormat.thermal80mm
                            ? _isThermalLoadedNotifier.value
                            : _isA4LoadedNotifier.value;

                        if (!isFormatLoaded) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (activeBytes != null) {
                          return SfPdfViewer.memory(
                            activeBytes,
                            canShowScrollHead: false,
                            canShowScrollStatus: false,
                            onDocumentLoadFailed: (details) {
                              core.PlatformUtils.debugLog(
                                InvoicePdfPreviewScreen,
                                'SfPdfViewer load failed: ${details.error} - ${details.description}',
                              );
                            },
                          );
                        }

                        if (activeFilePath != null) {
                          return SfPdfViewer.file(
                            File(activeFilePath),
                            canShowScrollHead: false,
                            canShowScrollStatus: false,
                            onDocumentLoadFailed: (details) {
                              core.PlatformUtils.debugLog(
                                InvoicePdfPreviewScreen,
                                'SfPdfViewer file load failed: ${details.error} - ${details.description}',
                              );
                            },
                          );
                        }

                        return const Center(
                          child: Text('Failed to load invoice preview.'),
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
