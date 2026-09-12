import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

void showInvoiceFilterBottomSheet({
  required BuildContext context,
  required ValueNotifier<List<shared.AppliedFilterModel>> appliedFiltersNotifier,
  required List<PaymentMode> paymentModes,
  required void Function(List<shared.AppliedFilterModel> applied) onApply,
}) {

  final Set<String> modeNames = {};
  for (final mode in paymentModes) {
    if (mode.paymentMethodName.trim().isNotEmpty) {
      modeNames.add(mode.paymentMethodName.trim());
    }
  }

  if (modeNames.isEmpty) {
    modeNames.addAll(['Cash', 'UPI', 'Credit Card', 'Debit Card', 'Net Banking', 'Cheque']);
  }

  final filterOptions = modeNames.map((name) {
    return shared.FilterItemModel(
      filterKey: name,
      filterTitle: name,
    );
  }).toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return FractionallySizedBox(
        heightFactor: 0.8,
        child: shared.FilterWidget(
          filterProps: shared.FilterProps(
            title: context.tr(
                  shared.LocaleKeys.commonFilters,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Filters',
            onFilterChange: (applied) {
              appliedFiltersNotifier.value = applied;
              onApply(applied);
            },
            themeProps: shared.ThemeProps.defaultThemeProps(context),
            filters: [
              shared.FilterListModel(
                filterKey: 'payment_mode',
                title: context.tr(
                      shared.LocaleKeys.invoiceTablePMode,
                      track: shared.TrackConstants.invoicePageTrack,
                    ) ??
                    'Payment Mode',
                type: shared.FilterType.checkboxList,
                previousApplied: appliedFiltersNotifier.value
                    .where((e) => e.filterKey == 'payment_mode')
                    .expand((e) => e.applied)
                    .toList(),
                filterOptions: filterOptions,
              ),
            ],
          ),
        ),
      );
    },
  );
}
