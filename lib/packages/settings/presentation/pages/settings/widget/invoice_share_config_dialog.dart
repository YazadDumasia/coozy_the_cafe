import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/invoice_management/domain/entities/invoice_management_entity.dart';
import 'package:coozy_the_cafe/packages/invoice_management/domain/services/invoice_share_service.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

/// Dialog allowing cafe owners to customize the SMS & WhatsApp invoice share message,
/// insert dynamic placeholder tags, configure an optional review/web link, preview output,
/// and easily reset to the system default format.
class InvoiceShareConfigDialog extends StatefulWidget {
  const InvoiceShareConfigDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => const InvoiceShareConfigDialog(),
    );
  }

  @override
  State<InvoiceShareConfigDialog> createState() =>
      _InvoiceShareConfigDialogState();
}

class _InvoiceShareConfigDialogState extends State<InvoiceShareConfigDialog> {
  late final TextEditingController _templateController;
  late final TextEditingController _linkController;
  late final FocusNode _templateFocusNode;
  late final FocusNode _linkFocusNode;

  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _previewTextNotifier = ValueNotifier<String>('');

  static const InvoiceDetailsEntity _sampleInvoiceDetails =
      InvoiceDetailsEntity(
        invoice: InvoiceEntity(
          id: 1024,
          hashId: 'REC-1024',
          totalCost: 360.0,
          discountAmount: 36.0,
          taxCost: 16.2,
          netPaymentAmount: 340.2,
          createdDate: '2026-10-10 22:45:00',
          customerName: 'Alex Morgan',
          phoneNumber: '+91 98765 43210',
          paymentMethodName: 'Cash',
        ),
        tableName: 'Table 4',
        items: [
          InvoiceItemEntity(
            id: 1,
            invoiceId: 1024,
            itemId: 101,
            itemName: 'Cappuccino',
            quantity: 2,
            unitPrice: 120.0,
            totalPrice: 240.0,
          ),
          InvoiceItemEntity(
            id: 2,
            invoiceId: 1024,
            itemId: 102,
            itemName: 'Croissant',
            quantity: 1,
            unitPrice: 120.0,
            totalPrice: 120.0,
          ),
        ],
      );

  @override
  void initState() {
    super.initState();
    _templateController = TextEditingController();
    _linkController = TextEditingController();
    _templateFocusNode = FocusNode();
    _linkFocusNode = FocusNode();

    _templateController.addListener(_updateLivePreview);
    _linkController.addListener(_updateLivePreview);

    _loadInitialConfig();
  }

