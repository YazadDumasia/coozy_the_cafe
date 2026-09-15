import 'package:coozy_the_cafe/packages/checkout/checkout.dart' as checkout;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/checkout_bloc.dart';

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final summary = state.summary;

        final sharedTaxDetails = summary.taxDetails
            .map(
              (t) => shared.AppliedTaxDetail(
                name: t.name,
                ratePercent: t.ratePercent,
                taxableSubtotal: t.taxableSubtotal,
                calculatedAmount: t.calculatedAmount,
              ),
            )
            .toList();

        final sharedDiscountDetails = summary.discountDetails
            .map(
              (d) => shared.AppliedDiscountDetail(
                name: d.name,
                value: d.value,
                isPercentage: d.isPercentage,
                calculatedAmount: d.calculatedAmount,
              ),
            )
            .toList();

        final sharedChargeDetails = summary.chargeDetails
            .map(
              (c) => shared.AppliedChargeDetail(
                name: c.name,
                value: c.value,
                isPercentage: c.isPercentage,
                calculatedAmount: c.calculatedAmount,
              ),
            )
            .toList();

        final sharedAppliedTaxes = state.appliedTaxes
            .map(
              (t) => shared.Tax(
                id: t.id,
                name: t.name,
                ratePercent: t.ratePercent,
                isDefaultAdd: t.isDefaultAdd,
              ),
            )
            .toList();

        final sharedAppliedDiscounts = state.appliedDiscounts
            .map(
              (d) => shared.Discount(
                id: d.id,
                name: d.name,
                value: d.value,
                isPercentage: d.isPercentage,
                isDefaultAdd: d.isDefaultAdd,
              ),
            )
            .toList();

        final sharedAppliedCharges = state.appliedOtherCharges
            .map(
              (c) => shared.ExtraCharge(
                id: c.id,
                name: c.name,
                value: c.value,
                isPercentage: c.isPercentage,
                isDefaultAdd: c.isDefaultAdd,
              ),
            )
            .toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: shared.SubtotalSummaryCard(
            subtotal: summary.subtotal,
            taxDetails: sharedTaxDetails,
            discountDetails: sharedDiscountDetails,
            chargeDetails: sharedChargeDetails,
            grandTotal: summary.grandTotal,
            totalItemCount: state.totalItemCount,
            totalUnitCount: state.totalUnitCount,
            isRoundOffEnabled: state.isRoundOffEnabled,
            roundingAmount: summary.roundingAmount,
            showClearButton: true,
            onRoundOffToggled: () {
              context.read<CheckoutBloc>().add(const CheckoutRoundOffToggled());
            },
            onAddTax: () {
              shared.showResponsiveModal(
                context: context,
                child: shared.SelectTaxDialog(
                  appliedTaxes: sharedAppliedTaxes,
                  onTaxAdded: (tax) {
                    context.read<CheckoutBloc>().add(
                      CheckoutTaxAdded(
                        checkout.Tax(
                          id: tax.id,
                          name: tax.name,
                          ratePercent: tax.ratePercent,
                          isDefaultAdd: tax.isDefaultAdd,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            onAddDiscount: () {
              shared.showResponsiveModal(
                context: context,
                child: shared.SelectDiscountDialog(
                  appliedDiscounts: sharedAppliedDiscounts,
                  onDiscountAdded: (discount) {
                    context.read<CheckoutBloc>().add(
                      CheckoutDiscountAdded(
                        checkout.Discount(
                          id: discount.id,
                          name: discount.name,
                          value: discount.value,
                          isPercentage: discount.isPercentage,
                          isDefaultAdd: discount.isDefaultAdd,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            onAddOtherCharges: () {
              shared.showResponsiveModal(
                context: context,
                child: shared.SelectChargeDialog(
                  appliedOtherCharges: sharedAppliedCharges,
                  onChargeAdded: (charge) {
                    context.read<CheckoutBloc>().add(
                      CheckoutOtherChargeAdded(
                        checkout.ExtraCharge(
                          id: charge.id,
                          name: charge.name,
                          value: charge.value,
                          isPercentage: charge.isPercentage,
                          isDefaultAdd: charge.isDefaultAdd,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            onRemoveTax: (taxDetail) {
              final target = state.appliedTaxes.firstWhere(
                (t) => t.name == taxDetail.name,
                orElse: () => checkout.Tax(id: '', name: '', ratePercent: 0),
              );
              if (target.id.isNotEmpty) {
                context.read<CheckoutBloc>().add(CheckoutTaxRemoved(target.id));
              }
            },
            onRemoveDiscount: (discountDetail) {
              final target = state.appliedDiscounts.firstWhere(
                (d) => d.name == discountDetail.name,
                orElse: () =>
                    const checkout.Discount(id: '', name: '', value: 0),
              );
              if (target.id.isNotEmpty) {
                context.read<CheckoutBloc>().add(
                  CheckoutDiscountRemoved(target.id),
                );
              }
            },
            onRemoveCharge: (chargeDetail) {
              final target = state.appliedOtherCharges.firstWhere(
                (c) => c.name == chargeDetail.name,
                orElse: () =>
                    const checkout.ExtraCharge(id: '', name: '', value: 0),
              );
              if (target.id.isNotEmpty) {
                context.read<CheckoutBloc>().add(
                  CheckoutOtherChargeRemoved(target.id),
                );
              }
            },
            onClearCart: () {
              context.read<CheckoutBloc>().add(const CheckoutCleared());
            },
          ),
        );
      },
    );
  }
}
