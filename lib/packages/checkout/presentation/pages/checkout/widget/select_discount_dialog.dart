import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
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

  Future<void> _onOptionSelected(
    BuildContext context,
    String discountName,
    CheckoutState state,
    List<Discount> savedDiscounts,
  ) async {
    Navigator.of(context).pop();

    Discount? existing = state.appliedDiscounts.firstWhere(
      (d) => d.name.trim().toLowerCase() == discountName.trim().toLowerCase(),
      orElse: () => const Discount(id: '', name: '', value: 0),
    );

    if (existing.name.isEmpty) {
      existing = savedDiscounts.firstWhere(
        (d) => d.name.trim().toLowerCase() == discountName.trim().toLowerCase(),
        orElse: () => const Discount(id: '', name: '', value: 0),
      );
    }

    if (!context.mounted) return;

    showResponsiveModal(
      context: context,
      child: AddDiscountDialog(
        initialName: discountName,
        initialValue: existing.name.isNotEmpty ? existing.value : null,
        initialIsPercentage:
            existing.name.isNotEmpty ? existing.isPercentage : null,
        initialIsDefaultAdd:
            existing.name.isNotEmpty ? existing.isDefaultAdd : null,
        onDiscountAdded: onDiscountAdded,
      ),
    );
  }

  Future<List<Discount>> _getSavedDiscounts() async {
    try {
      final db = sl<CoozyDatabase>();
      final rows = await db.select(db.discountsTable).get();
      return rows
          .map(
            (r) => Discount(
              id: r.id.toString(),
              name: r.name,
              value: r.value,
              isPercentage: r.isPercentage,
              isDefaultAdd: r.isDefaultAdd,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
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

        return FutureBuilder<List<Discount>>(
          future: _getSavedDiscounts(),
          builder: (context, snapshot) {
            final savedDiscounts = snapshot.data ?? [];
            final existingNames = defaultOptions
                .map((e) => e['key']!.toLowerCase())
                .toSet();
            final customOptions = <Map<String, String>>[];

            for (final discount in [...state.appliedDiscounts, ...savedDiscounts]) {
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
                      onTap: () => _onOptionSelected(
                        context,
                        option['display']!,
                        state,
                        savedDiscounts,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 24.0,
                        ),
                        child: Text(
                          option['display']!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.85),
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
      },
    );
  }
}
