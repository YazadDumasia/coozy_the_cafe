import 'package:flutter/material.dart';
import '../dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'controllers/time_line_picker_controller.dart';
import 'extra/color.dart';
import 'extra/style.dart';
import 'models/time_line_picker_enums.dart';
import 'models/time_slot.dart';
import 'widgets/time_slot_item.dart';

typedef TimeSlotBuilder =
    Widget Function(
      BuildContext context,
      TimeSlot slot,
      bool isSelected,
      bool isDisabled,
      VoidCallback onTap,
    );

class TimePickerAxis {
  static const TimelineLayoutMode horizontal = TimelineLayoutMode.horizontal;
  static const TimelineLayoutMode vertical = TimelineLayoutMode.vertical;
}

class TimeLinePicker extends StatefulWidget {
  /// Start time for the timeline
  final TimeOfDay startTime;

  /// End time for the timeline
  final TimeOfDay endTime;

  /// Interval duration between time slots (e.g. Duration(minutes: 30))
  final Duration interval;

  /// Width per time tile. When null, auto-computed.
  final double? width;

  /// Height per time tile. When null, auto-computed.
  final double? height;

  /// Controller for programmatic selection and scrolling
  final TimeLinePickerController? controller;

  /// Color applied to text of selected slot
  final Color selectedTextColor;

  /// Background selection color
  final Color selectionColor;

  /// Text color applied to deactivated/disabled slots
  final Color deactivatedColor;

  /// Text style for main hour label
  final TextStyle hourTextStyle;

  /// Text style for period (AM/PM) label
  final TextStyle periodTextStyle;

  /// Text style for time range label
  final TextStyle rangeTextStyle;

  /// Initial selected time slot
  final TimeSlot? initialSelectedSlot;

  /// Initial selected slots list
  final List<TimeSlot>? initialSelectedSlots;

  /// List of inactive time slots
  final List<TimeSlot>? inactiveTimeSlots;

  /// List of active time slots (all others will be inactive)
  final List<TimeSlot>? activeTimeSlots;

  /// Optional custom time slots list overriding startTime/endTime generation
  final List<TimeSlot>? customTimeSlots;

  /// Predicate for disabling specific slots
  final bool Function(TimeSlot slot)? isSlotDisabled;

  /// Layout style: horizontal, vertical, grid, or wrap
  final TimelineLayoutMode layoutMode;

  /// Selection mode: single, multiple, range
  final TimeSelectionMode selectionMode;

  /// Callback when selection changes
  final ValueChanged<List<TimeSlot>>? onChange;

  /// Callback when a single slot is tapped
  final ValueChanged<TimeSlot>? onSlotTap;

  /// Cross axis count for Grid layout
  final int gridCrossAxisCount;

  /// Spacing between items
  final double spacing;

  /// Run spacing between lines in Wrap or Grid
  final double runSpacing;

  /// Use 24-hour format vs 12-hour AM/PM format
  final bool use24HourFormat;

  /// Show end time in slot label
  final bool showEndTime;

  /// Border radius for date tiles
  final BorderRadius borderRadius;

  /// Custom item builder
  final TimeSlotBuilder? itemBuilder;

