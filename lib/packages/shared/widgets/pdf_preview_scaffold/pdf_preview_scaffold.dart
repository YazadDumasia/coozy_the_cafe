import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import 'pdf_preview_toolbar.dart';

class AdaptivePdfPreviewScaffold extends StatelessWidget {
  final String title;
  final Widget? leadingIcon;
  final Widget body;
  final VoidCallback? onPrint;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final bool isSaving;
  final bool isSharing;
  final bool isLoading;
  final List<Widget>? customActions;
  final Widget? subHeader;

  const AdaptivePdfPreviewScaffold({
    super.key,
    required this.title,
    this.leadingIcon,
    required this.body,
    this.onPrint,
    this.onSave,
    this.onShare,
    this.isSaving = false,
    this.isSharing = false,
    this.isLoading = false,
    this.customActions,
    this.subHeader,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);
    final isMobile = shared.ResponsiveLayout.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final toolbar = PdfPreviewToolbar(
      onPrint: onPrint,
      onSave: onSave,
      onShare: onShare,
      isSaving: isSaving,
      isSharing: isSharing,
      isLoading: isLoading,
      customActions: customActions,
    );

    // 1. Mobile form factor: full-screen Scaffold
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [toolbar],
        ),
        body: Column(
          children: [
            ...?subHeader != null ? [subHeader!] : null,
            Expanded(child: body),
          ],
        ),
      );
    }

    // 2. Tablet form factor in Landscape orientation: side-by-side controls & PDF viewer
    if (isTablet && isLandscape) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          width: screenSize.width * 0.92,
          height: screenSize.height * 0.92,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tablet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (leadingIcon != null) ...[
                          leadingIcon!,
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Control Sidebar (Toolbar & SubHeader)
                    Container(
                      width: 260,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.35,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Actions & Controls',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [toolbar],
                          ),
                          if (subHeader != null) ...[
                            const Divider(height: 24),
                            subHeader!,
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right PDF Viewer
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Tablet Portrait & Desktop form factors: centered responsive Dialog with stacked layout
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
      ),
      backgroundColor: colorScheme.surface,
      insetPadding: isDesktop
          ? const EdgeInsets.symmetric(horizontal: 40, vertical: 28)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: isDesktop ? screenSize.width * 0.80 : screenSize.width * 0.90,
        constraints: BoxConstraints(
          maxHeight: isDesktop
              ? screenSize.height * 0.85
              : screenSize.height * 0.90,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (leadingIcon != null) ...[
                        leadingIcon!,
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style:
                              (isDesktop
                                      ? theme.textTheme.titleLarge
                                      : theme.textTheme.titleMedium)
                                  ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                toolbar,
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (subHeader != null) ...[const SizedBox(height: 12), subHeader!],
            const SizedBox(height: 12),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
