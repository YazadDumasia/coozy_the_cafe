import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/table_info.dart';
import '../../../domain/services/table_qr_pdf_generator.dart';

class TableQrDialog extends StatefulWidget {
  final TableInfo? table;
  final List<TableInfo>? tables;

  const TableQrDialog({super.key, this.table, this.tables})
    : assert(
        table != null || tables != null,
        'Either table or tables must be provided',
      );

  @override
  State<TableQrDialog> createState() => _TableQrDialogState();
}

class _TableQrDialogState extends State<TableQrDialog> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  int _selectedColumns = 2;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
    });

    // Yield execution to UI frame so CircularProgressIndicator starts spinning fluidly
    await Future.delayed(const Duration(milliseconds: 30));

    try {
      final List<TableInfo> targetTables =
          widget.table != null
              ? [widget.table!]
              : (widget.tables ?? <TableInfo>[]);

      final bytes = await TableQrPdfGenerator.generatePdf(
        tables: targetTables,
        singleTable: widget.table,
        columnsCount: _selectedColumns,
      );

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      core.PlatformUtils.debugLog(
        TableQrDialog,
        'Error generating PDF: $e\n$stack',
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
    final bool isSingle = widget.table != null;
    final String tableNoDisplay =
        isSingle
            ? (widget.table!.tableNo?.isNotEmpty == true
                ? widget.table!.tableNo!
                : (widget.table!.id != null ? '${widget.table!.id}' : '1'))
            : 'All';

    final String titleText =
        isSingle
            ? (context.tr(
                  shared.LocaleKeys.tableQrDialogTitle,
                  params: {'tableNo': tableNoDisplay},
                  track: shared.TrackConstants.tablePageTrack,
                ) ??
                'Table $tableNoDisplay QR Card')
            : 'All Tables QR Cards PDF';

    final now = DateTime.now();
    final String timeStampStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';

    final String docName =
        isSingle
            ? 'Table_${tableNoDisplay}_QR_Card_$timeStampStr.pdf'
            : 'Coozy_All_Table_QR_Cards_$timeStampStr.pdf';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 780,
        constraints: const BoxConstraints(maxHeight: 740),
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
                      Icons.qr_code_2_rounded,
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

            // Column Count Selector (Only for multi-table preview)
            if (!isSingle) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                          _loadPdf();
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
              const SizedBox(height: 12),
            ],
            const Divider(height: 12),

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
                              'Failed to render QR Card PDF preview',
                        ),
                      ),
            ),
            const SizedBox(height: 16),

            // Action Buttons: Close, Download, Print
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
                      final List<TableInfo> targetTables =
                          widget.table != null
                              ? [widget.table!]
                              : (widget.tables ?? <TableInfo>[]);

                      await TableQrPdfGenerator.downloadOrSavePdf(
                        tables: targetTables,
                        singleTable: widget.table,
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
                      final List<TableInfo> targetTables =
                          widget.table != null
                              ? [widget.table!]
                              : (widget.tables ?? <TableInfo>[]);

                      await TableQrPdfGenerator.printOrShareTableCards(
                        tables: targetTables,
                        singleTable: widget.table,
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
                  label: Text(
                    context.tr(
                          shared.LocaleKeys.printTableQrCardsTooltip,
                          track: shared.TrackConstants.tablePageTrack,
                        ) ??
                        'Print Card PDF',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
