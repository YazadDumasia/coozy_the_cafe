import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/discount.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../utils/responsive_modal.dart';
import 'add_discount_dialog.dart';

class SelectDiscountDialog extends StatelessWidget {
  final Function(Discount) onDiscountAdded;

  const SelectDiscountDialog({
    super.key,
    required this.onDiscountAdded,
  });

  void _onOptionSelected(BuildContext context, String discountName) {
    Navigator.of(context).pop();

    showResponsiveModal(
      context: context,
      child: AddDiscountDialog(
        initialName: discountName,
        onDiscountAdded: onDiscountAdded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        final defaultOptions = [
          {
            'key': 'Flat Discount',
            'display': context.tr(
                  shared.LocaleKeys.checkoutFlatDiscount,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Flat Discount',
          },
          {
            'key': 'Percentage Discount',
            'display': context.tr(
                  shared.LocaleKeys.checkoutPercentageDiscount,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Percentage Discount',
          },
          {
            'key': 'Staff Discount',
            'display': context.tr(
                  shared.LocaleKeys.checkoutStaffDiscount,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Staff Discount',
          },
          {
            'key': 'Festival Offer',
            'display': context.tr(
                  shared.LocaleKeys.checkoutFestivalOffer,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Festival Offer',
          },
          {
            'key': 'Other Discount',
            'display': context.tr(
                  shared.LocaleKeys.checkoutOtherDiscount,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Other Discount',
          },
        ];

        // Gather existing discount names to avoid duplicates
        final existingNames = defaultOptions.map((e) => e['key']!.toLowerCase()).toSet();
        final customOptions = <Map<String, String>>[];

        for (final discount in state.appliedDiscounts) {
          if (discount.name.trim().isNotEmpty &&
              !existingNames.contains(discount.name.trim().toLowerCase())) {
            existingNames.add(discount.name.trim().toLowerCase());
            customOptions.add({
              'key': discount.name,
              'display': discount.name,
            });
          }
        }

        final allOptions = [...defaultOptions, ...customOptions];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row with "SELECT DISCOUNT" title and close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Expanded(
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.checkoutSelectDiscount,
                              track: shared.TrackConstants.checkoutPageTrack,
                            ) ??
                            'SELECT DISCOUNT',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: context.tr(
                            shared.LocaleKeys.commonClose,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Close',
                    ),
                  ],
                ),
              ),
              const Divider(height: 24, thickness: 1),

              // List of Discount Options (Default + Dynamically Added Discounts)
              ...allOptions.map((option) {
                return InkWell(
                  onTap: () => _onOptionSelected(context, option['display']!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    child: Text(
                      option['display']!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
