import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../coozy_core.dart';

/// Utility class for date formatting and manipulation.
class DateUtil {
  DateUtil._();

  static const String dateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSSSSZ';

  // 'yyyy-MM-dd HH:mm' =>"2022-02-21 04:14"
  static const String dateFormat1 = 'yyyy-MM-dd HH:mm';

  // 'yyyy-MM-dd HH:mm' =>"21-02-2022 04:14"
  // ignore: constant_identifier_names
  static const String dateFormat2 = 'dd-MM-yyyy HH:mm';

  // 'yyyy-MM-dd HH:mm' =>"21-Feb-2022 04:14"
  static const String dateFormat3 = 'dd-MMM-yyyy HH:mm';

  // 'yy-MM-dd hh:mm:ss aaa' =>"22-02-21 04:15:03 AM"
  static const String dateFormat4 = 'yy-MM-dd hh:mm:ss aaa';

  //"MM-dd-yyyy hh:mm tt" for server which exactly to equal "MM-dd-yyyy hh:mm aaa"
  // 'MM-dd-yy  hh:mm:ss aaa' =>"02-21-22 04:15:03 AM"
  static const String dateFormat5 = 'MM-dd-yy hh:mm:ss aaa';

  // 'dd-MM-yy  hh:mm:ss aaa' =>"21-02-22 04:15:03 AM"
  static const String dateFormat6 = 'dd-MM-yy hh:mm:ss aaa';

  // 'yyyy-MM-dd'=>"2022-02-21"
  static const String dateFormat7 = 'yyyy-MM-dd';

  // 'MM-dd-yyyy'=>"02-21-2022"
  static const String dateFormat8 = 'MM-dd-yyyy';

  // 'dd-MM-yyyy'=>"21-02-2022"
  static const String dateFormat9 = 'dd-MM-yyyy';

  // 'yyyy-MM-dd'=>"21-Feb-2022"
  static const String dateFormat10 = 'dd-MMM-yyyy';

  // 'dd/MM/yyyy hh:mm:ss aaa'=>"11/02/2022 04:16:58 AM"
  static const String dateFormat11 = 'dd/MM/yyyy hh:mm:ss aaa';

  // 'eeee'=>"Friday"
  static const String dateFormat12 = 'eeee';

  // 'EEE'=>"Fri"
  static const String dateFormat13 = 'EEE';

  // 'MMMM'=>"February"
  static const String dateFormat14 = 'MMMM';

  // 'dd-MM-yyyy hh:mm:ss aaa =>"11-02-2022 04:16:58 AM"
  static const String dateFormat15 = 'dd-MM-yyyy hh:mm:ss aaa';

  static const String dateFormat16 = 'dd-MM-yyyy hh:mm aaa';

  // 'hh:mm:ss aaa'=>"04:16:58 AM"
  static const String timeFormat1 = 'hh:mm:ss aaa';

  // 'hh:mm aaa'=>"04:16 AM"
  static const String timeFormat2 = 'hh:mm aaa';

  static String currentTimestamp = DateTime.now().toUtc().toIso8601String();

