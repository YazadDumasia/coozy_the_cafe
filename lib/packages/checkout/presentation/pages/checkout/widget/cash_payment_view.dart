import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';

typedef CashPaymentConfirmedCallback = void Function({
  required double cashReceived,
  required double changeAmount,
  String? note,
});

class CashPaymentView extends StatefulWidget {
  final double grandTotal;
  final VoidCallback onBack;
  final CashPaymentConfirmedCallback onPaymentConfirmed;

  const CashPaymentView({
    super.key,
    required this.grandTotal,
    required this.onBack,
    required this.onPaymentConfirmed,
  });

  @override
  State<CashPaymentView> createState() => _CashPaymentViewState();
}

class _CashPaymentViewState extends State<CashPaymentView> {
  late final TextEditingController _cashReceivedController;
  late final FocusNode _cashReceivedFocusNode;
  late final TextEditingController _receiptNoteController;
  late final FocusNode _receiptNoteFocusNode;
  bool _isNoteExpanded = false;

  final List<int> _quickAddValues = [
    1,
    2,
    5,
    10,
    20,
    50,
    100,
    200,
    500,
    1000,
    2000,
  ];

  @override
  void initState() {
    super.initState();
    final initialText = widget.grandTotal % 1 == 0
        ? widget.grandTotal.toInt().toString()
        : widget.grandTotal.toStringAsFixed(2);
    _cashReceivedController = TextEditingController(text: initialText);
    _cashReceivedFocusNode = FocusNode();
    _cashReceivedController.addListener(_onCashReceivedChanged);

    _receiptNoteController = TextEditingController();
    _receiptNoteFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _cashReceivedController.removeListener(_onCashReceivedChanged);
    _cashReceivedController.dispose();
    _cashReceivedFocusNode.dispose();
    _receiptNoteController.dispose();
    _receiptNoteFocusNode.dispose();
    super.dispose();
  }

  void _onCashReceivedChanged() {
    setState(() {});
  }

  double get _cashReceivedValue {
    final text = _cashReceivedController.text.trim();
    return double.tryParse(text) ?? 0.0;
  }

  double get _changeValue {
    final received = _cashReceivedValue;
    final diff = received - widget.grandTotal;
    return diff > 0 ? diff : 0.0;
  }

  void _addQuickAmount(int amount) {
    final current = _cashReceivedValue;
    final updated = current + amount;
    final updatedText = updated % 1 == 0
        ? updated.toInt().toString()
        : updated.toStringAsFixed(2);
    _cashReceivedController.text = updatedText;
    _cashReceivedController.selection = TextSelection.fromPosition(
      TextPosition(offset: _cashReceivedController.text.length),
    );
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
                    tooltip:
                        context.tr(
                          shared.LocaleKeys.commonBack,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Back',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr(
                          shared.LocaleKeys.checkoutCash,
                          track: shared.TrackConstants.checkoutPageTrack,
                        ) ??
                        'Cash',
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

            // Cash Main Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    // Grand Total Row
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr(
                                  shared.LocaleKeys.checkoutGrandTotal,
                                  track:
                                      shared.TrackConstants.checkoutPageTrack,
                                ) ??
                                'Grand Total',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatAmount(widget.grandTotal),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Cash Received (Optional) Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            context.tr(
                                  shared
                                      .LocaleKeys
                                      .checkoutCashReceivedOptional,
                                  track:
                                      shared.TrackConstants.checkoutPageTrack,
                                ) ??
                                'Cash Received (Optional)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cashReceivedController,
                            focusNode: _cashReceivedFocusNode,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Change Section (Blue Tinted Container)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: isDark ? 0.3 : 0.4,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            context.tr(
                                  shared.LocaleKeys.checkoutChange,
                                  track:
                                      shared.TrackConstants.checkoutPageTrack,
                                ) ??
                                'Change',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatAmount(_changeValue),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
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
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
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
                                    track:
                                        shared.TrackConstants.checkoutPageTrack,
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
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          0.0,
                          16.0,
                          16.0,
                        ),
                        child: Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: theme
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
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

            const SizedBox(height: 20),

            // Quick Addition Pills Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 10,
                children: _quickAddValues.map((val) {
                  return OutlinedButton(
                    onPressed: () => _addQuickAmount(val),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                    child: Text(
                      '+ $val',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // Bottom Sticky Confirmation Button (Received by Cash)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.onPaymentConfirmed(
                    cashReceived: _cashReceivedValue,
                    changeAmount: _changeValue,
                    note: _receiptNoteController.text.trim(),
                  );
                },
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
                        shared.LocaleKeys.checkoutReceivedByCash,
                        track: shared.TrackConstants.checkoutPageTrack,
                      ) ??
                      'Received by Cash',
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