  Future<void> _loadInitialConfig() async {
    _isLoadingNotifier.value = true;
    try {
      final template = await InvoiceShareService.instance.getTemplate();
      final customLink = await InvoiceShareService.instance.getCustomLink();

      _templateController.text = template;
      _linkController.text = customLink;
      _updateLivePreview();
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  void _updateLivePreview() {
    _previewTextNotifier.value = InvoiceShareService.instance
        .formatMessageWithTemplate(
          details: _sampleInvoiceDetails,
          template: _templateController.text,
          customLink: _linkController.text,
        );
  }

  void _insertToken(String token) {
    final text = _templateController.text;
    final selection = _templateController.selection;
    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, token);
      final newSelectionIndex = selection.start + token.length;
      _templateController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newSelectionIndex),
      );
    } else {
      _templateController.text = '$text$token';
    }
  }

  String _tr(String key) {
    return context.tr(key, track: shared.TrackConstants.settingTrack) ?? '';
  }

  Future<void> _onSave() async {
    _isSavingNotifier.value = true;
    try {
      await InvoiceShareService.instance.saveTemplate(
        _templateController.text.trim(),
      );
      await InvoiceShareService.instance.saveCustomLink(
        _linkController.text.trim(),
      );

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        shared.SnackBarUtils.showError(
          context,
          message: 'Failed to save template: $e',
        );
      }
    } finally {
      if (mounted) {
        _isSavingNotifier.value = false;
      }
    }
  }

  Future<void> _onResetToDefault() async {
    final resetTitle = _tr(shared.LocaleKeys.settingsInvoiceShareResetTitle).isNotEmpty
        ? _tr(shared.LocaleKeys.settingsInvoiceShareResetTitle)
        : 'Reset to Default Template?';
    final resetContent = _tr(shared.LocaleKeys.settingsInvoiceShareResetContent).isNotEmpty
        ? _tr(shared.LocaleKeys.settingsInvoiceShareResetContent)
        : 'This will revert your SMS and WhatsApp receipt message back to the original format and clear the custom link.';

    final confirm = await shared.DialogUtils.showConfirmationDialog<bool>(
      context: context,
      title: resetTitle,
      content: resetContent,
      confirmText: 'Reset',
      cancelText: 'Cancel',
      onConfirm: () => Navigator.of(context, rootNavigator: true).pop(true),
      onCancel: () => Navigator.of(context, rootNavigator: true).pop(false),
    );

    if (confirm != true) return;

    _templateController.text = InvoiceShareService.defaultTemplate;
    _linkController.clear();
    _updateLivePreview();

    await InvoiceShareService.instance.resetToDefault();

    if (mounted) {
      shared.SnackBarUtils.showInfo(
        context,
        message: _tr(shared.LocaleKeys.settingsInvoiceShareResetSuccess).isNotEmpty
            ? _tr(shared.LocaleKeys.settingsInvoiceShareResetSuccess)
            : 'Template reset to default layout.',
      );
    }
  }

  @override
  void dispose() {
    _templateController.removeListener(_updateLivePreview);
    _linkController.removeListener(_updateLivePreview);
    _templateController.dispose();
    _linkController.dispose();
    _templateFocusNode.dispose();
    _linkFocusNode.dispose();
    _isLoadingNotifier.dispose();
    _isSavingNotifier.dispose();
    _previewTextNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);

    final isMobile = shared.ResponsiveLayout.isMobile(context);
    final isTablet = shared.ResponsiveLayout.isTablet(context);
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : (isTablet ? 20 : 32),
        vertical: isMobile ? 16 : (isTablet ? 24 : 36),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 980 : (isTablet ? 760 : double.infinity),
          maxHeight: screenSize.height * (isMobile ? 0.94 : (isTablet ? 0.88 : 0.85)),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoadingNotifier,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const SizedBox(
                height: 300,
                child: Center(child: shared.LoadingPage(isEmbedded: true)),
              );
            }

            return Padding(
              padding: EdgeInsets.all(isMobile ? 14.0 : (isTablet ? 18.0 : 22.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          color: theme.primaryColor,
                          size: isMobile ? 20 : 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tr(shared.LocaleKeys.settingsInvoiceShareDialogTitle).isNotEmpty
                                  ? _tr(shared.LocaleKeys.settingsInvoiceShareDialogTitle)
                                  : 'Digital Receipt & Share Message',
                              style: (isMobile
                                      ? theme.textTheme.titleSmall
                                      : theme.textTheme.titleMedium)
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _tr(shared.LocaleKeys.settingsInvoiceShareDialogSubtitle).isNotEmpty
                                  ? _tr(shared.LocaleKeys.settingsInvoiceShareDialogSubtitle)
                                  : 'Customize the message sent via WhatsApp & SMS. Keep the default or customize anytime.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: isMobile ? 11 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => context.pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 10 : 14),
                  const Divider(height: 1),
                  SizedBox(height: isMobile ? 12 : 16),

                  // Scrollable Body powered by ResponsiveLayout
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Custom Link Field
                          Text(
                            _tr(shared.LocaleKeys.settingsInvoiceShareCustomLinkLabel).isNotEmpty
                                ? _tr(shared.LocaleKeys.settingsInvoiceShareCustomLinkLabel)
                                : 'Website / Review / Feedback Link (Optional)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 12.5 : 13.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _linkController,
                            focusNode: _linkFocusNode,
                            decoration: InputDecoration(
                              hintText: _tr(shared.LocaleKeys.settingsInvoiceShareCustomLinkHint).isNotEmpty
                                  ? _tr(shared.LocaleKeys.settingsInvoiceShareCustomLinkHint)
                                  : 'e.g. https://maps.app.goo.gl/... or cafe website',
                              prefixIcon: const Icon(Icons.link_rounded, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: _linkController.clear,
                                tooltip: 'Clear link',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Dynamic Placeholders Chips
                          Text(
                            _tr(shared.LocaleKeys.settingsInvoiceShareTokensTitle).isNotEmpty
                                ? _tr(shared.LocaleKeys.settingsInvoiceShareTokensTitle)
                                : 'Click token to insert into template:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 12.5 : 13.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: InvoiceShareService.supportedTokens.map((tokenInfo) {
                              final token = tokenInfo['token']!;
                              final label = tokenInfo['label']!;
                              return ActionChip(
                                label: Text(
                                  isMobile ? token : '$label ($token)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                avatar: const Icon(Icons.add_circle_outline, size: 14),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: isDark
                                    ? theme.colorScheme.surfaceContainerHighest
                                    : Colors.grey[200],
                                onPressed: () => _insertToken(token),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),

                          // ResponsiveLayout for Editor + Live Preview
                          shared.ResponsiveLayout(
                            mobile: _buildMobileTemplateSection(theme, isDark),
                            tablet: _buildWideTemplateSection(
                              theme,
                              isDark,
                              editorFlex: 6,
                              previewFlex: 5,
                              editorMaxLines: 12,
                            ),
                            desktop: _buildWideTemplateSection(
                              theme,
                              isDark,
                              editorFlex: 5,
                              previewFlex: 5,
                              editorMaxLines: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 12 : 16),
                  const Divider(height: 1),
                  SizedBox(height: isMobile ? 10 : 14),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<bool>(
                        valueListenable: _isSavingNotifier,
                        builder: (context, isSaving, _) {
                          return ElevatedButton.icon(
                            icon: isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded, size: 18),
                            label: Text(isSaving ? 'Saving...' : 'Save Template'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 14 : 18,
                                vertical: isMobile ? 10 : 12,
                              ),
                            ),
                            onPressed: isSaving ? null : _onSave,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Two-column layout for Tablet and Desktop/Web
  Widget _buildWideTemplateSection(
    ThemeData theme,
    bool isDark, {
    required int editorFlex,
    required int previewFlex,
    required int editorMaxLines,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Template Editor
        Expanded(
          flex: editorFlex,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tr(shared.LocaleKeys.settingsInvoiceShareTemplateTitle).isNotEmpty
                        ? _tr(shared.LocaleKeys.settingsInvoiceShareTemplateTitle)
                        : 'Message Template',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.restore_rounded, size: 16),
                    label: Text(
                      _tr(shared.LocaleKeys.settingsInvoiceShareResetBtn).isNotEmpty
                          ? _tr(shared.LocaleKeys.settingsInvoiceShareResetBtn)
                          : 'Reset to Default',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: _onResetToDefault,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _templateController,
                focusNode: _templateFocusNode,
                maxLines: editorMaxLines,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                ),
                decoration: InputDecoration(
                  hintText: _tr(shared.LocaleKeys.settingsInvoiceShareTemplateHint).isNotEmpty
                      ? _tr(shared.LocaleKeys.settingsInvoiceShareTemplateHint)
                      : 'Enter your custom invoice share message template...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right Column: Live Preview
        Expanded(
          flex: previewFlex,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _tr(shared.LocaleKeys.settingsInvoiceShareLivePreviewTitle).isNotEmpty
                      ? _tr(shared.LocaleKeys.settingsInvoiceShareLivePreviewTitle)
                      : 'Live Preview (with sample invoice):',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(minHeight: 250),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                      : const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: _previewTextNotifier,
                  builder: (context, preview, _) {
                    return SelectableText(
                      preview.isEmpty ? '(Empty message)' : preview,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.4,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Single-column stacked layout for Mobile
  Widget _buildMobileTemplateSection(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tr(shared.LocaleKeys.settingsInvoiceShareTemplateTitle).isNotEmpty
                  ? _tr(shared.LocaleKeys.settingsInvoiceShareTemplateTitle)
                  : 'Message Template',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.restore_rounded, size: 14),
              label: Text(
                _tr(shared.LocaleKeys.settingsInvoiceShareResetBtn).isNotEmpty
                    ? _tr(shared.LocaleKeys.settingsInvoiceShareResetBtn)
                    : 'Reset to Default',
                style: const TextStyle(fontSize: 11),
              ),
              onPressed: _onResetToDefault,
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _templateController,
          focusNode: _templateFocusNode,
          maxLines: 7,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
          decoration: InputDecoration(
            hintText: _tr(shared.LocaleKeys.settingsInvoiceShareTemplateHint).isNotEmpty
                ? _tr(shared.LocaleKeys.settingsInvoiceShareTemplateHint)
                : 'Enter your custom invoice share message template...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
        const SizedBox(height: 14),

        Text(
          _tr(shared.LocaleKeys.settingsInvoiceShareLivePreviewTitle).isNotEmpty
              ? _tr(shared.LocaleKeys.settingsInvoiceShareLivePreviewTitle)
              : 'Live Preview (with sample invoice):',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            ),
          ),
          child: ValueListenableBuilder<String>(
            valueListenable: _previewTextNotifier,
            builder: (context, preview, _) {
              return SelectableText(
                preview.isEmpty ? '(Empty message)' : preview,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.35,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