  /// Formats a DateTime into a file-safe date label (e.g., "2026-06-09").
  static String formatDateLabel(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Formats a DateTime into a human-readable string.
  static String formatReadable(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Returns the start of the current day in UTC.
  static DateTime startOfDay([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime.utc(d.year, d.month, d.day);
  }

  /// Returns the end of the current day in UTC.
  static DateTime endOfDay([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime.utc(d.year, d.month, d.day, 23, 59, 59, 999);
  }

  /// Returns the start of the current week (Monday) in UTC.
  static DateTime startOfWeek([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).subtract(Duration(days: d.weekday - 1));
  }

  static String? localFormat(String? utcTime, String dateFormat) {
    String? updatedDt;
    try {
      if (utcTime != null) {
        final DateTime strToDateTime = DateTime.parse(utcTime);
        final DateTime convertLocal = strToDateTime.toLocal();
        updatedDt = DateFormat(dateFormat).format(convertLocal);
      }
    } catch (e) {
      PlatformUtils.debugLog(DateUtil, 'LocalFormat:error:${e.toString()}');
    }
    return updatedDt;
  }

  static String? localFormatDateTime(DateTime? utcTime, String dateFormat) {
    String? updatedDt;
    try {
      if (utcTime != null) {
        final DateTime convertLocal = utcTime.toLocal();
        updatedDt = DateFormat(dateFormat).format(convertLocal);
      }
    } catch (e) {
      PlatformUtils.debugLog(DateUtil, 'LocalFormat:error:${e.toString()}');
    }
    return updatedDt;
  }

  static DateTime? stringToLocalDate(String? utcTime, String dateFormat) {
    try {
      if (utcTime != null) {
        return DateFormat(dateFormat).parse(utcTime).toLocal();
      }
    } catch (e) {
      PlatformUtils.debugLog(
        DateUtil,
        'StringToLocalDate: error - ${e.toString()}',
      );
    }
    return null;
  }

  static DateTime stringToDate(String? time, String dateFormat) {
    DateTime? input;
    try {
      if (time != null) {
        input = DateFormat(dateFormat).parse(time);
      }
    } catch (e) {
      PlatformUtils.debugLog(DateUtil, 'StingToDate:error:${e.toString()}');
      input = null;
    }
    return input!;
  }

  static String? dateToString(DateTime? time, String? dateFormat) {
    if (time == null) {
      return null;
    }
    try {
      return DateFormat(dateFormat).format(time);
    } catch (e) {
      PlatformUtils.debugLog(DateUtil, 'dateToString:error:${e.toString()}');
      return null;
    }
  }

  static DateTime? simpleDateFormatChanger(
    DateTime? inputDate,
    String? dateFormat,
  ) {
    if (inputDate == null || dateFormat == null) return null;

    try {
      final String formattedDate = DateFormat(dateFormat).format(inputDate);
      final DateTime parsedDate = DateFormat(dateFormat).parse(formattedDate);
      return parsedDate;
    } catch (e) {
      return null;
    }
  }

  static String? simpleStringFormatChanger({
    final String? inputDate,
    final String? dateFormat,
  }) {
    if (inputDate == null || dateFormat == null) return null;
    try {
      return DateFormat(
        dateFormat,
      ).format(DateFormat(dateFormat).parse(inputDate));
    } catch (e) {
      return null;
    }
  }

  static bool isDateHasValidDateFormat(DateTime? time, String? dateFormat) {
    try {
      DateFormat(dateFormat).format(time!);
      return true;
    } catch (e) {
      return false;
      // throw Exception('Invalid date format');
    }
  }

  static bool isStringHasCorrectDateFormat(String? time, String? dateFormat) {
    try {
      DateFormat(dateFormat).parse(time ?? '');
      return true;
    } catch (e) {
      return false;
      // throw Exception('Invalid date format');
    }
  }

  static DateTime? stringToLocalDateTime(String? utcTime, String dateFormat) {
    try {
      if (utcTime != null) {
        // Parse the input string using the provided date format
        final DateTime parsedDateTime = DateFormat(dateFormat).parse(utcTime);

        // Convert the parsed UTC DateTime to local DateTime
        return parsedDateTime.toLocal();
      }
    } catch (e) {
      PlatformUtils.debugLog(
        DateUtil,
        'StringToLocalDateTime: error - ${e.toString()}',
      );
    }
    return null;
  }

  static DateTime? stringToDateTime(String? date, String dateFormat) {
    try {
      if (date != null) {
        // Parse the input string using the provided date format
        final DateTime? parsedDateTime = DateFormat(dateFormat).tryParse(date);

        // Convert the parsed UTC DateTime to local DateTime
        return parsedDateTime;
      }
    } catch (e) {
      PlatformUtils.debugLog(
        DateUtil,
        'stringToDateTime: error - ${e.toString()}',
      );
    }
    return null;
  }

  // Convert DateTime to TimeOfDay
  static TimeOfDay dateTimeToTimeOfDay(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  // Convert TimeOfDay to DateTime
  static DateTime timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final DateTime now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }

  // Format TimeOfDay as string
  static String formatTimeOfDay(TimeOfDay timeOfDay, String pattern) {
    final DateTime dateTime = timeOfDayToDateTime(timeOfDay);
    return DateFormat(pattern).format(dateTime);
  }

  static TimeOfDay parseTimeOfDay(String time, String format) {
    final DateTime? dateTime = DateFormat(format).tryParse(time);
    return TimeOfDay(hour: dateTime?.hour ?? 0, minute: dateTime?.minute ?? 0);
  }

  String formatDuration(Duration duration) {
    // Format duration into "HH:mm"
    final String hours = (duration.inHours % 24).toString().padLeft(2, '0');
    final String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');

    return '$hours:$minutes';
  }

  static String? calculateRemainingTime({
    required String? format,
    String? fromTime,
    String? toTime,
  }) {
    try {
      final DateTime? startDateTime = DateFormat(format).tryParse(fromTime!);
      final DateTime? endDateTime = DateFormat(format).tryParse(toTime!);

      // Calculate the difference
      final Duration difference = startDateTime!.difference(endDateTime!);

      // Convert the difference to hours and minutes
      final int days = difference.inDays;
      final int hours = difference.inHours % 24;
      final int minutes = difference.inMinutes % 60;
      final StringBuffer stringBuffer = StringBuffer('');
      if (days != 0) {
        stringBuffer.write('$days days');
      } else if (hours != 0) {
        if (days != 0) {
          stringBuffer.write(', $hours hours');
        } else {
          stringBuffer.write('$hours hours');
        }
      }
      if (minutes != 0) {
        if (hours != 0) {
          stringBuffer.write(', $minutes minutes');
        } else {
          stringBuffer.write('$minutes minutes');
        }
      }

      final String dateValue = stringBuffer.toString();
      // Return formatted string
      return dateValue;
    } catch (e) {
      PlatformUtils.debugLog(
        DateUtil,
        'calculateRemainingTime: error - ${e.toString()}',
      );
      return null;
    }
  }

  static int? calculateTimeDifferenceInSeconds(
    String checkInTime,
    String checkOutTime,
  ) {
    try {
      final DateTime checkInDateTime = DateFormat.jm().parse(checkInTime);
      final DateTime checkOutDateTime = DateFormat.jm().parse(checkOutTime);

      // Calculate the difference
      final Duration difference = checkOutDateTime.difference(checkInDateTime);
      PlatformUtils.debugLog(
        DateUtil,
        'calculateTimeDifferenceInMinutes:difference:${difference.inMinutes.toString()}',
      );
      return difference.inSeconds;
    } catch (error) {
      PlatformUtils.debugLog(
        DateUtil,
        'calculateTimeDifferenceInMinutes:Error:$error',
      );
      return null;
    }
  }
}
