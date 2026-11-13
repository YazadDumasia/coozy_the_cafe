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
  final Uint8List? prebuiltThermalBytes;
  final Uint8List? prebuiltA4Bytes;

  const InvoicePdfPreviewDialog({
    super.key,
    required this.details,
    this.filePath,
    this.prebuiltThermalBytes,
    this.prebuiltA4Bytes,
  });

  @override
  State<InvoicePdfPreviewDialog> createState() =>
      _InvoicePdfPreviewDialogState();
}

class _InvoicePdfPreviewDialogState extends State<InvoicePdfPreviewDialog> {
  final ValueNotifier<Uint8List?> _thermalBytesNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _thermalFilePathNotifier = ValueNotifier(null);
  File? _thermalTempFile;

  final ValueNotifier<Uint8List?> _a4BytesNotifier = ValueNotifier(null);
  final ValueNotifier<String?> _a4FilePathNotifier = ValueNotifier(null);
  File? _a4TempFile;

  final ValueNotifier<bool> _isThermalLoadedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isA4LoadedNotifier = ValueNotifier(false);

  final ValueNotifier<bool> _isDialogTransitionCompletedNotifier =
      ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);
  final ValueNotifier<String?> _errorMessageNotifier = ValueNotifier(null);

  final ValueNotifier<InvoicePreviewFormat> _selectedFormatNotifier =
      ValueNotifier(InvoicePreviewFormat.thermal80mm);
  final ValueNotifier<bool> _isPrintingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          _isDialogTransitionCompletedNotifier.value = true;
        }
      });
    });

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
    _isDialogTransitionCompletedNotifier.dispose();
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
          InvoicePdfPreviewDialog,
          'Error preloading thermal PDF: ',
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
          InvoicePdfPreviewDialog,
          'Error preloading A4 PDF: ',
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
    if (a4Result != null && mounted) {
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
    final tempFile = File(
      '${tempDir.path}${Platform.pathSeparator}cache_preview_invoice_${cleanHash}_${formatSuffix}_$timestamp.pdf',
    );
    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }

  void _onFormatChanged(InvoicePreviewFormat format) {
    if (_selectedFormatNotifier.value == format) return;
    _selectedFormatNotifier.value = format;
    if (format == InvoicePreviewFormat.a4Invoice &&
        !_isA4LoadedNotifier.value) {
      _isLoadingNotifier.value = true;
    } else if (format == InvoicePreviewFormat.thermal80mm &&
        !_isThermalLoadedNotifier.value) {
      _isLoadingNotifier.value = true;
    } else {
      _isLoadingNotifier.value = false;
    }
  }

  void _deleteCachedFiles() {
    final filesToDelete = <File>[];
    if (_thermalTempFile != null) filesToDelete.add(_thermalTempFile!);
    if (_a4TempFile != null) filesToDelete.add(_a4TempFile!);
    _thermalTempFile = null;
    _a4TempFile = null;

    if (kIsWeb || filesToDelete.isEmpty) return;
    Future.microtask(() async {
      for (final f in filesToDelete) {
        try {
          if (await f.exists()) {
            await f.delete();
          }
        } catch (_) {}
      }
    });
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
              bytes: _thermalBytesNotifier.value,
            );
          }
        }
      } else {
        await InvoicePdfGenerator.printPdf(
          details: widget.details,
          bytes: _thermalBytesNotifier.value,
        );
      }
    } catch (e) {
      if (mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to print thermal receipt: $e',
        );
      }
    } finally {
      if (mounted) {
        _isPrintingNotifier.value = false;
      }
    }
  }

  void _copySummary() {
    InvoiceShareService.instance.buildShareMessage(widget.details).then((
      summary,
    ) {
      Clipboard.setData(ClipboardData(text: summary));
      if (mounted) {
        shared.SnackBarUtils.showSuccess(
          context,
          message: 'Invoice summary copied to clipboard',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = shared.ResponsiveLayout.isMobile(context);
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);
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

    return Dialog(
      insetPadding: isDesktop
          ? EdgeInsets.symmetric(
              horizontal: (size.width * 0.12).clamp(16.0, 160.0),
              vertical: (size.height * 0.05).clamp(16.0, 60.0),
            )
          : isTablet
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          : EdgeInsets.zero,
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          isDesktop ? 20 : (isTablet ? 12 : 0),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: isDesktop ? null : (isTablet ? size.width * 0.94 : size.width),
        height: isMobile ? size.height : null,
        child: Column(
          children: [
            // TOP HEADER
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 20,
                vertical: isMobile ? 10 : 14,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      )
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: isDark ? 0.4 : 0.8,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Segmented format toggle (Thermal vs A4)
                  ValueListenableBuilder<InvoicePreviewFormat>(
                    valueListenable: _selectedFormatNotifier,
                    builder: (context, selectedFormat, _) {
                      return Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.5,
                                )
                              : const Color(0xFFF1F3F6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFormatToggleItem(
                              context: context,
                              label: 'Thermal 80mm',
                              isSelected:
                                  selectedFormat ==
                                  InvoicePreviewFormat.thermal80mm,
                              onTap: () => _onFormatChanged(
                                InvoicePreviewFormat.thermal80mm,
                              ),
                            ),
                            const SizedBox(width: 2),
                            _buildFormatToggleItem(
                              context: context,
                              label: 'A4 Document',
                              isSelected:
                                  selectedFormat ==
                                  InvoicePreviewFormat.a4Invoice,
                              onTap: () => _onFormatChanged(
                                InvoicePreviewFormat.a4Invoice,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  // System Print button
                  OutlinedButton.icon(
                    onPressed: () {
                      final selectedFormat = _selectedFormatNotifier.value;
                      final activeBytes =
                          selectedFormat == InvoicePreviewFormat.thermal80mm
                          ? _thermalBytesNotifier.value
                          : _a4BytesNotifier.value;
                      InvoicePdfGenerator.printPdf(
                        details: widget.details,
                        bytes: activeBytes,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.print_rounded, size: 16),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.invoiceActionPrint,
                            track: shared.TrackConstants.invoicePageTrack,
                          ) ??
                          'Print',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
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
            // VIEWER BODY
            Expanded(
              child: Container(
                color: isDark
                    ? colorScheme.surfaceContainerLowest
                    : const Color(0xFFF7F8FA),
                width: double.infinity,
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isDialogTransitionCompletedNotifier,
                  builder: (context, isDialogTransitionCompleted, _) {
                    if (!isDialogTransitionCompleted) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ValueListenableBuilder<bool>(
                      valueListenable: _isLoadingNotifier,
                      builder: (context, isLoading, _) {
                        if (isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ValueListenableBuilder<String?>(
                          valueListenable: _errorMessageNotifier,
                          builder: (context, errorMessage, _) {
                            if (errorMessage != null) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        size: 48,
                                        color: colorScheme.error,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Failed to load invoice preview',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        errorMessage,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
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
                              );
                            }

                            return ListenableBuilder(
                              listenable: Listenable.merge([
                                _selectedFormatNotifier,
                                _thermalBytesNotifier,
                                _thermalFilePathNotifier,
                                _a4BytesNotifier,
                                _a4FilePathNotifier,
                              ]),
                              builder: (context, _) {
                                final selectedFormat =
                                    _selectedFormatNotifier.value;
                                final activeBytes =
                                    selectedFormat ==
                                        InvoicePreviewFormat.thermal80mm
                                    ? _thermalBytesNotifier.value
                                    : _a4BytesNotifier.value;
                                final activeFilePath =
                                    selectedFormat ==
                                        InvoicePreviewFormat.thermal80mm
                                    ? _thermalFilePathNotifier.value
                                    : _a4FilePathNotifier.value;

                                return Center(
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          selectedFormat ==
                                              InvoicePreviewFormat.thermal80mm
                                          ? 440
                                          : double.infinity,
                                    ),
                                    margin: EdgeInsets.all(
                                      isMobile ? 8.0 : 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
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
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // BOTTOM FOOTER
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 20,
                vertical: isMobile ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      )
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
                  OutlinedButton.icon(
                    onPressed: _copySummary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.8,
                        ),
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
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
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
                    child: Text(
                      'Close',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isPrintingNotifier,
                    builder: (context, isPrinting, _) {
                      return FilledButton.icon(
                        onPressed: isPrinting ? null : _handleThermalPrint,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary,
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
                        icon: isPrinting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.print_rounded, size: 17),
                        label: Text(
                          context.tr(
                                shared.LocaleKeys.invoicePrintThermalReceipt,
                                track: shared.TrackConstants.invoicePageTrack,
                              ) ??
                              'Print Thermal Receipt',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
            style: theme.textTheme.labelMedium?.copyWith(
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
