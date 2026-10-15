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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          color: theme.primaryColor,
                          size: 24,
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
                              style: theme.textTheme.titleMedium?.copyWith(
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
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => context.pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Scrollable Body
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
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Dynamic Placeholders Chips
                          Row(
                            children: [
                              Text(
                                _tr(shared.LocaleKeys.settingsInvoiceShareTokensTitle).isNotEmpty
                                    ? _tr(shared.LocaleKeys.settingsInvoiceShareTokensTitle)
                                    : 'Click token to insert into template:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                                  '$label ($token)',
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

                          // Message Template Editor
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
                            maxLines: 8,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
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
                          const SizedBox(height: 16),

                          // Live Preview Card
                          Text(
                            _tr(shared.LocaleKeys.settingsInvoiceShareLivePreviewTitle).isNotEmpty
                                ? _tr(shared.LocaleKeys.settingsInvoiceShareLivePreviewTitle)
                                : 'Live Preview (with sample invoice):',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
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
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.pop(),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
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
}
