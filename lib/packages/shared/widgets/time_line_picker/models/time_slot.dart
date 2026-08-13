import 'package:flutter/material.dart';

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? label;
  final bool isAvailable;
  final bool isDisabled;
  final bool isSelected;
  final dynamic customData;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    this.label,
    this.isAvailable = true,
    this.isDisabled = false,
    this.isSelected = false,
    this.customData,
  });

  TimeSlot copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? label,
    bool? isAvailable,
    bool? isDisabled,
    bool? isSelected,
    dynamic customData,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      label: label ?? this.label,
      isAvailable: isAvailable ?? this.isAvailable,
      isDisabled: isDisabled ?? this.isDisabled,
      isSelected: isSelected ?? this.isSelected,
      customData: customData ?? this.customData,
    );
  }

  /// Helper to format 12-hour or 24-hour time string
  String format(
    BuildContext context, {
    bool use24HourFormat = false,
    bool showEndTime = true,
    String separator = ' - ',
  }) {
    if (label != null && label!.isNotEmpty) return label!;
    final startStr = _formatTimeOfDay(context, startTime, use24HourFormat);
    if (!showEndTime) return startStr;
    final endStr = _formatTimeOfDay(context, endTime, use24HourFormat);
    return '$startStr$separator$endStr';
  }

  static String _formatTimeOfDay(
    BuildContext context,
    TimeOfDay time,
    bool use24h,
  ) {
    if (use24h) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final localizations = MaterialLocalizations.of(context);
      return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: false);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => startTime.hashCode ^ endTime.hashCode;

  @override
  String toString() =>
      'TimeSlot(${startTime.hour}:${startTime.minute} - ${endTime.hour}:${endTime.minute}, isSelected: $isSelected)';
}
