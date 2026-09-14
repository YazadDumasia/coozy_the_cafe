import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import '../../models/bill_summary_model/bill_summary_model.dart';

class SubtotalSummaryCard extends StatelessWidget {
  final double subtotal;
  final List<AppliedTaxDetail> taxDetails;
  final List<AppliedDiscountDetail> discountDetails;
  final List<AppliedChargeDetail> chargeDetails;
  final double grandTotal;
  final int totalItemCount;
  final int totalUnitCount;
  final bool isRoundOffEnabled;
  final double roundingAmount;
  final VoidCallback? onRoundOffToggled;
  final VoidCallback? onAddTax;
  final VoidCallback? onAddDiscount;
  final VoidCallback? onAddOtherCharges;
  final ValueChanged<AppliedTaxDetail>? onRemoveTax;
  final ValueChanged<AppliedDiscountDetail>? onRemoveDiscount;
  final ValueChanged<AppliedChargeDetail>? onRemoveCharge;
  final VoidCallback? onClearCart;
  final bool showClearButton;

  const SubtotalSummaryCard({
    super.key,
    required this.subtotal,
    this.taxDetails = const [],
    this.discountDetails = const [],
    this.chargeDetails = const [],
    required this.grandTotal,
    required this.totalItemCount,
    required this.totalUnitCount,
    this.isRoundOffEnabled = false,
    this.roundingAmount = 0.0,
    this.onRoundOffToggled,
    this.onAddTax,
    this.onAddDiscount,
    this.onAddOtherCharges,
    this.onRemoveTax,
    this.onRemoveDiscount,
    this.onRemoveCharge,
    this.onClearCart,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subtotal Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr(
                        shared.LocaleKeys.checkoutSubtotal,
                        track: shared.TrackConstants.checkoutPageTrack,
                      ) ??
                      'Subtotal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  core.CurrencyFormatter.format(value: subtotal),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Applied Taxes Lines
            ...taxDetails.map((tax) {
              final formattedRate = tax.ratePercent % 1 == 0
                  ? tax.ratePercent.toInt().toString()
                  : tax.ratePercent.toString();
              final formattedBase = tax.taxableSubtotal % 1 == 0
                  ? tax.taxableSubtotal.toInt().toString()
                  : tax.taxableSubtotal.toStringAsFixed(2);

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (onRemoveTax != null) ...[
                            InkWell(
                              onTap: () => onRemoveTax!(tax),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: 16,
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              '${tax.name} - ($formattedRate% of $formattedBase)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      subtotal == 0
                          ? '0.00'
                          : '+ ${core.CurrencyFormatter.format(value: tax.calculatedAmount)}',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Applied Discounts Lines
            ...discountDetails.map((discount) {
              final displayVal = discount.isPercentage
                  ? '${discount.value}%'
                  : '${discount.value % 1 == 0 ? discount.value.toInt() : discount.value.toStringAsFixed(2)}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (onRemoveDiscount != null) ...[
                            InkWell(
                              onTap: () => onRemoveDiscount!(discount),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: 16,
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              '${discount.name} ($displayVal)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '- ${core.CurrencyFormatter.format(value: discount.calculatedAmount)}',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Applied Other Charges Lines
            ...chargeDetails.map((charge) {
              final displayVal = charge.isPercentage
                  ? '${charge.value}%'
                  : '${charge.value % 1 == 0 ? charge.value.toInt() : charge.value.toStringAsFixed(2)}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (onRemoveCharge != null) ...[
                            InkWell(
                              onTap: () => onRemoveCharge!(charge),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  size: 16,
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              '${charge.name} ($displayVal)',
                              textAlign: TextAlign.end,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+ ${core.CurrencyFormatter.format(value: charge.calculatedAmount)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 4),

            // Interactive Toggle: Round Off
            if (onRoundOffToggled != null)
              InkWell(
                onTap: onRoundOffToggled,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        isRoundOffEnabled
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(
                              shared.LocaleKeys.checkoutRoundOff,
                              track: shared.TrackConstants.checkoutPageTrack,
                            ) ??
                            'Round Off',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(Click here to ${isRoundOffEnabled ? "Disable" : "Enable"})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Spacer(),
                      if (isRoundOffEnabled)
                        Text(
                          roundingAmount >= 0
                              ? '+${roundingAmount.toStringAsFixed(2)}'
                              : roundingAmount.toStringAsFixed(2),
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            const Divider(height: 24),

            // Grand Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr(
                        shared.LocaleKeys.checkoutGrandTotal,
                        track: shared.TrackConstants.checkoutPageTrack,
                      ) ??
                      'Grand Total',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    core.CurrencyFormatter.format(value: grandTotal),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions Row: Add Tax, Add Discount, Add Other Charges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onAddTax != null)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.checkoutAddTax,
                            track: shared.TrackConstants.checkoutPageTrack,
                          ) ??
                          'Add Tax',
                    ),
                    onPressed: onAddTax,
                  ),
                if (onAddDiscount != null)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.checkoutAddDiscount,
                            track: shared.TrackConstants.checkoutPageTrack,
                          ) ??
                          'Add Discount',
                    ),
                    onPressed: onAddDiscount,
                  ),
                if (onAddOtherCharges != null)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 16),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.checkoutAddOtherCharges,
                            track: shared.TrackConstants.checkoutPageTrack,
                          ) ??
                          'Add Other Charges',
                    ),
                    onPressed: onAddOtherCharges,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Footer Row: Items Count & Units Count (and optional Clear Button)
            Row(
              children: [
                Text(
                  '$totalItemCount Items | $totalUnitCount Units',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (showClearButton && onClearCart != null) ...[
                  const Spacer(),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear Cart',
                    onPressed: onClearCart,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
