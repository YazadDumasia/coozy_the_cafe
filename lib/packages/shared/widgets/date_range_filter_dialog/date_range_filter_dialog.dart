/// # DateRangeFilterDialog Usage Guide
///
/// A multipurpose date & date-range filter widget supporting full-screen,
/// modal bottom-sheet, centered popup dialog, and embedded presentation modes.
/// Returns a [DateRangeFilterResult] containing [fromDate] and [toDate].
///
/// ---
///
/// ### 1. Full-Screen Dialog View
/// ```dart
/// final result = await shared.DateRangeFilterDialog.showFullScreen(
///   context: context,
///   initialFromDate: DateTime.now().subtract(const Duration(days: 7)),
///   initialToDate: DateTime.now(),
///   title: 'FILTER BY DATE',
///   submitButtonText: 'Submit', // optional: defaults to 'Submit'
/// );
///
/// if (result != null) {
///   print('From Date: ${result.fromDate}');
///   print('To Date: ${result.toDate}');
///   print('Total Days: ${result.totalDays}');
///   print('Formatted: ${result.format()}'); // e.g. "12 Sep 2026 - 18 Sep 2026"
/// }
/// ```
///
/// ### 2. Modal Bottom-Sheet View
/// ```dart
/// final result = await shared.DateRangeFilterDialog.showBottomSheet(
///   context: context,
///   initialFromDate: currentFromDate,
///   initialToDate: currentToDate,
/// );
///
/// if (result != null) {
///   final from = result.fromDate;
///   final to = result.toDate;
/// }
/// ```
///
/// ### 3. Centered Popup Card Dialog
/// ```dart
/// final result = await shared.DateRangeFilterDialog.showPopupDialog(
///   context: context,
///   initialFromDate: currentFromDate,
///   initialToDate: currentToDate,
/// );
/// ```
///
/// ### 4. Single Date Picker Mode (Not a Range)
/// ```dart
/// final result = await shared.DateRangeFilterDialog.showFullScreen(
///   context: context,
///   isRangeMode: false, // Disables To Date
///   initialFromDate: DateTime.now(),
///   title: 'Select Date',
/// );
///
/// if (result != null) {
///   print('Selected Date: ${result.fromDate}');
/// }
/// ```
///
/// ### 5. Generic Launcher with Options
/// ```dart
/// final result = await shared.DateRangeFilterDialog.show(
///   context: context,
///   asBottomSheet: true, // or asPopupDialog: true
///   showPresets: true,   // show/hide preset buttons (Today, Yesterday, etc.)
///   showClearButton: true, // optional Reset / Clear action
///   initialFromDate: currentFrom,
///   initialToDate: currentTo,
/// );
/// ```
///
/// ### 6. Accessing Returned Data
/// - Strongly-typed getters: `result.fromDate`, `result.toDate`
/// - Aliases: `result.startDate`, `result.endDate`
/// - Active preset info: `result.selectedPreset` (e.g. `DateRangePreset.thisWeek`)
/// - Map conversion / Index access: `result['fromDate']`, `result['toDate']`, `result.toMap()`
library;

import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

/// Display presentation style for [DateRangeFilterDialog].
enum DateRangeFilterDisplayType {
  fullScreen,
  bottomSheet,
  popupDialog,
  embedded,
}

/// Available preset date ranges.
enum DateRangePreset {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  lastYear,
}

/// Result returned from [DateRangeFilterDialog].
/// Contains [fromDate] and [toDate], plus helper getters and backward-compatible
/// index operator / [toMap] support.
class DateRangeFilterResult {
  final DateTime fromDate;
  final DateTime toDate;
  final DateRangePreset? selectedPreset;

  const DateRangeFilterResult({
    required this.fromDate,
    required this.toDate,
    this.selectedPreset,
  });

  /// Alias for [fromDate]
  DateTime get startDate => fromDate;

  /// Alias for [toDate]
  DateTime get endDate => toDate;

  /// Total days included in the range (inclusive).
  int get totalDays {
    final start = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final end = DateTime(toDate.year, toDate.month, toDate.day);
    return end.difference(start).inDays + 1;
  }

  /// Whether the range represents a single calendar day.
  bool get isSingleDay =>
      fromDate.year == toDate.year &&
      fromDate.month == toDate.month &&
      fromDate.day == toDate.day;

