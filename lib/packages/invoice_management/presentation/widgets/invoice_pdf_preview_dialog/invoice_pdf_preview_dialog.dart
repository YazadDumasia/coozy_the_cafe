import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  bool _isLoading = true;
  String? _errorMessage;
  static int _docCounter = 0;
  late final String _sourceName;

  @override
  void initState() {
    super.initState();
    _sourceName = 'invoice_pdf_preview_${++_docCounter}';
    _loadPdfBytes();
  }

  Future<void> _loadPdfBytes() async {
    try {
      if (!kIsWeb && widget.filePath != null) {
        final file = File(widget.filePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (mounted) {
            setState(() {
              _pdfBytes = bytes;
              _isLoading = false;
            });
            return;
          }
        }
      }

      final bytes = await InvoicePdfGenerator.generatePdf(
        details: widget.details,
      );
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = shared.ResponsiveLayout.isMobile(context);
    final size = MediaQuery.of(context).size;

    final receiptNo = widget.details.invoice.hashId.isNotEmpty
        ? widget.details.invoice.hashId
        : 'MD-${widget.details.invoice.id}';

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
                    tooltip: 'Print',
                    onPressed: _pdfBytes != null
                        ? () => InvoicePdfGenerator.printPdf(
                              details: widget.details,
                            )
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: 'Share',
                    onPressed: _pdfBytes != null
                        ? () => InvoicePdfGenerator.sharePdf(
                              details: widget.details,
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
