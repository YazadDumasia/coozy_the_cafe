import 'package:flutter/material.dart';
import 'models/time_slot.dart';

class TimeWidget extends StatelessWidget {
  final double width;
  final double height;
  final TimeSlot slot;
  final TextStyle? hourTextStyle;
  final TextStyle? periodTextStyle;
  final TextStyle? rangeTextStyle;
  final Color selectionColor;
  final ValueChanged<TimeSlot>? onSlotSelected;
  final bool isSelected;
  final bool isDeactivated;
  final Color? deactivatedColor;
  final Color? selectedTextColor;
  final BorderRadius borderRadius;
  final bool use24HourFormat;
  final bool showEndTime;

  const TimeWidget({
    super.key,
    required this.slot,
    required this.width,
    required this.height,
    required this.hourTextStyle,
    required this.periodTextStyle,
    required this.rangeTextStyle,
    required this.selectionColor,
    this.onSlotSelected,
    this.isSelected = false,
    this.isDeactivated = false,
    this.deactivatedColor,
    this.selectedTextColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.use24HourFormat = false,
    this.showEndTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle hourStyle = _resolveStyle(hourTextStyle);
    final TextStyle rangeStyle = _resolveStyle(rangeTextStyle);

    final localizations = MaterialLocalizations.of(context);
    final startStr = use24HourFormat
        ? '${slot.startTime.hour.toString().padLeft(2, '0')}:${slot.startTime.minute.toString().padLeft(2, '0')}'
        : localizations.formatTimeOfDay(
            slot.startTime,
            alwaysUse24HourFormat: false,
          );

    final endStr = use24HourFormat
        ? '${slot.endTime.hour.toString().padLeft(2, '0')}:${slot.endTime.minute.toString().padLeft(2, '0')}'
        : localizations.formatTimeOfDay(
            slot.endTime,
            alwaysUse24HourFormat: false,
          );

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
          onTap: isDeactivated ? null : () => onSlotSelected?.call(slot),
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
                    startStr,
                    style: hourStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showEndTime) ...[
                    const SizedBox(height: 2),
                    Text(
                      'to $endStr',
                      style: rangeStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _resolveStyle(TextStyle? baseStyle) {
    final TextStyle style = baseStyle ?? const TextStyle();
    if (isDeactivated) {
      return style.copyWith(color: deactivatedColor ?? Colors.grey);
    }
    if (isSelected && selectedTextColor != null) {
      return style.copyWith(color: selectedTextColor);
    }
    return style;
  }
}
