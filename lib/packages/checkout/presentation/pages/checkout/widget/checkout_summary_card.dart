import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../utils/responsive_modal.dart';
import 'select_charge_dialog.dart';
import 'select_discount_dialog.dart';
import 'select_tax_dialog.dart';

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final summary = state.summary;

        return Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      currencyFormatter.format(summary.subtotal),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Applied Taxes Lines
                ...summary.taxDetails.map((tax) {
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
                          child: Text(
                            '${tax.name} - ($formattedRate% of $formattedBase)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          summary.subtotal == 0 ? '0.00' : tax.calculatedAmount.toStringAsFixed(2),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),

                // Applied Discounts Lines
                ...summary.discountDetails.map((discount) {
                  final displayVal = discount.isPercentage
                      ? '${discount.value}%'
                      : '${discount.value % 1 == 0 ? discount.value.toInt() : discount.value.toStringAsFixed(2)}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${discount.name} ($displayVal)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '-${discount.calculatedAmount % 1 == 0 ? discount.calculatedAmount.toInt() : discount.calculatedAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Applied Other Charges Lines
                ...summary.chargeDetails.map((charge) {
                  final displayVal = charge.isPercentage
                      ? '${charge.value}%'
                      : '${charge.value % 1 == 0 ? charge.value.toInt() : charge.value.toStringAsFixed(2)}';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${charge.name} ($displayVal)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          charge.calculatedAmount % 1 == 0
                              ? charge.calculatedAmount.toInt().toString()
                              : charge.calculatedAmount.toStringAsFixed(2),
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 4),

                // Interactive Toggle: Round Off
                InkWell(
                  onTap: () {
                    context.read<CheckoutBloc>().add(const CheckoutRoundOffToggled());
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          state.isRoundOffEnabled ? Icons.check_box : Icons.check_box_outline_blank,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr(
                                shared.LocaleKeys.checkoutRoundOff,
                                track: shared.TrackConstants.checkoutPageTrack,
                              ) ??
                              'Round Off',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(Click here to ${state.isRoundOffEnabled ? "Disable" : "Enable"})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Spacer(),
                        if (state.isRoundOffEnabled)
                          Text(
                            summary.roundingAmount >= 0
                                ? '+${summary.roundingAmount.toStringAsFixed(2)}'
                                : summary.roundingAmount.toStringAsFixed(2),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
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
                    Text(
                      currencyFormatter.format(summary.grandTotal),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text(
                        context.tr(
                              shared.LocaleKeys.checkoutAddTax,
                              track: shared.TrackConstants.checkoutPageTrack,
                            ) ??
                            'Add Tax',
                      ),
                      onPressed: () {
                        showResponsiveModal(
                          context: context,
                          child: SelectTaxDialog(
                            onTaxAdded: (tax) {
                              context.read<CheckoutBloc>().add(CheckoutTaxAdded(tax));
                            },
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text(
                        context.tr(
                              shared.LocaleKeys.checkoutAddDiscount,
                              track: shared.TrackConstants.checkoutPageTrack,
                            ) ??
                            'Add Discount',
                      ),
                      onPressed: () {
                        showResponsiveModal(
                          context: context,
                          child: SelectDiscountDialog(
                            onDiscountAdded: (discount) {
                              context.read<CheckoutBloc>().add(CheckoutDiscountAdded(discount));
                            },
                          ),
                        );
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text(
                        context.tr(
                              shared.LocaleKeys.checkoutAddOtherCharges,
                              track: shared.TrackConstants.checkoutPageTrack,
                            ) ??
                            'Add Other Charges',
                      ),
                      onPressed: () {
                        showResponsiveModal(
                          context: context,
                          child: SelectChargeDialog(
                            onChargeAdded: (charge) {
                              context.read<CheckoutBloc>().add(CheckoutOtherChargeAdded(charge));
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Footer Row: Items Count & Clear Button
                Row(
                  children: [
                    Text(
                      '${state.totalItemCount} Items | ${state.totalUnitCount} Units',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Clear Cart',
                      onPressed: () {
                        context.read<CheckoutBloc>().add(const CheckoutCleared());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