  /// Formatted range string using [dateFormat] (default 'dd MMM yyyy').
  String format([String dateFormat = 'dd MMM yyyy']) {
    final fromStr = DateUtil.localFormatDateTime(fromDate, dateFormat) ?? '';
    if (isSingleDay) return fromStr;
    final toStr = DateUtil.localFormatDateTime(toDate, dateFormat) ?? '';
    return '$fromStr - $toStr';
  }

  Map<String, dynamic> toMap() => {
    'fromDate': fromDate,
    'toDate': toDate,
    'startDate': fromDate,
    'endDate': toDate,
    'selectedPreset': selectedPreset?.name,
    'totalDays': totalDays,
    'isSingleDay': isSingleDay,
  };

  dynamic operator [](String key) {
    if (key == 'fromDate' || key == 'startDate') return fromDate;
    if (key == 'toDate' || key == 'endDate') return toDate;
    if (key == 'selectedPreset') return selectedPreset;
    if (key == 'totalDays') return totalDays;
    if (key == 'isSingleDay') return isSingleDay;
    return null;
  }

  @override
  String toString() =>
      'DateRangeFilterResult(fromDate: $fromDate, toDate: $toDate, preset: $selectedPreset)';
}

/// A versatile, multi-purpose date and date-range filter widget.
///
/// Can be presented in four display types:
/// - **Full Screen** ([showFullScreen]): Full-screen layout matching the initial design.
/// - **Bottom Sheet** ([showBottomSheet]): Modal bottom sheet dialog.
/// - **Popup Dialog** ([showPopupDialog]): Centered modal card popup.
/// - **Embedded** ([displayType]: [DateRangeFilterDisplayType.embedded]): Embedded inside a page.
class DateRangeFilterDialog extends StatefulWidget {
  final DateTime? initialFromDate;
  final DateTime? initialToDate;

  /// Backwards-compatible alias for [initialFromDate]
  final DateTime? initialStartDate;

  /// Backwards-compatible alias for [initialToDate]
  final DateTime? initialEndDate;

  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Date formatting pattern. Defaults to `'dd MMM yyyy'`.
  final String dateFormat;

  /// If true (default), both From and To dates are selected.
  /// If false, only a single date is selected.
  final bool isRangeMode;

  /// Whether to show the quick preset buttons. Default is true.
  final bool showPresets;

  /// Optional custom list of presets to display. Defaults to all 8 standard presets.
  final List<DateRangePreset>? customPresets;

  /// Whether to show a "Clear / Reset" button. Default is false.
  final bool showClearButton;

  final String? title;
  final String? subtitle;
  final String? fromDateLabel;
  final String? toDateLabel;
  final String? submitButtonText;
  final String? clearButtonText;

  /// Display presentation style. Default is [DateRangeFilterDisplayType.fullScreen].
  final DateRangeFilterDisplayType displayType;

  /// Backwards-compatible flag for bottom sheet mode.
  final bool isBottomSheet;

  /// Optional callback executed upon applying selection.
  final void Function(DateRangeFilterResult result)? onApply;

  /// Optional callback executed when clear / reset is pressed.
  final VoidCallback? onClear;

  const DateRangeFilterDialog({
    super.key,
    this.initialFromDate,
    this.initialToDate,
    this.initialStartDate,
    this.initialEndDate,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'dd MMM yyyy',
    this.isRangeMode = true,
    this.showPresets = true,
    this.customPresets,
    this.showClearButton = false,
    this.title,
    this.subtitle,
    this.fromDateLabel,
    this.toDateLabel,
    this.submitButtonText,
    this.clearButtonText,
    this.displayType = DateRangeFilterDisplayType.fullScreen,
    this.isBottomSheet = false,
    this.onApply,
    this.onClear,
  });

