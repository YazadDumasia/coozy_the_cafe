import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class CategoryGridItem extends StatelessWidget {
  final String title;
  final String type; // 'EXPENSE' or 'INCOME'
  final bool isCustomAddButton;
  final VoidCallback onTap;

  const CategoryGridItem({
    super.key,
    required this.title,
    required this.type,
    this.isCustomAddButton = false,
    required this.onTap,
  });

  /// Maps a category name to a relevant Material icon.
  static IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('tax')) {
      return Icons.receipt_long_rounded;
    }
    if (t.contains('fuel') || t.contains('petrol')) {
      return Icons.local_gas_station_rounded;
    }
    if (t.contains('food') ||
        t.contains('bread') ||
        t.contains('milk') ||
        t.contains('vegetable') ||
        t.contains('sauce') ||
        t.contains('cold drink')) {
      return Icons.restaurant_rounded;
    }
    if (t.contains('bill') || t.contains('electric') || t.contains('water')) {
      return Icons.bolt_rounded;
    }
    if (t.contains('transport') || t.contains('travel')) {
      return Icons.directions_car_rounded;
    }
    if (t.contains('insurance')) {
      return Icons.health_and_safety_rounded;
    }
    if (t.contains('salary') || t.contains('staff')) {
      return Icons.people_rounded;
    }
    if (t.contains('rent') || t.contains('rental')) {
      return Icons.home_rounded;
    }
    if (t.contains('repair') || t.contains('maintenance')) {
      return Icons.build_rounded;
    }
    if (t.contains('commission')) {
      return Icons.handshake_rounded;
    }
    if (t.contains('advertis')) {
      return Icons.campaign_rounded;
    }
    if (t.contains('fee')) {
      return Icons.price_check_rounded;
    }
    if (t.contains('interest')) {
      return Icons.percent_rounded;
    }
    if (t.contains('loan')) {
      return Icons.account_balance_rounded;
    }
    if (t.contains('supplies') || t.contains('supply')) {
      return Icons.inventory_2_rounded;
    }
    if (t.contains('transfer')) {
      return Icons.swap_horiz_rounded;
    }
    if (t.contains('contract')) {
      return Icons.description_rounded;
    }
    if (t.contains('misc') || t.contains('disposable')) {
      return Icons.more_horiz_rounded;
    }
    if (t.contains('profit')) {
      return Icons.trending_up_rounded;
    }
    if (t.contains('award')) {
      return Icons.emoji_events_rounded;
    }
    if (t.contains('sale')) {
      return Icons.point_of_sale_rounded;
    }
    if (t.contains('refund')) {
      return Icons.undo_rounded;
    }
    if (t.contains('lottery')) {
      return Icons.casino_rounded;
    }
    if (t.contains('dividend') || t.contains('invest')) {
      return Icons.show_chart_rounded;
    }
    return Icons.label_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isExpense = type == 'EXPENSE';

    final Color accentColor;
    final Color circleBgColor;
    final Color circleIconColor;

    if (isCustomAddButton) {
      accentColor = colorScheme.tertiary;
      circleBgColor = colorScheme.tertiaryContainer;
      circleIconColor = colorScheme.onTertiaryContainer;
    } else if (isExpense) {
      accentColor = const Color(0xFFD32F2F);
      circleBgColor = isDark
          ? const Color(0xFF3E2020)
          : const Color(0xFFFFEBEE);
      circleIconColor = const Color(0xFFD32F2F);
    } else {
      accentColor = const Color(0xFF2E7D32);
      circleBgColor = isDark
          ? const Color(0xFF1B3B2B)
          : const Color(0xFFE8F5E9);
      circleIconColor = const Color(0xFF2E7D32);
    }

    final Widget iconWidget = isCustomAddButton
        ? Icon(Icons.add_rounded, color: circleIconColor, size: 24)
        : Icon(_iconFor(title), color: circleIconColor, size: 22);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHigh
                : colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: circleBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: iconWidget,
                ),
                const SizedBox(height: 6),
                Text(
                  isCustomAddButton
                      ? (context.tr(
                              shared.LocaleKeys.expenditureCustom,
                              track: shared.TrackConstants.expenditurePageTrack,
                            ) ??
                            'Custom')
                      : title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
