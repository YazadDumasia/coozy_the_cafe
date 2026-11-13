import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../domain/entities/table_info.dart';
import '../../../domain/services/table_qr_pdf_generator.dart';

class TableQrDialog extends StatefulWidget {
  final TableInfo? table;
  final List<TableInfo>? tables;
  final Uint8List? prebuiltPdfBytes;
  final Map<int, Uint8List>? prebuiltColumnsPdfBytes;

  const TableQrDialog({
    super.key,
    this.table,
    this.tables,
    this.prebuiltPdfBytes,
    this.prebuiltColumnsPdfBytes,
  }) : assert(
         table != null || tables != null,
         'Either table or tables must be provided',
       );

  @override
  State<TableQrDialog> createState() => _TableQrDialogState();
}

class _TableQrDialogState extends State<TableQrDialog> {
  final ValueNotifier<Uint8List?> _pdfBytesNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isSharingNotifier = ValueNotifier(false);
  final ValueNotifier<int> _selectedColumnsNotifier = ValueNotifier(2);

  late final Map<int, Uint8List> _columnCache;
  bool _cancelled = false;
  int _generationId = 0;

  @override
  void initState() {
    super.initState();
    _columnCache = <int, Uint8List>{};
    if (widget.table == null) {
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
    super.dispose();
  }

  Future<void> _loadPdf() async {
    final int myGeneration = ++_generationId;

    if (!mounted || _cancelled) return;
    _isLoadingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 60));
    if (_cancelled || _generationId != myGeneration) return;

    try {
      final List<TableInfo> targetTables = widget.table != null
          ? [widget.table!]
          : (widget.tables ?? <TableInfo>[]);

      final bytes = await TableQrPdfGenerator.generatePdf(
        tables: targetTables,
        singleTable: widget.table,
        columnsCount: _selectedColumnsNotifier.value,
      );

      if (_cancelled || _generationId != myGeneration || !mounted) return;

      _columnCache[_selectedColumnsNotifier.value] = bytes;
      _pdfBytesNotifier.value = bytes;
      _isLoadingNotifier.value = false;
    } catch (e, stack) {
      core.PlatformUtils.debugLog(
        TableQrDialog,
        'Error generating PDF: $e\n$stack',
      );
      if (!_cancelled && _generationId == myGeneration && mounted) {
        _isLoadingNotifier.value = false;
      }
    }
  }

  String _buildDocName() {
    final bool isSingle = widget.table != null;
    final String tableNoDisplay = isSingle
        ? (widget.table!.tableNo?.isNotEmpty == true
              ? widget.table!.tableNo!
              : (widget.table!.id != null ? '${widget.table!.id}' : '1'))
        : 'All';

    final now = DateTime.now();
    final String timeStampStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';

    return isSingle
        ? 'Table_${tableNoDisplay}_QR_Card_$timeStampStr.pdf'
        : 'Coozy_All_Table_QR_Cards_$timeStampStr.pdf';
  }

  Future<void> _handleShare(String docName) async {
    if (_isSavingNotifier.value ||
        _isSharingNotifier.value ||
        _isLoadingNotifier.value) {
      return;
    }
    _isSharingNotifier.value = true;
    try {
      final List<TableInfo> targetTables = widget.table != null
          ? [widget.table!]
          : (widget.tables ?? <TableInfo>[]);

      await TableQrPdfGenerator.sharePdf(
        tables: targetTables,
        singleTable: widget.table,
        columnsCount: _selectedColumnsNotifier.value,
        docName: docName,
      );
    } catch (e) {
      if (mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to share PDF: $e',
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
      final List<TableInfo> targetTables = widget.table != null
          ? [widget.table!]
          : (widget.tables ?? <TableInfo>[]);

      final result = await TableQrPdfGenerator.downloadOrSavePdf(
        tables: targetTables,
        singleTable: widget.table,
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
      final List<TableInfo> targetTables = widget.table != null
          ? [widget.table!]
          : (widget.tables ?? <TableInfo>[]);

      await TableQrPdfGenerator.printOrShareTableCards(
        tables: targetTables,
        singleTable: widget.table,
        columnsCount: _selectedColumnsNotifier.value,
        docName: docName,
      );
    } catch (e) {
      if (mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to print PDF: $e',
        );
      }
    }
  }

  void _onColumnChanged(int newCol) {
    if (newCol == _selectedColumnsNotifier.value) return;
    _selectedColumnsNotifier.value = newCol;
    if (_columnCache.containsKey(newCol)) {
      _pdfBytesNotifier.value = _columnCache[newCol];
      _isLoadingNotifier.value = false;
    } else {
      _pdfBytesNotifier.value = null;
      _isLoadingNotifier.value = true;
      _loadPdf();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSingle = widget.table != null;
    final String tableNoDisplay = isSingle
        ? (widget.table!.tableNo?.isNotEmpty == true
              ? widget.table!.tableNo!
              : (widget.table!.id != null ? '${widget.table!.id}' : '1'))
        : 'All';

    final String titleText = isSingle
        ? (context.tr(
                shared.LocaleKeys.tableQrDialogTitle,
                params: {'tableNo': tableNoDisplay},
                track: shared.TrackConstants.tablePageTrack,
              ) ??
              'Table $tableNoDisplay QR Card')
        : 'All Tables QR Cards PDF';

    final docName = _buildDocName();

    return ListenableBuilder(
      listenable: Listenable.merge([
        _pdfBytesNotifier,
        _isLoadingNotifier,
        _isSavingNotifier,
        _isSharingNotifier,
        _selectedColumnsNotifier,
      ]),
      builder: (context, _) {
        return shared.AdaptivePdfPreviewScaffold(
          title: titleText,
          leadingIcon: Icon(
            Icons.qr_code_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          isLoading: _isLoadingNotifier.value,
          isSaving: _isSavingNotifier.value,
          isSharing: _isSharingNotifier.value,
          onShare: () => _handleShare(docName),
          onSave: () => _handleDownloadOrSave(docName),
          onPrint: () => _handlePrint(docName),
          subHeader: !isSingle
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      shared.PdfColumnSelector(
                        selectedColumns: _selectedColumnsNotifier.value,
                        onColumnChanged: _onColumnChanged,
                      ),
                    ],
                  ),
                )
              : null,
          body: shared.PdfViewerViewport(
            pdfBytes: _pdfBytesNotifier.value,
            isLoading: _isLoadingNotifier.value,
            errorMessage: context.tr(
              shared.LocaleKeys.commonErrorMsg,
              track: shared.TrackConstants.commonTrack,
            ),
          ),
        );
      },
    );
  }
}