  /// Opens the filter in a **Full Screen Dialog** route.
  static Future<DateRangeFilterResult?> showFullScreen({
    required BuildContext context,
    DateTime? initialFromDate,
    DateTime? initialToDate,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String dateFormat = 'dd MMM yyyy',
    bool isRangeMode = true,
    bool showPresets = true,
    List<DateRangePreset>? customPresets,
    bool showClearButton = false,
    String? title,
    String? subtitle,
    String? fromDateLabel,
    String? toDateLabel,
    String? submitButtonText,
    String? clearButtonText,
    void Function(DateRangeFilterResult result)? onApply,
    VoidCallback? onClear,
  }) {
    return Navigator.of(context).push<DateRangeFilterResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DateRangeFilterDialog(
          initialFromDate: initialFromDate,
          initialToDate: initialToDate,
          initialStartDate: initialStartDate,
          initialEndDate: initialEndDate,
          firstDate: firstDate,
          lastDate: lastDate,
          dateFormat: dateFormat,
          isRangeMode: isRangeMode,
          showPresets: showPresets,
          customPresets: customPresets,
          showClearButton: showClearButton,
          title: title,
          subtitle: subtitle,
          fromDateLabel: fromDateLabel,
          toDateLabel: toDateLabel,
          submitButtonText: submitButtonText,
          clearButtonText: clearButtonText,
          displayType: DateRangeFilterDisplayType.fullScreen,
          onApply: onApply,
          onClear: onClear,
        ),
      ),
    );
  }

  /// Opens the filter in a **Modal Bottom Sheet**.
  static Future<DateRangeFilterResult?> showBottomSheet({
    required BuildContext context,
    DateTime? initialFromDate,
    DateTime? initialToDate,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String dateFormat = 'dd MMM yyyy',
    bool isRangeMode = true,
    bool showPresets = true,
    List<DateRangePreset>? customPresets,
    bool showClearButton = false,
    String? title,
    String? subtitle,
    String? fromDateLabel,
    String? toDateLabel,
    String? submitButtonText,
    String? clearButtonText,
    void Function(DateRangeFilterResult result)? onApply,
    VoidCallback? onClear,
  }) {
    return showModalBottomSheet<DateRangeFilterResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DateRangeFilterDialog(
        initialFromDate: initialFromDate,
        initialToDate: initialToDate,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        firstDate: firstDate,
        lastDate: lastDate,
        dateFormat: dateFormat,
        isRangeMode: isRangeMode,
        showPresets: showPresets,
        customPresets: customPresets,
        showClearButton: showClearButton,
        title: title,
        subtitle: subtitle,
        fromDateLabel: fromDateLabel,
        toDateLabel: toDateLabel,
        submitButtonText: submitButtonText,
        clearButtonText: clearButtonText,
        displayType: DateRangeFilterDisplayType.bottomSheet,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }

  /// Opens the filter in a **Centered Modal Popup Dialog**.
  static Future<DateRangeFilterResult?> showPopupDialog({
    required BuildContext context,
    DateTime? initialFromDate,
    DateTime? initialToDate,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String dateFormat = 'dd MMM yyyy',
    bool isRangeMode = true,
    bool showPresets = true,
    List<DateRangePreset>? customPresets,
    bool showClearButton = false,
    String? title,
    String? subtitle,
    String? fromDateLabel,
    String? toDateLabel,
    String? submitButtonText,
    String? clearButtonText,
    void Function(DateRangeFilterResult result)? onApply,
    VoidCallback? onClear,
  }) {
    return showDialog<DateRangeFilterResult>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
          child: DateRangeFilterDialog(
            initialFromDate: initialFromDate,
            initialToDate: initialToDate,
            initialStartDate: initialStartDate,
            initialEndDate: initialEndDate,
            firstDate: firstDate,
            lastDate: lastDate,
            dateFormat: dateFormat,
            isRangeMode: isRangeMode,
            showPresets: showPresets,
            customPresets: customPresets,
            showClearButton: showClearButton,
            title: title,
            subtitle: subtitle,
            fromDateLabel: fromDateLabel,
            toDateLabel: toDateLabel,
            submitButtonText: submitButtonText,
            clearButtonText: clearButtonText,
            displayType: DateRangeFilterDisplayType.popupDialog,
            onApply: onApply,
            onClear: onClear,
          ),
        ),
      ),
    );
  }

  /// Generic launcher helper. Defaults to full screen, or bottom sheet if [asBottomSheet] is true.
  static Future<DateRangeFilterResult?> show({
    required BuildContext context,
    DateTime? initialFromDate,
    DateTime? initialToDate,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String dateFormat = 'dd MMM yyyy',
    bool isRangeMode = true,
    bool showPresets = true,
    List<DateRangePreset>? customPresets,
    bool showClearButton = false,
    String? title,
    String? subtitle,
    String? fromDateLabel,
    String? toDateLabel,
    String? submitButtonText,
    String? clearButtonText,
    bool asBottomSheet = false,
    bool asPopupDialog = false,
    void Function(DateRangeFilterResult result)? onApply,
    VoidCallback? onClear,
  }) {
    if (asPopupDialog) {
      return showPopupDialog(
        context: context,
        initialFromDate: initialFromDate,
        initialToDate: initialToDate,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        firstDate: firstDate,
        lastDate: lastDate,
        dateFormat: dateFormat,
        isRangeMode: isRangeMode,
        showPresets: showPresets,
        customPresets: customPresets,
        showClearButton: showClearButton,
        title: title,
        subtitle: subtitle,
        fromDateLabel: fromDateLabel,
        toDateLabel: toDateLabel,
        submitButtonText: submitButtonText,
        clearButtonText: clearButtonText,
        onApply: onApply,
        onClear: onClear,
      );
    }
    if (asBottomSheet) {
      return showBottomSheet(
        context: context,
        initialFromDate: initialFromDate,
        initialToDate: initialToDate,
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        firstDate: firstDate,
        lastDate: lastDate,
        dateFormat: dateFormat,
        isRangeMode: isRangeMode,
        showPresets: showPresets,
        customPresets: customPresets,
        showClearButton: showClearButton,
        title: title,
        subtitle: subtitle,
        fromDateLabel: fromDateLabel,
        toDateLabel: toDateLabel,
        submitButtonText: submitButtonText,
        clearButtonText: clearButtonText,
        onApply: onApply,
        onClear: onClear,
      );
    }
    return showFullScreen(
      context: context,
      initialFromDate: initialFromDate,
      initialToDate: initialToDate,
      initialStartDate: initialStartDate,
      initialEndDate: initialEndDate,
      firstDate: firstDate,
      lastDate: lastDate,
      dateFormat: dateFormat,
      isRangeMode: isRangeMode,
      showPresets: showPresets,
      customPresets: customPresets,
      showClearButton: showClearButton,
      title: title,
      subtitle: subtitle,
      fromDateLabel: fromDateLabel,
      toDateLabel: toDateLabel,
      submitButtonText: submitButtonText,
      clearButtonText: clearButtonText,
      onApply: onApply,
      onClear: onClear,
    );
  }

  @override
  State<DateRangeFilterDialog> createState() => _DateRangeFilterDialogState();
}

