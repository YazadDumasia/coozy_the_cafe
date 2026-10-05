import 'package:intl/intl.dart';

import '../entities/sales_trend_entry.dart';

/// Centralized utility for parsing and formatting report periods (daily, weekly, monthly, yearly).
class ReportDateUtils {
  ReportDateUtils._();

  /// Resolves the (start, end) DateTime tuple for a weekly period.
  /// Uses [startDate] and [endDate] if available, or computes it from [period] (e.g. '2026-W38')
  /// following standard SQLite/ISO Monday-Sunday week boundaries.
  static (DateTime, DateTime)? resolveWeekRange({
    String? startDate,
    String? endDate,
    required String period,
  }) {
    if (startDate != null &&
        startDate.isNotEmpty &&
        endDate != null &&
        endDate.isNotEmpty) {
      try {
        final s = DateTime.parse(startDate);
        final e = DateTime.parse(endDate);
        return (s, e);
      } catch (_) {}
    }
    return parseWeekPeriod(period);
  }

  /// Calculates (start, end) dates for SQLite '%Y-W%W' week strings (Monday-Sunday).
  static (DateTime, DateTime)? parseWeekPeriod(String periodStr) {
    final match = RegExp(r'^(\d{4})-W(\d{1,2})$').firstMatch(periodStr.trim());
    if (match == null) return null;
    final year = int.tryParse(match.group(1)!) ?? 0;
    final weekNum = int.tryParse(match.group(2)!) ?? 0;
    if (year == 0) return null;

    // SQLite %W: week 01 starts on the first Monday of the year.
    // Days before the first Monday are week 00.
    final jan1 = DateTime.utc(year, 1, 1);
    final daysUntilFirstMonday = (8 - jan1.weekday) % 7;
    final firstMonday = jan1.add(Duration(days: daysUntilFirstMonday));

    DateTime start;
    DateTime end;
    if (weekNum == 0) {
      start = jan1;
      end = firstMonday.subtract(const Duration(days: 1));
    } else {
      start = firstMonday.add(Duration(days: (weekNum - 1) * 7));
      end = start.add(const Duration(days: 6));
    }
    return (start, end);
  }

  /// Formats a period string for display in tables, reports, and exports.
  /// For weekly format, produces human-readable dates like:
  /// - Same year: '21 Sep - 27 Sep (W38)' or '07 Sep - 13 Sep (W36)'
  /// - Across years: '28 Dec 2026 - 03 Jan 2027 (W52)'
  static String formatPeriod({
    required String period,
    required SalesPeriodFormat format,
    String? startDate,
    String? endDate,
  }) {
    if (period.trim().isEmpty) return '—';
    switch (format) {
      case SalesPeriodFormat.daily:
        try {
          final dt = DateTime.parse(period);
          return DateFormat('dd MMM yyyy').format(dt);
        } catch (_) {
          return period;
        }
      case SalesPeriodFormat.weekly:
        final range = resolveWeekRange(
          startDate: startDate,
          endDate: endDate,
          period: period,
        );
        if (range != null) {
          final s = range.$1;
          final e = range.$2;
          final weekSuffix = period.contains('-W')
              ? ' (W${period.split('-W').last})'
              : '';
          if (s.year != e.year) {
            return '${DateFormat('d MMM yyyy').format(s)} - ${DateFormat('d MMM yyyy').format(e)}$weekSuffix';
          }
          return '${DateFormat('d MMM').format(s)} - ${DateFormat('d MMM yyyy').format(e)}$weekSuffix';
        }
        return period;
      case SalesPeriodFormat.monthly:
        try {
          final parts = period.split('-');
          if (parts.length >= 2) {
            final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
            return DateFormat('MMMM yyyy').format(dt);
          }
        } catch (_) {}
        return period;
      case SalesPeriodFormat.yearly:
        return period;
    }
  }

  /// Short period label for chart axes and tooltips.
  /// For weekly format, produces concise date intervals like '21-27 Sep' or '31 Aug-6 Sep'.
  static String formatChartLabel({
    required String period,
    required SalesPeriodFormat format,
    String? startDate,
    String? endDate,
  }) {
    if (period.trim().isEmpty) return '';
    switch (format) {
      case SalesPeriodFormat.daily:
        try {
          final dt = DateTime.parse(period);
          return DateFormat('d/MM').format(dt);
        } catch (_) {
          if (period.length >= 10) {
            final parts = period.substring(0, 10).split('-');
            if (parts.length >= 3) return '${parts[2]}/${parts[1]}';
          }
          return period;
        }
      case SalesPeriodFormat.weekly:
        final range = resolveWeekRange(
          startDate: startDate,
          endDate: endDate,
          period: period,
        );
        if (range != null) {
          final s = range.$1;
          final e = range.$2;
          if (s.month == e.month) {
            return '${DateFormat('d').format(s)}-${DateFormat('d MMM').format(e)}';
          }
          return '${DateFormat('d MMM').format(s)}-${DateFormat('d MMM').format(e)}';
        }
        if (period.contains('-W')) {
          final parts = period.split('-W');
          if (parts.length == 2) return 'W${parts[1]}';
        }
        return period;
      case SalesPeriodFormat.monthly:
        try {
          final parts = period.split('-');
          if (parts.length >= 2) {
            final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
            return DateFormat('MMM yy').format(dt);
          }
        } catch (_) {}
        return period;
      case SalesPeriodFormat.yearly:
        return period;
    }
  }

