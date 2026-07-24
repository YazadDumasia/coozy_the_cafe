import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'date_widget.dart';
import 'extra/color.dart';
import 'extra/style.dart';
import 'gestures/tap.dart';

/// The scroll axis for the date picker timeline.
enum DatePickerAxis {
  /// Dates scroll left / right.
  horizontal,

  /// Dates scroll top / bottom.
  vertical,
}

/// Controller for programmatic scrolling of the [DatePicker].
class DatePickerController {
  _DatePickerState? _state;

  void _attach(_DatePickerState state) => _state = state;
  void _detach() => _state = null;

  /// Animate to the currently selected date.
  void animateToSelection() {
    _state?._scrollToSelection();
  }

  /// Animate to a specific [date].
  ///
  /// The date must fall within the range `[startDate, startDate + daysCount)`.
  void animateToDate(DateTime date) {
    _state?._scrollToDate(date);
  }

  /// Jump (no animation) to the currently selected date.
  void jumpToSelection() {
    _state?._scrollToSelection(animate: false);
  }
}

/// A scrollable timeline of dates that supports **horizontal** and **vertical**
/// layouts, with auto‑sizing based on the provided text styles.
///
/// Based on: https://github.com/iamvivekkaushik/DatePickerTimelineFlutter
/// Modified to:
///   - auto‑compute item width/height from font metrics when not supplied
///   - support [DatePickerAxis.horizontal] and [DatePickerAxis.vertical]
///   - use `scrollable_positioned_list` for index-based scrolling
class DatePicker extends StatefulWidget {
  /// The first date shown in the timeline.
  final DateTime startDate;

  /// Explicit width per date tile. When `null`, it is computed from the text
  /// styles so that every label fits without clipping — **including** the
  /// selection background.
  final double? width;

  /// Explicit height per date tile. When `null`, it is computed from the text
  /// styles — **including** the selection background.
  final double? height;

  /// Optional controller for programmatic scrolling.
  final DatePickerController? controller;

  /// Text color applied to all three labels of the **selected** date.
  final Color selectedTextColor;

  /// Background color of the selection indicator.
  final Color selectionColor;

  /// Text color applied to deactivated dates.
  final Color deactivatedColor;

  /// Style for the month abbreviation label.
  final TextStyle monthTextStyle;

  /// Style for the day‑of‑week abbreviation label.
  final TextStyle dayTextStyle;

  /// Style for the date number label.
  final TextStyle dateTextStyle;

  /// The date to mark as selected on first build. If provided, the list will
  /// **scroll to this date** immediately.
  final DateTime? initialSelectedDate;

  /// Dates that should be rendered but **not** tappable.
  final List<DateTime>? inactiveDates;

  /// When non‑null, **only** these dates are tappable — all others are
  /// deactivated.
  final List<DateTime>? activeDates;

  /// Fired whenever the user taps a different date.
  final DateChangeListener? onDateChange;

  /// Number of days to show starting from [startDate].
  final int daysCount;

  /// Locale string for date formatting (e.g. `"en_US"`).
  final String locale;

  /// Scroll direction of the timeline.
  final DatePickerAxis axis;

  /// Text direction override (for RTL locales).
  final TextDirection? directionality;

  /// Border radius for each date tile and its ink splash.
  final BorderRadius borderRadius;