  /// Additional custom item styling
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final TextStyle? disabledTextStyle;
  final Color? selectedBackgroundColor;
  final Color? unselectedBackgroundColor;
  final Color? disabledBackgroundColor;
  final Border? selectedBorder;
  final Border? unselectedBorder;
  final EdgeInsetsGeometry? itemPadding;
  final EdgeInsetsGeometry? itemMargin;
  final EdgeInsetsGeometry? containerPadding;
  final List<BoxShadow>? itemShadows;
  final Widget? slotIcon;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const TimeLinePicker({
    super.key,
    this.startTime = const TimeOfDay(hour: 0, minute: 0),
    this.endTime = const TimeOfDay(hour: 23, minute: 59),
    this.interval = const Duration(minutes: 30),
    this.width,
    this.height,
    this.controller,
    this.hourTextStyle = defaultHourTextStyle,
    this.periodTextStyle = defaultPeriodTextStyle,
    this.rangeTextStyle = defaultRangeTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = TimePickerColors.defaultSelectionColor,
    this.deactivatedColor = TimePickerColors.defaultDeactivatedColor,
    this.initialSelectedSlot,
    this.initialSelectedSlots,
    this.inactiveTimeSlots,
    this.activeTimeSlots,
    this.customTimeSlots,
    this.isSlotDisabled,
    this.layoutMode = TimelineLayoutMode.horizontal,
    this.selectionMode = TimeSelectionMode.single,
    this.onChange,
    this.onSlotTap,
    this.gridCrossAxisCount = 3,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.use24HourFormat = false,
    this.showEndTime = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.itemBuilder,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.disabledTextStyle,
    this.selectedBackgroundColor,
    this.unselectedBackgroundColor,
    this.disabledBackgroundColor,
    this.selectedBorder,
    this.unselectedBorder,
    this.itemPadding,
    this.itemMargin,
    this.containerPadding,
    this.itemShadows,
    this.slotIcon,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  State<TimeLinePicker> createState() => _TimeLinePickerState();
}

class _TimeLinePickerState extends State<TimeLinePicker> {
  late TimeLinePickerController _controller;
  late List<TimeSlot> _timeSlots;
  late ScrollController _scrollController;
  bool _internalControllerCreated = false;
  TimeSlot? _rangeStartSlot;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initController();
    _generateSlots();

    if (widget.initialSelectedSlot != null) {
      _controller.selectSlot(widget.initialSelectedSlot!);
    } else if (widget.initialSelectedSlots != null &&
        widget.initialSelectedSlots!.isNotEmpty) {
      _controller.selectSlots(widget.initialSelectedSlots!);
    }
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TimeLinePickerController();
      _internalControllerCreated = true;
    }
    _controller.attachScrollController(_scrollController);
    _controller.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
      if (widget.onChange != null) {
        widget.onChange!(_controller.selectedSlots);
      }
    }
  }

  @override
  void didUpdateWidget(covariant TimeLinePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChange);
      _controller.detachScrollController();
      if (_internalControllerCreated) {
        _controller.dispose();
        _internalControllerCreated = false;
      }
      _initController();
    }
    if (oldWidget.startTime != widget.startTime ||
        oldWidget.endTime != widget.endTime ||
        oldWidget.interval != widget.interval ||
        oldWidget.customTimeSlots != widget.customTimeSlots ||
        oldWidget.isSlotDisabled != widget.isSlotDisabled ||
        oldWidget.activeTimeSlots != widget.activeTimeSlots ||
        oldWidget.inactiveTimeSlots != widget.inactiveTimeSlots) {
      _generateSlots();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.detachScrollController();
    if (_internalControllerCreated) {
      _controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _generateSlots() {
    if (widget.customTimeSlots != null && widget.customTimeSlots!.isNotEmpty) {
      _timeSlots = widget.customTimeSlots!.map((s) {
        final isDisabled = _isSlotDisabled(s);
        return s.copyWith(isDisabled: isDisabled);
      }).toList();
      return;
    }

    final slots = <TimeSlot>[];
    int startMinutes = widget.startTime.hour * 60 + widget.startTime.minute;
    int endMinutes = widget.endTime.hour * 60 + widget.endTime.minute;

    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60;
    }

    final intervalMinutes = widget.interval.inMinutes > 0
        ? widget.interval.inMinutes
        : 30;

    int current = startMinutes;
    while (current < endMinutes) {
      int next = current + intervalMinutes;
      if (next > endMinutes) break;

      final startHour = (current ~/ 60) % 24;
      final startMin = current % 60;
      final endHour = (next ~/ 60) % 24;
      final endMin = next % 60;

      final slot = TimeSlot(
        startTime: TimeOfDay(hour: startHour, minute: startMin),
        endTime: TimeOfDay(hour: endHour, minute: endMin),
      );

      final isDisabled = _isSlotDisabled(slot);
      slots.add(slot.copyWith(isDisabled: isDisabled));
      current = next;
    }

    _timeSlots = slots;
  }

  bool _isSlotDisabled(TimeSlot slot) {
    if (widget.isSlotDisabled != null && widget.isSlotDisabled!(slot)) {
      return true;
    }
    if (widget.inactiveTimeSlots != null &&
        widget.inactiveTimeSlots!.contains(slot)) {
      return true;
    }
    if (widget.activeTimeSlots != null &&
        !widget.activeTimeSlots!.contains(slot)) {
      return true;
    }
    return false;
  }

  void _onSlotTap(TimeSlot slot) {
    if (slot.isDisabled || !slot.isAvailable) return;

    if (widget.onSlotTap != null) {
      widget.onSlotTap!(slot);
    }

    switch (widget.selectionMode) {
      case TimeSelectionMode.single:
        _controller.selectSlot(slot, isMultiple: false);
        break;
      case TimeSelectionMode.multiple:
        _controller.selectSlot(slot, isMultiple: true);
        break;
      case TimeSelectionMode.range:
        if (_rangeStartSlot == null ||
            _rangeStartSlot != null && _controller.selectedSlots.length > 1) {
          _rangeStartSlot = slot;
          _controller.selectSlot(slot, isMultiple: false);
        } else {
          _controller.selectRange(_rangeStartSlot!, slot, _timeSlots);
          _rangeStartSlot = null;
        }
        break;
    }
  }

  Widget _buildItem(TimeSlot slot) {
    final isSelected = _controller.isSelected(slot);
    final isDisabled = slot.isDisabled || !slot.isAvailable;

    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(
        context,
        slot,
        isSelected,
        isDisabled,
        () => _onSlotTap(slot),
      );
    }

    return TimeSlotItem(
      slot: slot,
      isSelected: isSelected,
      onTap: () => _onSlotTap(slot),
      use24HourFormat: widget.use24HourFormat,
      showEndTime: widget.showEndTime,
      selectedTextStyle: widget.selectedTextStyle,
      unselectedTextStyle: widget.unselectedTextStyle,
      disabledTextStyle: widget.disabledTextStyle,
      selectedBackgroundColor: widget.selectedBackgroundColor,
      unselectedBackgroundColor: widget.unselectedBackgroundColor,
      disabledBackgroundColor: widget.disabledBackgroundColor,
      selectedBorder: widget.selectedBorder,
      unselectedBorder: widget.unselectedBorder,
      borderRadius: widget.borderRadius,
      padding: widget.itemPadding,
      margin: widget.itemMargin,
      shadows: widget.itemShadows,
      icon: widget.slotIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        widget.containerPadding ?? const EdgeInsets.all(8.0);

    switch (widget.layoutMode) {
      case TimelineLayoutMode.horizontal:
        return Padding(
          padding: effectivePadding,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: widget.physics,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _timeSlots.map((slot) => _buildItem(slot)).toList(),
            ),
          ),
        );

      case TimelineLayoutMode.vertical:
        return Padding(
          padding: effectivePadding,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            physics: widget.physics,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _timeSlots.map((slot) => _buildItem(slot)).toList(),
            ),
          ),
        );

      case TimelineLayoutMode.grid:
        return Padding(
          padding: effectivePadding,
          child: DynamicHeightGridView(
            controller: _scrollController,
            shrinkWrap: widget.shrinkWrap,
            physics: widget.physics,
            itemCount: _timeSlots.length,
            crossAxisCount: widget.gridCrossAxisCount,
            crossAxisSpacing: widget.spacing,
            mainAxisSpacing: widget.runSpacing,
            builder: (context, index) => _buildItem(_timeSlots[index]),
          ),
        );

      case TimelineLayoutMode.wrap:
        return Padding(
          padding: effectivePadding,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: widget.physics,
            child: Wrap(
              spacing: widget.spacing,
              runSpacing: widget.runSpacing,
              children: _timeSlots.map((slot) => _buildItem(slot)).toList(),
            ),
          ),
        );
    }
  }
}
