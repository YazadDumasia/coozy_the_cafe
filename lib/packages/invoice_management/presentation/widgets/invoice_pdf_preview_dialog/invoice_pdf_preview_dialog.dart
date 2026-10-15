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
import '../../../domain/services/invoice_share_service.dart';

enum InvoicePreviewFormat { thermal80mm, a4Invoice }

class InvoicePdfPreviewDialog extends StatefulWidget {
  final InvoiceDetailsEntity details;
  final String? filePath;

  const InvoicePdfPreviewDialog({
    super.key,
    required this.details,
    this.filePath,
  });

  @override
  State<InvoicePdfPreviewDialog> createState() =>
      _InvoicePdfPreviewDialogState();
}

class _InvoicePdfPreviewDialogState extends State<InvoicePdfPreviewDialog> {
  // Preloaded data for both formats
  Uint8List? _thermalBytes;
  String? _thermalFilePath;
  File? _thermalTempFile;

  Uint8List? _a4Bytes;
  String? _a4FilePath;
  File? _a4TempFile;

  bool _isThermalLoaded = false;
  bool _isA4Loaded = false;

  bool _isDialogTransitionCompleted = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Selected format toggle (Default: Thermal 80mm)
  InvoicePreviewFormat _selectedFormat = InvoicePreviewFormat.thermal80mm;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    // Wait for the modal dialog entrance transition to complete smoothly
    // before presenting the heavy SfPdfViewer rendering to prevent the dialog from sticking
    // in semi-transparent animation phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(() {
            _isDialogTransitionCompleted = true;
          });
        }
      });
    });

    _preloadAllFormats();
  }

  @override
  void dispose() {
    _deleteCachedFiles();
    super.dispose();
  }

  /// Preloads both Thermal 80mm and A4 in the background simultaneously
  Future<void> _preloadAllFormats() async {
    _cleanupOldCachedFiles();

    // 1. Preload Thermal 80mm
    final thermalFuture = () async {
      try {
        if (!kIsWeb &&
            widget.filePath != null &&
            widget.filePath!.isNotEmpty) {
          final file = File(widget.filePath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            return (bytes: bytes, path: file.path, tempFile: null as File?);
          }
        }

        final bytes = await InvoicePdfGenerator.generatePdf(
          details: widget.details,
          isA4Format: false,
          is58mm: false,
        );

        if (!kIsWeb) {
          final tempFile = await _writeTempPdf(bytes: bytes, formatSuffix: 'thermal80');
          return (bytes: bytes, path: tempFile.path, tempFile: tempFile);
        } else {
          return (bytes: bytes, path: null as String?, tempFile: null as File?);
        }
      } catch (e) {
        core.PlatformUtils.debugLog(
          InvoicePdfPreviewDialog,
          'Error preloading thermal PDF: $e',
        );
        rethrow;
      }
    }();

    // 2. Preload A4 in the background
    final a4Future = () async {
      try {
        final bytes = await InvoicePdfGenerator.generatePdf(
          details: widget.details,
          isA4Format: true,
          is58mm: false,
        );

        if (!kIsWeb) {
          final tempFile = await _writeTempPdf(bytes: bytes, formatSuffix: 'a4');
          return (bytes: bytes, path: tempFile.path, tempFile: tempFile);
        } else {
          return (bytes: bytes, path: null as String?, tempFile: null as File?);
        }
      } catch (e) {
        core.PlatformUtils.debugLog(
          InvoicePdfPreviewDialog,
          'Error preloading A4 PDF: $e',
        );
        return null;
      }
    }();

    // Handle thermal completion (primary initial view)
    try {
      final thermalResult = await thermalFuture;
      if (mounted) {
        setState(() {
          _thermalBytes = thermalResult.bytes;
          _thermalFilePath = thermalResult.path;
          _thermalTempFile = thermalResult.tempFile;
          _isThermalLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }

    // Handle A4 completion in background without blocking initial thermal view
    final a4Result = await a4Future;
    if (a4Result != null && mounted) {
      setState(() {
        _a4Bytes = a4Result.bytes;
        _a4FilePath = a4Result.path;
        _a4TempFile = a4Result.tempFile;
        _isA4Loaded = true;
      });
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
    final tempFile = File(
      '${tempDir.path}${Platform.pathSeparator}cache_preview_invoice_${cleanHash}_${formatSuffix}_$timestamp.pdf',
    );
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }

  void _onFormatChanged(InvoicePreviewFormat format) {
    if (_selectedFormat == format) return;
    setState(() {
      _selectedFormat = format;
      if (format == InvoicePreviewFormat.a4Invoice && !_isA4Loaded) {
        _isLoading = true;
      } else if (format == InvoicePreviewFormat.thermal80mm && !_isThermalLoaded) {
        _isLoading = true;
      } else {
        _isLoading = false;
      }
    });
  }

  void _deleteCachedFiles() {
    final filesToDelete = <File>[];
    if (_thermalTempFile != null) filesToDelete.add(_thermalTempFile!);
    if (_a4TempFile != null) filesToDelete.add(_a4TempFile!);
    _thermalTempFile = null;
    _a4TempFile = null;
    _thermalFilePath = null;
    _a4FilePath = null;

    if (filesToDelete.isEmpty) return;

    Future.delayed(const Duration(milliseconds: 300), () async {
      for (final file in filesToDelete) {
        for (int attempt = 1; attempt <= 3; attempt++) {
          try {
            if (await file.exists()) {
              await file.delete();
              core.PlatformUtils.debugLog(
                InvoicePdfPreviewDialog,
                'Auto-deleted cached preview PDF: ${file.path}',
              );
            }
            break;
          } catch (e) {
            core.PlatformUtils.debugLog(
              InvoicePdfPreviewDialog,
              'Attempt $attempt to auto-delete cached preview PDF failed ($e), retrying...',
            );
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }
      }
    });
  }

  static Future<void> _cleanupOldCachedFiles() async {
    if (kIsWeb) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      if (await dir.exists()) {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File &&
              entity.path.contains('cache_preview_invoice_')) {
            try {
              await entity.delete();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _copySummary() async {
    final summary = await InvoiceShareService.instance.buildShareMessage(widget.details);
    await Clipboard.setData(ClipboardData(text: summary));
    if (mounted) {
      shared.SnackBarUtils.showSuccess(
        context,
        message: 'Invoice summary copied to clipboard!',
      );
    }
  }

  Future<void> _handleThermalPrint() async {
    if (_isPrinting) return;
    setState(() => _isPrinting = true);
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
              bytes: _thermalBytes,
            );
          }
        }
      } else {
        await InvoicePdfGenerator.printPdf(
          details: widget.details,
          bytes: _thermalBytes,
        );
      }
    } catch (e) {
      if (mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Error printing receipt: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = shared.ResponsiveLayout.isMobile(context);
    final size = MediaQuery.of(context).size;

    final receiptNo = widget.details.invoice.hashId.isNotEmpty
        ? widget.details.invoice.hashId
        : 'MD-${widget.details.invoice.id}';
    final customerName = widget.details.invoice.customerName?.isNotEmpty == true
        ? widget.details.invoice.customerName!
        : (widget.details.tableName != null &&
                  widget.details.tableName!.isNotEmpty
              ? widget.details.tableName!
              : 'Walk-in');

    final activeBytes = _selectedFormat == InvoicePreviewFormat.thermal80mm
        ? _thermalBytes
        : _a4Bytes;
    final activeFilePath = _selectedFormat == InvoicePreviewFormat.thermal80mm
        ? _thermalFilePath
        : _a4FilePath;
    final isCurrentFormatLoaded = _selectedFormat == InvoicePreviewFormat.thermal80mm
        ? _isThermalLoaded
        : _isA4Loaded;

    final hasPdf = activeBytes != null || activeFilePath != null;

    return Dialog(
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 16)
          : EdgeInsets.symmetric(
              horizontal: (size.width * 0.12).clamp(16.0, 160.0),
              vertical: (size.height * 0.05).clamp(16.0, 60.0),
            ),
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ==========================================
          // TOP HEADER HIGHLIGHT PART
          // ==========================================
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 20,
              vertical: isMobile ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                  : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // 1. Icon badge - Seamlessly adapts to primary/surface theme
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: isDark ? 0.4 : 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: isDark ? colorScheme.primary : colorScheme.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Title & Subtitle (Bill & Invoice Preview | HashId • Customer)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr(
                              shared.LocaleKeys.invoicePreviewBillTitle,
                              track: shared.TrackConstants.invoicePageTrack,
                            ) ??
                            'Bill & Invoice Preview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 15 : 17,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$receiptNo • $customerName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 11.5 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Segmented Format Switch: [ Thermal (80mm) | A4 Invoice ]
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHighest
                        : const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(3.5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFormatToggleItem(
                        context: context,
                        label:
                            context.tr(
                              shared.LocaleKeys.invoicePreviewThermal80mm,
                              track: shared.TrackConstants.invoicePageTrack,
                            ) ??
                            'Thermal (80mm)',
                        isSelected:
                            _selectedFormat == InvoicePreviewFormat.thermal80mm,
                        onTap: () =>
                            _onFormatChanged(InvoicePreviewFormat.thermal80mm),
                      ),
                      _buildFormatToggleItem(
                        context: context,
                        label:
                            context.tr(
                              shared.LocaleKeys.invoicePreviewA4,
                              track: shared.TrackConstants.invoicePageTrack,
                            ) ??
                            'A4 Invoice',
                        isSelected:
                            _selectedFormat == InvoicePreviewFormat.a4Invoice,
                        onTap: () =>
                            _onFormatChanged(InvoicePreviewFormat.a4Invoice),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // 4. Quick Print Button (Solid pill button with print icon)
                FilledButton.icon(
                  onPressed: hasPdf
                      ? () => InvoicePdfGenerator.printPdf(
                          details: widget.details,
                          bytes: activeBytes,
                        )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark
                        ? colorScheme.primaryContainer
                        : colorScheme.primary,
                    foregroundColor: isDark
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    visualDensity: VisualDensity.compact,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.invoiceActionPrint,
                          track: shared.TrackConstants.invoicePageTrack,
                        ) ??
                        'Print',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // 5. Close icon button (X)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  splashRadius: 20,
                  color: colorScheme.onSurfaceVariant,
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // ==========================================
          // CENTER PREVIEW CONTAINER
          // ==========================================
          Expanded(
            child: Container(
              color: isDark
                  ? colorScheme.surfaceContainerLowest
                  : const Color(0xFFF3F5F8),
              child: (_isLoading || !isCurrentFormatLoaded || !_isDialogTransitionCompleted)
                  ? const Center(child: shared.LoadingPage(isEmbedded: true))
                  : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.invoicePreviewError,
                                    track:
                                        shared.TrackConstants.invoicePageTrack,
                                  ) ??
                                  'Failed to load invoice preview',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonalIcon(
                              onPressed: () => _preloadAllFormats(),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              _selectedFormat ==
                                  InvoicePreviewFormat.thermal80mm
                              ? 440
                              : double.infinity,
                        ),
                        margin: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: activeFilePath != null
                            ? SfPdfViewer.file(
                                File(activeFilePath),
                                canShowScrollHead: false,
                                canShowScrollStatus: false,
                              )
                            : activeBytes != null
                            ? SfPdfViewer.memory(
                                activeBytes,
                                canShowScrollHead: false,
                                canShowScrollStatus: false,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
            ),
          ),

          // ==========================================
          // BOTTOM FOOTER HIGHLIGHT PART
          // ==========================================
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 20,
              vertical: isMobile ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                  : Colors.white,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // 1. Left: Copy Summary Outlined Button
                OutlinedButton.icon(
                  onPressed: _copySummary,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                      width: 1,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.invoiceCopySummary,
                          track: shared.TrackConstants.invoicePageTrack,
                        ) ??
                        'Copy Summary',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),

                const Spacer(),

                // 2. Center/Right: Close text button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 3. Right: Golden / Amber "Print Thermal Receipt" Pill Button
                FilledButton.icon(
                  onPressed: _isPrinting ? null : _handleThermalPrint,
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.6),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 20,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: _isPrinting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.print_rounded, size: 17),
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.invoicePrintThermalReceipt,
                          track: shared.TrackConstants.invoicePageTrack,
                        ) ??
                        'Print Thermal Receipt',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatToggleItem({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? theme.colorScheme.primaryContainer : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark
                        ? theme.colorScheme.onPrimaryContainer
                        : const Color(0xFF1E2432))
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
