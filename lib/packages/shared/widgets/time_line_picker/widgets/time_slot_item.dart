import 'package:flutter/material.dart';
import '../models/time_slot.dart';

class TimeSlotItem extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool use24HourFormat;
  final bool showEndTime;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final TextStyle? disabledTextStyle;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? disabledBackgroundColor;
  final Border? selectedBorder;
  final Border? unselectedBorder;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadows;
  final Widget? icon;

  const TimeSlotItem({
    super.key,
    required this.slot,
    required this.isSelected,
    this.onTap,
    this.use24HourFormat = false,
    this.showEndTime = true,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.disabledTextStyle,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.disabledBackgroundColor,
    this.selectedBorder,
    this.unselectedBorder,
    this.borderRadius,
    this.padding,
    this.margin,
    this.shadows,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = slot.isDisabled || !slot.isAvailable;

    Color bgColor;
    if (isDisabled) {
      bgColor =
          disabledBackgroundColor ??
          theme.disabledColor.withValues(alpha: 0.12);
    } else if (isSelected) {
      bgColor = selectedBackgroundColor ?? theme.primaryColor;
    } else {
      bgColor = unselectedBackgroundColor ?? theme.cardColor;
    }

    TextStyle textStyle;
    if (isDisabled) {
      textStyle =
          disabledTextStyle ??
          TextStyle(
            color: theme.disabledColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          );
    } else if (isSelected) {
      textStyle =
          selectedTextStyle ??
          const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          );
    } else {
      textStyle =
          unselectedTextStyle ??
          TextStyle(
            color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          );
    }

    final effectiveBorder = isSelected
        ? selectedBorder ?? Border.all(color: theme.primaryColor, width: 1.5)
        : unselectedBorder ??
              Border.all(
                color: theme.dividerColor.withValues(alpha: 0.4),
                width: 1.0,
              );

    final effectiveRadius = borderRadius ?? BorderRadius.circular(10.0);
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0);
    final effectiveMargin = margin ?? const EdgeInsets.all(4.0);

    return Container(
      margin: effectiveMargin,
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: effectiveRadius as BorderRadius?,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: effectiveRadius,
              border: isDisabled
                  ? Border.all(
                      color: theme.disabledColor.withValues(alpha: 0.2),
                    )
                  : effectiveBorder,
              boxShadow: isSelected && shadows == null
                  ? [
                      BoxShadow(
                        color: (selectedBackgroundColor ?? theme.primaryColor)
                            .withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : shadows,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 6.0)],
                Flexible(
                  child: Text(
                    slot.format(
                      context,
                      use24HourFormat: use24HourFormat,
                      showEndTime: showEndTime,
                    ),
                    style: textStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