  static const Map<String, int> _monthMap = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  /// Parses diverse period and date strings into a comparable [DateTime].
  /// Supports:
  /// - Daily: '02 Sep 2026', '2 Sep 2026', '2026-09-02'
  /// - Weekly: '21 Sep - 27 Sep 2026 (W38)', '28 Dec 2026 - 03 Jan 2027 (W52)', '2026-W38'
  /// - Monthly: 'September 2026', 'Sep 2026', '2026-09'
  /// - Yearly: '2026'
  /// - Standard formats: 'dd/MM/yyyy', 'dd-MM-yyyy', ISO-8601
  static DateTime? parsePeriodDate(dynamic input) {
    if (input == null) return null;
    if (input is DateTime) return input;
    final str = input.toString().trim();
    if (str.isEmpty || str == '—') return null;

    // 1. Direct ISO / standard parse (e.g. '2026-09-02', '2026-09-02T10:00:00')
    final direct = DateTime.tryParse(str);
    if (direct != null) return direct;

    // 2. 'dd MMM yyyy' or 'd MMM yyyy' (e.g. '02 Sep 2026', '2 Sep 2026')
    final dayMonthYearMatch = RegExp(r'^(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})$')
        .firstMatch(str);
    if (dayMonthYearMatch != null) {
      final day = int.tryParse(dayMonthYearMatch.group(1)!);
      final mKey = dayMonthYearMatch.group(2)!.toLowerCase();
      final year = int.tryParse(dayMonthYearMatch.group(3)!);
      final month = _monthMap[mKey];
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    // 3. 'MMMM yyyy' or 'MMM yyyy' (e.g. 'September 2026', 'Sep 2026')
    final monthYearMatch = RegExp(r'^([A-Za-z]+)\s+(\d{4})$').firstMatch(str);
    if (monthYearMatch != null) {
      final mKey = monthYearMatch.group(1)!.toLowerCase();
      final year = int.tryParse(monthYearMatch.group(2)!);
      final month = _monthMap[mKey];
      if (month != null && year != null) {
        return DateTime(year, month, 1);
      }
    }

    // 4. Weekly format with dates:
    // e.g. '21 Sep 2026 - 27 Sep 2026 (W38)', '21 Sep - 27 Sep 2026 (W38)', '28 Dec 2026 - 03 Jan 2027 (W52)'
    final weekMatch = RegExp(
      r'^(\d{1,2})\s+([A-Za-z]+)(?:\s+(\d{4}))?\s*-\s*(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})',
    ).firstMatch(str);
    if (weekMatch != null) {
      final day = int.tryParse(weekMatch.group(1)!);
      final mKey = weekMatch.group(2)!.toLowerCase();
      final year = int.tryParse(weekMatch.group(3) ?? weekMatch.group(6)!);
      final month = _monthMap[mKey];
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    // 5. Weekly format without year in first part: '21 Sep - 27 Sep (W38)'
    final weekTagMatch = RegExp(
      r'^(\d{1,2})\s+([A-Za-z]+)\s*-\s*(\d{1,2})\s+([A-Za-z]+)(?:\s*\(W(\d{1,2})\))?',
    ).firstMatch(str);
    if (weekTagMatch != null) {
      final day = int.tryParse(weekTagMatch.group(1)!);
      final mKey = weekTagMatch.group(2)!.toLowerCase();
      final month = _monthMap[mKey];
      if (day != null && month != null) {
        return DateTime(DateTime.now().year, month, day);
      }
    }

    // 6. SQLite week: '2026-W38'
    final isoWeekMatch = RegExp(r'^(\d{4})-W(\d{1,2})$').firstMatch(str);
    if (isoWeekMatch != null) {
      final parsed = parseWeekPeriod(str);
      if (parsed != null) return parsed.$1;
    }

    // 7. Slash/dash date: 'dd/MM/yyyy' or 'dd-MM-yyyy'
    final slashMatch = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})$')
        .firstMatch(str);
    if (slashMatch != null) {
      final p1 = int.tryParse(slashMatch.group(1)!);
      final p2 = int.tryParse(slashMatch.group(2)!);
      final p3 = int.tryParse(slashMatch.group(3)!);
      if (p1 != null && p2 != null && p3 != null) {
        if (p1 > 12) {
          return DateTime(p3, p2, p1);
        } else if (p2 > 12) {
          return DateTime(p3, p1, p2);
        } else {
          return DateTime(p3, p2, p1);
        }
      }
    }

    // 8. 4-digit Year only: '2026'
    final yearMatch = RegExp(r'^\d{4}$').firstMatch(str);
    if (yearMatch != null) {
      final y = int.tryParse(str);
      if (y != null) return DateTime(y, 1, 1);
    }

    return null;
  }
}
