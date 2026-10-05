import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import '../../../../domain/entities/sales_trend_entry.dart';

class SalesPeriodFormatSelector extends StatelessWidget {
  const SalesPeriodFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  final SalesPeriodFormat selectedFormat;
  final ValueChanged<SalesPeriodFormat> onFormatChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final dailyLabel =
        context.tr(
          shared.LocaleKeys.reportPageFormatDaily,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'Daily';
    final weeklyLabel =
        context.tr(
          shared.LocaleKeys.reportPageFormatWeekly,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'Weekly';
    final monthlyLabel =
        context.tr(
          shared.LocaleKeys.reportPageFormatMonthly,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'Monthly';
    final yearlyLabel =
        context.tr(
          shared.LocaleKeys.reportPageFormatYearly,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'Yearly';

    final formats = [
      (SalesPeriodFormat.daily, dailyLabel, Icons.view_day_rounded),
      (SalesPeriodFormat.weekly, weeklyLabel, Icons.view_week_rounded),
      (
        SalesPeriodFormat.monthly,
        monthlyLabel,
        Icons.calendar_view_month_rounded,
      ),
      (SalesPeriodFormat.yearly, yearlyLabel, Icons.calendar_today_rounded),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 420;
          return Row(
            children: formats.map((item) {
              final format = item.$1;
              final label = item.$2;
              final icon = item.$3;
              final isSelected = selectedFormat == format;

              return Expanded(
                child: InkWell(
                  onTap: () => onFormatChanged(format),
                  borderRadius: BorderRadius.circular(9),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? scheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isNarrow) ...[
                          Icon(
                            icon,
                            size: 14,
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? scheme.onPrimary
                                      : scheme.onSurfaceVariant,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
