import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';

class CardOrOtherPaymentView extends StatefulWidget {
  final String paymentModeName;
  final double grandTotal;
  final VoidCallback onBack;
  final VoidCallback onPaymentConfirmed;

  const CardOrOtherPaymentView({
    super.key,
    required this.paymentModeName,
    required this.grandTotal,
    required this.onBack,
    required this.onPaymentConfirmed,
  });

  @override
  State<CardOrOtherPaymentView> createState() => _CardOrOtherPaymentViewState();
}

class _CardOrOtherPaymentViewState extends State<CardOrOtherPaymentView> {
  late final TextEditingController _receiptNoteController;
  late final FocusNode _receiptNoteFocusNode;
  bool _sendSms = true;
  bool _isNoteExpanded = true;

  @override
  void initState() {
    super.initState();
    _receiptNoteController = TextEditingController();
    _receiptNoteFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _receiptNoteController.dispose();
    _receiptNoteFocusNode.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? theme.colorScheme.surface : const Color(0xFFF4F4F6),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              color: theme.colorScheme.primary,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: widget.onBack,
                    tooltip: context.tr(
                          shared.LocaleKeys.commonBack,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Back',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.paymentModeName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Grand Total Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(
                              shared.LocaleKeys.checkoutGrandTotal,
                              track: shared.TrackConstants.checkoutPageTrack,
                            ) ??
                            'Grand Total',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatAmount(widget.grandTotal),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Receipt Note (Optional) Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isNoteExpanded = !_isNoteExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          children: [
                            Icon(
                              _isNoteExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.checkoutReceiptNoteOptional,
                                    track: shared.TrackConstants.checkoutPageTrack,
                                  ) ??
                                  'Receipt Note (Optional)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isNoteExpanded) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextField(
                            controller: _receiptNoteController,
                            focusNode: _receiptNoteFocusNode,
                            maxLines: null,
                            expands: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Send Transaction SMS Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                color: theme.colorScheme.surface,
                child: CheckboxListTile(
                  value: _sendSms,
                  onChanged: (val) {
                    setState(() {
                      _sendSms = val ?? false;
                    });
                  },
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutSendTransactionSms,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Send Transaction SMS',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    context.tr(
                          shared.LocaleKeys.checkoutSmsLeftZero,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'SMS left 0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Bottom Sticky Green Confirmation Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: widget.onPaymentConfirmed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CB85C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  context.tr(
                        shared.LocaleKeys.checkoutReceivedByMode,
                        track: shared.TrackConstants.checkoutPageTrack,
                        params: {'modeName': widget.paymentModeName},
                      ) ??
                      'Received by ${widget.paymentModeName}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
