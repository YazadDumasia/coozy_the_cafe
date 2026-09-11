import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/extra_charge.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../utils/responsive_modal.dart';
import 'add_other_charge_dialog.dart';

class SelectChargeDialog extends StatelessWidget {
  final Function(ExtraCharge) onChargeAdded;

  const SelectChargeDialog({
    super.key,
    required this.onChargeAdded,
  });

  Future<void> _onOptionSelected(
    BuildContext context,
    String chargeName,
    CheckoutState state,
    List<ExtraCharge> savedCharges,
  ) async {
    Navigator.of(context).pop();

    ExtraCharge? existing = state.appliedOtherCharges.firstWhere(
      (c) => c.name.trim().toLowerCase() == chargeName.trim().toLowerCase(),
      orElse: () => const ExtraCharge(id: '', name: '', value: 0),
    );

    if (existing.name.isEmpty) {
      existing = savedCharges.firstWhere(
        (c) => c.name.trim().toLowerCase() == chargeName.trim().toLowerCase(),
        orElse: () => const ExtraCharge(id: '', name: '', value: 0),
      );
    }

    if (!context.mounted) return;

    showResponsiveModal(
      context: context,
      child: AddOtherChargeDialog(
        initialName: chargeName,
        initialValue: existing.name.isNotEmpty ? existing.value : null,
        initialIsPercentage:
            existing.name.isNotEmpty ? existing.isPercentage : null,
        initialIsDefaultAdd:
            existing.name.isNotEmpty ? existing.isDefaultAdd : null,
        onChargeAdded: onChargeAdded,
      ),
    );
  }

  Future<List<ExtraCharge>> _getSavedCharges() async {
    try {
      final db = sl<CoozyDatabase>();
      final rows = await db.select(db.extraChargesTable).get();
      return rows
          .map(
            (r) => ExtraCharge(
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
            'key': 'Delivery Charge',
            'display': context.tr(
                  shared.LocaleKeys.checkoutDeliveryCharge,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Delivery Charge',
          },
          {
            'key': 'Packing Charge',
            'display': context.tr(
                  shared.LocaleKeys.checkoutPackingCharge,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Packing Charge',
          },
          {
            'key': 'Service Charge/Fee',
            'display': context.tr(
                  shared.LocaleKeys.checkoutServiceChargeFee,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Service Charge/Fee',
          },
          {
            'key': 'Other Charge',
            'display': context.tr(
                  shared.LocaleKeys.checkoutOtherCharge,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Other Charge',
          },
        ];

        return FutureBuilder<List<ExtraCharge>>(
          future: _getSavedCharges(),
          builder: (context, snapshot) {
            final savedCharges = snapshot.data ?? [];
            final existingNames = defaultOptions
                .map((e) => e['key']!.toLowerCase())
                .toSet();
            final customOptions = <Map<String, String>>[];

            for (final charge in [...state.appliedOtherCharges, ...savedCharges]) {
              if (charge.name.trim().isNotEmpty &&
                  !existingNames.contains(charge.name.trim().toLowerCase())) {
                existingNames.add(charge.name.trim().toLowerCase());
                customOptions.add({
                  'key': charge.name,
                  'display': charge.name,
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
                  // Header Row with "SELECT CHARGE" title and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Expanded(
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.checkoutSelectCharge,
                                  track: shared.TrackConstants.checkoutPageTrack,
                                ) ??
                                'SELECT CHARGE',
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

                  // List of Charge Options (Default + Dynamically Added Extra Charges)
                  ...allOptions.map((option) {
                    return InkWell(
                      onTap: () => _onOptionSelected(
                        context,
                        option['display']!,
                        state,
                        savedCharges,
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
