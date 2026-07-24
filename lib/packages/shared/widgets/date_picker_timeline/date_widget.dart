import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'gestures/tap.dart';

/// Individual date tile widget used in the DatePicker list.
///
/// Renders month abbreviation, day-of-week abbreviation, and date number
/// in a [Column] (horizontal mode) or [Row] (vertical mode).
///
/// Based on: https://github.com/iamvivekkaushik/DatePickerTimelineFlutter
class DateWidget extends StatelessWidget {
  final double width;
  final double height;
  final DateTime date;
  final TextStyle? monthTextStyle;
  final TextStyle? dayTextStyle;
  final TextStyle? dateTextStyle;
  final Color selectionColor;
  final DateChangeListener? onDateSelected;
  final String? locale;
  final bool isSelected;
  final bool isDeactivated;
  final Color? deactivatedColor;
  final Color? selectedTextColor;
  final BorderRadius borderRadius;

  const DateWidget({
    super.key,
    required this.date,
    required this.width,
    required this.height,
    required this.monthTextStyle,
    required this.dayTextStyle,
    required this.dateTextStyle,
    required this.selectionColor,
    this.onDateSelected,
    this.locale,
    this.isSelected = false,
    this.isDeactivated = false,
    this.deactivatedColor,
    this.selectedTextColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  Widget build(BuildContext context) {
    // Resolve final text styles based on selection / deactivation state.
    final TextStyle monthStyle = _resolveStyle(monthTextStyle);
    final TextStyle dayStyle = _resolveStyle(dayTextStyle);
    final TextStyle dateStyle = _resolveStyle(dateTextStyle);

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Material(
        elevation: isSelected ? 4.0 : 0.0,
        animateColor: true,
        animationDuration: const Duration(milliseconds: 300),
        type: MaterialType.card,
        borderRadius: borderRadius,
        color: isSelected ? selectionColor : Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: isDeactivated ? null : () => onDateSelected?.call(date),
          child: SizedBox(
            width: width,
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    DateFormat('MMM', locale).format(date).toUpperCase(),
                    style: monthStyle,
                  ),
                  const SizedBox(height: 2),
                  Text(date.day.toString(), style: dateStyle),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('E', locale).format(date).toUpperCase(),
                    style: dayStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Applies deactivated or selected color overrides to the given style.
  TextStyle _resolveStyle(TextStyle? baseStyle) {
    final TextStyle style = baseStyle ?? const TextStyle();
    if (isDeactivated) {
      return style.copyWith(color: deactivatedColor ?? style.color);
    }
    if (isSelected && selectedTextColor != null) {
      return style.copyWith(color: selectedTextColor);
    }
    return style;
  }
}