class _DateRangeFilterDialogState extends State<DateRangeFilterDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final ValueNotifier<DateTime> _fromDateNotifier;
  late final ValueNotifier<DateTime> _toDateNotifier;
  DateRangePreset? _selectedPreset;

  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late final FocusNode _fromFocusNode;
  late final FocusNode _toFocusNode;

  DateRangeFilterDisplayType get _effectiveDisplayType {
    if (widget.isBottomSheet) {
      return DateRangeFilterDisplayType.bottomSheet;
    }
    return widget.displayType;
  }

  @override
  void initState() {
    super.initState();
    final initialFrom =
        widget.initialFromDate ?? widget.initialStartDate ?? DateTime.now();
    final initialTo =
        widget.initialToDate ?? widget.initialEndDate ?? DateTime.now();

    _fromDateNotifier = ValueNotifier<DateTime>(initialFrom);
    _toDateNotifier = ValueNotifier<DateTime>(initialTo);

    _fromController = TextEditingController();
    _toController = TextEditingController();
    _fromFocusNode = FocusNode();
    _toFocusNode = FocusNode();

    _updateControllerTexts(initialFrom, initialTo);
  }

  void _updateControllerTexts(DateTime from, DateTime to) {
    _fromController.text =
        DateUtil.localFormatDateTime(from, widget.dateFormat) ?? '';
    _toController.text =
        DateUtil.localFormatDateTime(to, widget.dateFormat) ?? '';
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    _fromDateNotifier.dispose();
    _toDateNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDateNotifier.value,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      _selectedPreset = null;
      _fromDateNotifier.value = picked;
      if (!widget.isRangeMode || _toDateNotifier.value.isBefore(picked)) {
        _toDateNotifier.value = picked;
      }
      _updateControllerTexts(_fromDateNotifier.value, _toDateNotifier.value);
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDateNotifier.value,
      firstDate: _fromDateNotifier.value,
      lastDate: widget.lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      _selectedPreset = null;
      _toDateNotifier.value = picked;
      _updateControllerTexts(_fromDateNotifier.value, _toDateNotifier.value);
    }
  }

  void _setPresetRange(DateRangePreset preset) {
    final now = DateTime.now();
    DateTime from = now;
    DateTime to = now;

    switch (preset) {
      case DateRangePreset.today:
        from = DateTime(now.year, now.month, now.day);
        to = from;
        break;
      case DateRangePreset.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        from = DateTime(yesterday.year, yesterday.month, yesterday.day);
        to = from;
        break;
      case DateRangePreset.thisWeek:
        from = now.subtract(Duration(days: now.weekday - 1));
        to = now;
        break;
      case DateRangePreset.lastWeek:
        final lastWeekDay = now.subtract(Duration(days: now.weekday + 6));
        from = lastWeekDay;
        to = lastWeekDay.add(const Duration(days: 6));
        break;
      case DateRangePreset.thisMonth:
        from = DateTime(now.year, now.month, 1);
        to = now;
        break;
      case DateRangePreset.lastMonth:
        from = DateTime(now.year, now.month - 1, 1);
        to = DateTime(now.year, now.month, 0);
        break;
      case DateRangePreset.thisYear:
        from = DateTime(now.year, 1, 1);
        to = now;
        break;
      case DateRangePreset.lastYear:
        from = DateTime(now.year - 1, 1, 1);
        to = DateTime(now.year - 1, 12, 31);
        break;
    }

    _selectedPreset = preset;
    _fromDateNotifier.value = from;
    _toDateNotifier.value = widget.isRangeMode ? to : from;
    _updateControllerTexts(_fromDateNotifier.value, _toDateNotifier.value);
  }

  void _submitSelection() {
    final result = DateRangeFilterResult(
      fromDate: _fromDateNotifier.value,
      toDate: widget.isRangeMode
          ? _toDateNotifier.value
          : _fromDateNotifier.value,
      selectedPreset: _selectedPreset,
    );
    widget.onApply?.call(result);
    if (_effectiveDisplayType != DateRangeFilterDisplayType.embedded) {
      Navigator.of(context).pop(result);
    }
  }

  void _clearSelection() {
    widget.onClear?.call();
    if (_effectiveDisplayType != DateRangeFilterDisplayType.embedded) {
      Navigator.of(context).pop(null);
    }
  }

  String _getPresetLabel(BuildContext context, DateRangePreset preset) {
    switch (preset) {
      case DateRangePreset.today:
        return context.tr(
              shared.LocaleKeys.commonToday,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Today';
      case DateRangePreset.yesterday:
        return context.tr(
              shared.LocaleKeys.commonYesterday,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Yesterday';
      case DateRangePreset.thisWeek:
        return context.tr(
              shared.LocaleKeys.commonThisWeek,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'This Week';
      case DateRangePreset.lastWeek:
        return context.tr(
              shared.LocaleKeys.commonLastWeek,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Last Week';
      case DateRangePreset.thisMonth:
        return context.tr(
              shared.LocaleKeys.commonThisMonth,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'This Month';
      case DateRangePreset.lastMonth:
        return context.tr(
              shared.LocaleKeys.commonLastMonth,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Last Month';
      case DateRangePreset.thisYear:
        return context.tr(
              shared.LocaleKeys.commonThisYear,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'This Year';
      case DateRangePreset.lastYear:
        return context.tr(
              shared.LocaleKeys.commonLastYear,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Last Year';
    }
  }

  Widget _buildFormContent({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    required String resolvedSubtitle,
    required String resolvedFromLabel,
    required String resolvedToLabel,
    required String resolvedSubmitText,
    required String resolvedClearText,
  }) {
    final presets = widget.customPresets ?? DateRangePreset.values;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            resolvedSubtitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Start Date / From Date Input
          InkWell(
            onTap: _pickFromDate,
            borderRadius: BorderRadius.circular(8),
            child: IgnorePointer(
              child: ValueListenableBuilder<DateTime>(
                valueListenable: _fromDateNotifier,
                builder: (context, fromDate, child) {
                  return TextFormField(
                    controller: _fromController,
                    focusNode: _fromFocusNode,
                    decoration: InputDecoration(
                      labelText: resolvedFromLabel,
                      hintText: resolvedFromLabel,
                      border: const UnderlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),

          // End Date / To Date Input (shown in range mode)
          if (widget.isRangeMode) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickToDate,
              borderRadius: BorderRadius.circular(8),
              child: IgnorePointer(
                child: ValueListenableBuilder<DateTime>(
                  valueListenable: _toDateNotifier,
                  builder: (context, toDate, child) {
                    return TextFormField(
                      controller: _toController,
                      focusNode: _toFocusNode,
                      decoration: InputDecoration(
                        labelText: resolvedToLabel,
                        hintText: resolvedToLabel,
                        border: const UnderlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_month_outlined),
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Primary Submit Button (+ optional Clear button)
          if (widget.showClearButton)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: _clearSelection,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: isDark ? 0.4 : 0.7,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      resolvedClearText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _submitSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      resolvedSubmitText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: _submitSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                resolvedSubmitText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

          // 2-Column Preset Grid matching original design
          if (widget.showPresets && presets.isNotEmpty) ...[
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: presets.map((preset) {
                    return SizedBox(
                      width: width,
                      child: OutlinedButton(
                        onPressed: () => _setPresetRange(preset),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.cardColor,
                          side: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: isDark ? 0.3 : 0.6,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _getPresetLabel(context, preset),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final resolvedTitle =
        widget.title ??
        context.tr(
          shared.LocaleKeys.commonFilterByDate,
          track: shared.TrackConstants.commonTrack,
        ) ??
        'FILTER BY DATE';

    final resolvedSubtitle =
        widget.subtitle ??
        context.tr(
          shared.LocaleKeys.commonSelectDateRange,
          track: shared.TrackConstants.commonTrack,
        ) ??
        'Select Date Range';

    final resolvedFromLabel =
        widget.fromDateLabel ??
        (widget.isRangeMode
            ? (context.tr(
                    shared.LocaleKeys.commonFromDate,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  context.tr(
                    shared.LocaleKeys.commonStartDate,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Start Date')
            : (context.tr(
                    shared.LocaleKeys.commonSelectDateRange,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Select Date'));

    final resolvedToLabel =
        widget.toDateLabel ??
        context.tr(
          shared.LocaleKeys.commonToDate,
          track: shared.TrackConstants.commonTrack,
        ) ??
        context.tr(
          shared.LocaleKeys.commonEndDate,
          track: shared.TrackConstants.commonTrack,
        ) ??
        'End Date';

    final resolvedSubmitText =
        widget.submitButtonText ??
        context.tr(
          shared.LocaleKeys.commonSubmit,
          track: shared.TrackConstants.commonTrack,
        ) ??
        'Submit';

    final resolvedClearText =
        widget.clearButtonText ??
        context.tr(
          shared.LocaleKeys.commonClear,
          track: shared.TrackConstants.commonTrack,
        ) ??
        'Clear';

    // 1. Embedded display type
    if (_effectiveDisplayType == DateRangeFilterDisplayType.embedded) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildFormContent(
          context: context,
          theme: theme,
          colorScheme: colorScheme,
          isDark: isDark,
          resolvedSubtitle: resolvedSubtitle,
          resolvedFromLabel: resolvedFromLabel,
          resolvedToLabel: resolvedToLabel,
          resolvedSubmitText: resolvedSubmitText,
          resolvedClearText: resolvedClearText,
        ),
      );
    }

    // 2. Popup Modal Card Dialog
    if (_effectiveDisplayType == DateRangeFilterDisplayType.popupDialog) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    resolvedTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip:
                      context.tr(
                        shared.LocaleKeys.commonClose,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildFormContent(
                context: context,
                theme: theme,
                colorScheme: colorScheme,
                isDark: isDark,
                resolvedSubtitle: resolvedSubtitle,
                resolvedFromLabel: resolvedFromLabel,
                resolvedToLabel: resolvedToLabel,
                resolvedSubmitText: resolvedSubmitText,
                resolvedClearText: resolvedClearText,
              ),
            ),
          ),
        ],
      );
    }

    // 3. Bottom Sheet View
    if (_effectiveDisplayType == DateRangeFilterDisplayType.bottomSheet) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.5 : 0.8,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip:
                        context.tr(
                          shared.LocaleKeys.commonClose,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      resolvedTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildFormContent(
                  context: context,
                  theme: theme,
                  colorScheme: colorScheme,
                  isDark: isDark,
                  resolvedSubtitle: resolvedSubtitle,
                  resolvedFromLabel: resolvedFromLabel,
                  resolvedToLabel: resolvedToLabel,
                  resolvedSubmitText: resolvedSubmitText,
                  resolvedClearText: resolvedClearText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 4. Full-Screen Dialog View matching original design
    return SafeArea(
      child: Theme(
        data: Theme.of(context),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip:
                  context.tr(
                    shared.LocaleKeys.commonClose,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Close',
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(resolvedTitle),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildFormContent(
              context: context,
              theme: theme,
              colorScheme: colorScheme,
              isDark: isDark,
              resolvedSubtitle: resolvedSubtitle,
              resolvedFromLabel: resolvedFromLabel,
              resolvedToLabel: resolvedToLabel,
              resolvedSubmitText: resolvedSubmitText,
              resolvedClearText: resolvedClearText,
            ),
          ),
        ),
      ),
    );
  }
}
