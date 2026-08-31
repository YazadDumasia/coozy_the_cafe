import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/tax.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../utils/responsive_modal.dart';
import 'add_tax_dialog.dart';

class SelectTaxDialog extends StatelessWidget {
  final Function(Tax) onTaxAdded;

  const SelectTaxDialog({
    super.key,
    required this.onTaxAdded,
  });

  void _onOptionSelected(BuildContext context, String taxName) {
    Navigator.of(context).pop();

    showResponsiveModal(
      context: context,
      child: AddTaxDialog(
        initialName: taxName,
        onTaxAdded: onTaxAdded,
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
            'key': 'CGST',
            'display': context.tr(
                  shared.LocaleKeys.checkoutCgst,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'CGST',
          },
          {
            'key': 'SGST',
            'display': context.tr(
                  shared.LocaleKeys.checkoutSgst,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'SGST',
          },
          {
            'key': 'IGST',
            'display': context.tr(
                  shared.LocaleKeys.checkoutIgst,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'IGST',
          },
          {
            'key': 'VAT',
            'display': context.tr(
                  shared.LocaleKeys.checkoutVat,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'VAT',
          },
          {
            'key': 'Other Tax',
            'display': context.tr(
                  shared.LocaleKeys.checkoutOtherTax,
                  track: shared.TrackConstants.checkoutPageTrack,
                ) ??
                'Other Tax',
          },
        ];

        // Gather existing tax names to avoid duplicates
        final existingNames = defaultOptions.map((e) => e['key']!.toLowerCase()).toSet();
        final customOptions = <Map<String, String>>[];

        for (final tax in state.appliedTaxes) {
          if (tax.name.trim().isNotEmpty &&
              !existingNames.contains(tax.name.trim().toLowerCase())) {
            existingNames.add(tax.name.trim().toLowerCase());
            customOptions.add({
              'key': tax.name,
              'display': tax.name,
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
              // Header Row with "SELECT TAX" title and close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Expanded(
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.checkoutSelectTax,
                              track: shared.TrackConstants.checkoutPageTrack,
                            ) ??
                            'SELECT TAX',
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

              // List of Tax Options (Default + Dynamically Added Taxes)
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
