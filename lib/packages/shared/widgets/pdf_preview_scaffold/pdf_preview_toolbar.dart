import 'package:flutter/material.dart';

class PdfPreviewToolbar extends StatelessWidget {
  final VoidCallback? onPrint;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool isSaving;
  final bool isSharing;
  final bool isLoading;
  final String saveTooltip;
  final String shareTooltip;
  final String printTooltip;
  final List<Widget>? customActions;

  const PdfPreviewToolbar({
    super.key,
    this.onPrint,
    this.onSave,
    this.onShare,
    this.isSaving = false,
    this.isSharing = false,
    this.isLoading = false,
    this.saveTooltip = 'Save / Download PDF',
    this.shareTooltip = 'Share PDF',
    this.printTooltip = 'Print PDF',
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...?customActions,
        if (onShare != null)
          IconButton(
            tooltip: shareTooltip,
            icon: isSharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share_rounded),
            onPressed: (isSaving || isSharing || isLoading) ? null : onShare,
          ),
        if (onSave != null)
          IconButton(
            tooltip: saveTooltip,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
            onPressed: (isSaving || isSharing || isLoading) ? null : onSave,
          ),
        if (onPrint != null)
          IconButton(
            tooltip: printTooltip,
            icon: const Icon(Icons.print_rounded),
            onPressed: (isSaving || isSharing || isLoading) ? null : onPrint,
          ),
      ],
    );
  }
}
