import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/invoice_management_entity.dart';
import '../../../domain/services/invoice_pdf_generator.dart';

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
  Uint8List? _pdfBytes;
  File? _cachedTempFile;
  String? _cachedFilePath;
  bool _isTemporaryCache = false;
  bool _isLoading = true;
  String? _errorMessage;
  static int _docCounter = 0;
  late final String _sourceName;

  @override
  void initState() {
    super.initState();
    _sourceName = 'invoice_pdf_preview_${++_docCounter}';
    _loadPdf();
  }

  @override
  void dispose() {
    _deleteCachedFile();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    try {
      // 1. If an existing permanent file was provided, load directly without marking as temporary
      if (!kIsWeb && widget.filePath != null && widget.filePath!.isNotEmpty) {
        final file = File(widget.filePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (mounted) {
            setState(() {
              _pdfBytes = bytes;
              _cachedFilePath = file.path;
              _isTemporaryCache = false;
              _isLoading = false;
            });
            return;
          }
        }
      }

      // 2. Clean up any leftover preview cache files from previous sessions
      _cleanupOldCachedFiles();

      // 3. Generate PDF binary data
      final bytes = await InvoicePdfGenerator.generatePdf(
        details: widget.details,
      );

      // 4. Save to temporary cache on native platforms
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        final cleanHash = widget.details.invoice.hashId.isNotEmpty
            ? widget.details.invoice.hashId.replaceAll(RegExp(r'[^\w\-]'), '_')
            : '${widget.details.invoice.id}';
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final tempFile = File(
          '${tempDir.path}${Platform.pathSeparator}cache_preview_invoice_${cleanHash}_$timestamp.pdf',
        );
        await tempFile.writeAsBytes(bytes, flush: true);

        core.PlatformUtils.debugLog(
          InvoicePdfPreviewDialog,
          'Cached preview PDF written to: ${tempFile.path}',
        );

        if (mounted) {
          setState(() {
            _pdfBytes = bytes;
            _cachedTempFile = tempFile;
            _cachedFilePath = tempFile.path;
            _isTemporaryCache = true;
            _isLoading = false;
          });
        }
      } else {
        // Web: keep in memory
        if (mounted) {
          setState(() {
            _pdfBytes = bytes;
            _isTemporaryCache = false;
            _isLoading = false;
          });
        }
      }
    } catch (e, stack) {
      core.PlatformUtils.debugLog(
        InvoicePdfPreviewDialog,
        'Error loading PDF preview: $e\n$stack',
      );
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _deleteCachedFile() {
    if (_isTemporaryCache && _cachedTempFile != null) {
      final fileToDelete = _cachedTempFile!;
      _cachedTempFile = null;
      _cachedFilePath = null;

      // Allow PdfViewer / pdfium to cleanly release the native file handle before unlinking
      Future.delayed(const Duration(milliseconds: 300), () async {
        for (int attempt = 1; attempt <= 3; attempt++) {
          try {
            if (await fileToDelete.exists()) {
              await fileToDelete.delete();
              core.PlatformUtils.debugLog(
                InvoicePdfPreviewDialog,
                'Auto-deleted cached preview PDF: ${fileToDelete.path}',
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
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = shared.ResponsiveLayout.isMobile(context);
    final size = MediaQuery.of(context).size;

    final receiptNo = widget.details.invoice.hashId.isNotEmpty
        ? widget.details.invoice.hashId
        : 'MD-${widget.details.invoice.id}';

    final hasPdf = _pdfBytes != null || _cachedFilePath != null;

    return Dialog(
      insetPadding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 24)
          : EdgeInsets.symmetric(
              horizontal: size.width * 0.15,
              vertical: size.height * 0.08,
            ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(
                                shared.LocaleKeys.invoicePreviewTitle,
                                track: shared.TrackConstants.invoicePageTrack,
                              ) ??
                              'Invoice Receipt',
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
                  ),
                  IconButton(
                    icon: const Icon(Icons.print_outlined),
                    tooltip: context.tr(
                          shared.LocaleKeys.invoiceActionPrint,
                          track: shared.TrackConstants.invoicePageTrack,
                        ) ??
                        'Print',
                    onPressed: hasPdf
                        ? () => InvoicePdfGenerator.printPdf(
                              details: widget.details,
                              bytes: _pdfBytes,
                            )
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: context.tr(
                          shared.LocaleKeys.invoiceActionShare,
                          track: shared.TrackConstants.invoicePageTrack,
                        ) ??
                        'Share',
                    onPressed: hasPdf
                        ? () => InvoicePdfGenerator.sharePdf(
                              details: widget.details,
                              filePath: _cachedFilePath,
                              bytes: _pdfBytes,
                            )
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content Viewer
            Expanded(
              child: _isLoading
                  ? const Center(child: shared.LoadingPage())
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
                                        track: shared.TrackConstants.invoicePageTrack,
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
                              ],
                            ),
                          ),
                        )
                      : _cachedFilePath != null
                          ? Container(
                              color: colorScheme.surface,
                              child: PdfViewer.file(
                                _cachedFilePath!,
                              ),
                            )
                          : _pdfBytes != null
                              ? Container(
                                  color: colorScheme.surface,
                                  child: PdfViewer.data(
                                    _pdfBytes!,
                                    sourceName: _sourceName,
                                  ),
                                )
                              : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
