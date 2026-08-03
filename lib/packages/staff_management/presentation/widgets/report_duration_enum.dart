import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ReportDuration {
  weekly,
  monthly,
  quarterly,
  halfYear,
  yearly,
}

extension ReportDurationExt on ReportDuration {
  String get displayName {
    switch (this) {
      case ReportDuration.weekly:
        return 'Weekly';
      case ReportDuration.monthly:
        return 'Monthly';
      case ReportDuration.quarterly:
        return 'Quarterly';
      case ReportDuration.halfYear:
        return 'Half Year';
      case ReportDuration.yearly:
        return 'Yearly';
    }
  }

  /// Calculates start and end dates based on duration enum
  DateTimeRange getDateRange(DateTime referenceDate) {
    final now = referenceDate;
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (this) {
      case ReportDuration.weekly:
        // Current week (starting Monday)
        final weekday = now.weekday;
        start = DateTime(now.year, now.month, now.day).subtract(Duration(days: weekday - 1));
        break;
      case ReportDuration.monthly:
        // Current month
        start = DateTime(now.year, now.month, 1);
        break;
      case ReportDuration.quarterly:
        // Current quarter (Q1: Jan-Mar, Q2: Apr-Jun, Q3: Jul-Sep, Q4: Oct-Dec)
        final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        start = DateTime(now.year, quarterMonth, 1);
        break;
      case ReportDuration.halfYear:
        // Half year (H1: Jan-Jun, H2: Jul-Dec)
        final halfMonth = now.month <= 6 ? 1 : 7;
        start = DateTime(now.year, halfMonth, 1);
        break;
      case ReportDuration.yearly:
        // Current year
        start = DateTime(now.year, 1, 1);
        break;
    }
    return DateTimeRange(start: start, end: end);
  }

  /// Date format for axis labels
  String formatAxisLabel(DateTime date) {
    switch (this) {
      case ReportDuration.weekly:
        return DateFormat('E, d MMM').format(date);
      case ReportDuration.monthly:
        return DateFormat('d MMM').format(date);
      case ReportDuration.quarterly:
      case ReportDuration.halfYear:
        return DateFormat('MMM yyyy').format(date);
      case ReportDuration.yearly:
        return DateFormat('MMM').format(date);
    }
  }
}