  const DatePicker(
    this.startDate, {
    super.key,
    this.width,
    this.height,
    this.controller,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.deactivatedColor = AppColors.defaultDeactivatedColor,
    this.initialSelectedDate,
    this.activeDates,
    this.inactiveDates,
    this.daysCount = 365,
    this.onDateChange,
    this.locale = 'en_US',
    this.axis = DatePickerAxis.horizontal,
    this.directionality,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late DateTime _currentDate;
  late double _itemWidth;
  late double _itemHeight;

  final ItemScrollController _scrollController = ItemScrollController();

  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialSelectedDate ?? widget.startDate;
    initializeDateFormatting(widget.locale, null);
    _computeItemSize();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant DatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monthTextStyle != widget.monthTextStyle ||
        oldWidget.dayTextStyle != widget.dayTextStyle ||
        oldWidget.dateTextStyle != widget.dateTextStyle ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.locale != widget.locale) {
      _computeItemSize();
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auto-sizing
  // ---------------------------------------------------------------------------

  /// Computes [_itemWidth] and [_itemHeight] by measuring the largest text span
  /// across all month names, day names, and two-digit date numbers in the
  /// current locale. The result includes internal padding so the selection
  /// background wraps snugly around the content.
  void _computeItemSize() {
    if (widget.width != null && widget.height != null) {
      _itemWidth = widget.width!;
      _itemHeight = widget.height!;
      return;
    }

    // Horizontal padding inside the tile (must match DateWidget).
    const double hPad = 8.0;
    // Vertical padding inside the tile.
    const double vPad = 4.0;
    // Spacing between the three text rows.
    const double spacing = 2.0;

    double maxTextWidth = 0;
    double totalTextHeight = 0;

    // --- Measure month labels ---
    final List<String> months = List.generate(12, (i) {
      final DateTime d = DateTime(2024, i + 1);
      return DateFormat('MMM', widget.locale).format(d).toUpperCase();
    });
    final _MeasureResult monthMeasure = _measureLargest(
      months,
      widget.monthTextStyle,
    );
    maxTextWidth = monthMeasure.width;
    totalTextHeight += monthMeasure.height;

    // --- Measure date numbers (1..31) ---
    final List<String> dates = List.generate(31, (i) => (i + 1).toString());
    final _MeasureResult dateMeasure = _measureLargest(
      dates,
      widget.dateTextStyle,
    );
    if (dateMeasure.width > maxTextWidth) maxTextWidth = dateMeasure.width;
    totalTextHeight += dateMeasure.height;

    // --- Measure day-of-week labels ---
    // Use a week starting from a known Monday (2024-01-01 is Monday).
    final List<String> days = List.generate(7, (i) {
      final DateTime d = DateTime(2024, 1, i + 1);
      return DateFormat('E', widget.locale).format(d).toUpperCase();
    });
    final _MeasureResult dayMeasure = _measureLargest(
      days,
      widget.dayTextStyle,
    );
    if (dayMeasure.width > maxTextWidth) maxTextWidth = dayMeasure.width;
    totalTextHeight += dayMeasure.height;

    // Combine.
    _itemWidth = widget.width ?? (maxTextWidth + hPad * 2);
    _itemHeight = widget.height ?? (totalTextHeight + vPad * 2 + spacing * 2);
  }

  /// Measures every string in [texts] with [style] and returns the max width
  /// and max height across all of them.
  static _MeasureResult _measureLargest(List<String> texts, TextStyle style) {
    double maxW = 0;
    double maxH = 0;
    for (final String t in texts) {
      final TextPainter tp = TextPainter(
        text: TextSpan(text: t, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      if (tp.width > maxW) maxW = tp.width;
      if (tp.height > maxH) maxH = tp.height;
      tp.dispose();
    }
    return _MeasureResult(maxW, maxH);
  }

  // ---------------------------------------------------------------------------
  // Scrolling
  // ---------------------------------------------------------------------------

  int _indexForDate(DateTime date) {
    return date
        .difference(
          DateTime(
            widget.startDate.year,
            widget.startDate.month,
            widget.startDate.day,
          ),
        )
        .inDays
        .clamp(0, widget.daysCount - 1);
  }

  void _scrollToSelection({bool animate = true}) {
    final int idx = _indexForDate(_currentDate);
    if (animate) {
      _scrollController.scrollTo(
        index: idx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(index: idx);
    }
  }

  void _scrollToDate(DateTime date, {bool animate = true}) {
    final int idx = _indexForDate(date);
    if (animate) {
      _scrollController.scrollTo(
        index: idx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(index: idx);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isDeactivated(DateTime date) {
    if (widget.inactiveDates != null) {
      for (final DateTime d in widget.inactiveDates!) {
        if (_isSameDay(date, d)) return true;
      }
    }
    if (widget.activeDates != null) {
      for (final DateTime d in widget.activeDates!) {
        if (_isSameDay(date, d)) return false;
      }
      return true; // not in active list → deactivated
    }
    return false;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // The total cross-axis extent (height for horizontal, width for vertical)
    // includes item size + margin from DateWidget (3.0 on each side).
    const double margin = 3.0 * 2;

    final Axis scrollAxis = widget.axis == DatePickerAxis.horizontal
        ? Axis.horizontal
        : Axis.vertical;

    // After the first frame, scroll to the initial selection.
    if (!_initialScrollDone) {
      _initialScrollDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.isAttached) {
          _scrollToSelection(animate: false);
        }
      });
    }

    Widget list = ScrollablePositionedList.builder(
      itemScrollController: _scrollController,
      scrollDirection: scrollAxis,
      itemCount: widget.daysCount,
      initialScrollIndex: _indexForDate(_currentDate),
      itemBuilder: (context, index) {
        final DateTime date = DateTime(
          widget.startDate.year,
          widget.startDate.month,
          widget.startDate.day + index,
        );
        final bool selected = _isSameDay(date, _currentDate);
        final bool deactivated = _isDeactivated(date);

        return DateWidget(
          date: date,
          width: _itemWidth,
          height: _itemHeight,
          monthTextStyle: widget.monthTextStyle,
          dayTextStyle: widget.dayTextStyle,
          dateTextStyle: widget.dateTextStyle,
          selectionColor: widget.selectionColor,
          selectedTextColor: widget.selectedTextColor,
          deactivatedColor: widget.deactivatedColor,
          locale: widget.locale,
          isSelected: selected,
          isDeactivated: deactivated,
          borderRadius: widget.borderRadius,
          onDateSelected: (selectedDate) {
            if (!_isSameDay(selectedDate, _currentDate)) {
              setState(() => _currentDate = selectedDate);
              widget.onDateChange?.call(selectedDate);
            }
          },
        );
      },
    );

    // Apply directionality override if provided.
    if (widget.directionality != null) {
      list = Directionality(textDirection: widget.directionality!, child: list);
    }

    // Constrain the cross-axis extent so the widget sizes itself.
    if (widget.axis == DatePickerAxis.horizontal) {
      return SizedBox(height: _itemHeight + margin, child: list);
    } else {
      return SizedBox(width: _itemWidth + margin, child: list);
    }
  }
}

/// Internal helper to carry two measurement values.
class _MeasureResult {
  final double width;
  final double height;
  const _MeasureResult(this.width, this.height);
}
