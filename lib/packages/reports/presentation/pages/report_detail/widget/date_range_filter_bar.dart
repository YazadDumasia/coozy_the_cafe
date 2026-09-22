import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

enum DateRangePreset { today, thisWeek, thisMonth, last30Days, custom }

class DateRangeFilterBar extends StatefulWidget {
  const DateRangeFilterBar({
    super.key,
    required this.onRangeChanged,
    this.initialPreset = DateRangePreset.last30Days,
  });

  final ValueChanged<DateTimeRange> onRangeChanged;
  final DateRangePreset initialPreset;

  @override
  State<DateRangeFilterBar> createState() => _DateRangeFilterBarState();
}

class _DateRangeFilterBarState extends State<DateRangeFilterBar> {
  late final ValueNotifier<DateRangePreset> _selectedNotifier;

  @override
  void initState() {
    super.initState();
    _selectedNotifier = ValueNotifier<DateRangePreset>(widget.initialPreset);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.onRangeChanged(_rangeFor(_selectedNotifier.value)),
    );
  }

  @override
  void dispose() {
    _selectedNotifier.dispose();
    super.dispose();
  }

  DateTimeRange _rangeFor(DateRangePreset preset) {
    final now = DateTime.now();
    return switch (preset) {
      DateRangePreset.today => DateTimeRange(
        start: DateUtil.startOfDay(now),
        end: DateUtil.endOfDay(now),
      ),
      DateRangePreset.thisWeek => DateTimeRange(
        start: DateUtil.startOfWeek(now),
        end: DateUtil.endOfDay(now),
      ),
      DateRangePreset.thisMonth => DateTimeRange(
        start: DateTime.utc(now.year, now.month, 1),
        end: DateUtil.endOfDay(now),
      ),
      DateRangePreset.last30Days => DateTimeRange(
        start: DateUtil.startOfDay(now.subtract(const Duration(days: 29))),
        end: DateUtil.endOfDay(now),
      ),
      DateRangePreset.custom => DateTimeRange(
        start: DateUtil.startOfDay(now.subtract(const Duration(days: 29))),
        end: DateUtil.endOfDay(now),
      ),
    };
  }

  Future<void> _pickCustomRange() async {
    final currentRange = _rangeFor(_selectedNotifier.value);
    final result = await shared.DateRangeFilterDialog.showBottomSheet(
      context: context,
      initialFromDate: currentRange.start,
      initialToDate: currentRange.end,
      title:
          context.tr(
            shared.LocaleKeys.commonFilterByDate,
            track: shared.TrackConstants.commonTrack,
          ) ??
          'FILTER BY DATE',
    );
    if (result != null) {
      widget.onRangeChanged(
        DateTimeRange(start: result.fromDate, end: result.toDate),
      );
    }
  }

  void _select(DateRangePreset preset) {
    _selectedNotifier.value = preset;
    if (preset == DateRangePreset.custom) {
      _pickCustomRange();
    } else {
      widget.onRangeChanged(_rangeFor(preset));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final todayLabel =
        context.tr(
          shared.LocaleKeys.reportPagePresetToday,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'Today';
    final thisWeekLabel =
        context.tr(
          shared.LocaleKeys.reportPagePresetThisWeek,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'This Week';
    final thisMonthLabel =
        context.tr(
          shared.LocaleKeys.reportPagePresetThisMonth,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'This Month';
    final last30DaysLabel =
        context.tr(
          shared.LocaleKeys.reportPagePresetLast30Days,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'Last 30 Days';
    final customLabel =
        context.tr(
          shared.LocaleKeys.reportPagePresetCustom,
          track: shared.TrackConstants.reportPageTrack,
        ) ??
        'Custom';

    return ValueListenableBuilder<DateRangePreset>(
      valueListenable: _selectedNotifier,
      builder: (context, selectedPreset, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildChip(
                todayLabel,
                DateRangePreset.today,
                selectedPreset,
                scheme,
              ),
              const SizedBox(width: 8),
              _buildChip(
                thisWeekLabel,
                DateRangePreset.thisWeek,
                selectedPreset,
                scheme,
              ),
              const SizedBox(width: 8),
              _buildChip(
                thisMonthLabel,
                DateRangePreset.thisMonth,
                selectedPreset,
                scheme,
              ),
              const SizedBox(width: 8),
              _buildChip(
                last30DaysLabel,
                DateRangePreset.last30Days,
                selectedPreset,
                scheme,
              ),
              const SizedBox(width: 8),
              _buildChip(
                customLabel,
                DateRangePreset.custom,
                selectedPreset,
                scheme,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(
    String label,
    DateRangePreset preset,
    DateRangePreset selectedPreset,
    ColorScheme scheme,
  ) {
    final isSelected = selectedPreset == preset;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _select(preset),
      selectedColor: scheme.primary.withValues(alpha: 0.18),
      checkmarkColor: scheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? scheme.primary : scheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? scheme.primary : scheme.outlineVariant,
      ),
    );
  }
}
