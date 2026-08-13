import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';

/// Example showcase widget demonstrating [TimeLinePicker] with all 4 layout modes
/// (Horizontal, Vertical, Grid, Wrap), time intervals, selection modes, and custom styling.
class TimeLinePickerExample extends StatefulWidget {
  const TimeLinePickerExample({super.key});

  @override
  State<TimeLinePickerExample> createState() => _TimeLinePickerExampleState();
}

class _TimeLinePickerExampleState extends State<TimeLinePickerExample> {
  final TimeLinePickerController _horizontalController =
      TimeLinePickerController();
  final TimeLinePickerController _verticalController =
      TimeLinePickerController();
  final TimeLinePickerController _gridController = TimeLinePickerController();
  final TimeLinePickerController _wrapController = TimeLinePickerController();

  TimelineLayoutMode _selectedLayout = TimelineLayoutMode.horizontal;
  TimeSelectionMode _selectedSelectionMode = TimeSelectionMode.single;
  Duration _selectedInterval = const Duration(minutes: 30);
  bool _use24Hour = false;
  bool _showEndTime = true;

  List<TimeSlot> _selectedSlots = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Time Line Picker Example'),
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _horizontalController.clearSelection();
                _verticalController.clearSelection();
                _gridController.clearSelection();
                _wrapController.clearSelection();
                setState(() {
                  _selectedSlots.clear();
                });
              },
              tooltip: 'Clear Selections',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfigurationCard(theme),
              const SizedBox(height: 20),
              _buildSelectedInfoCard(theme),
              const SizedBox(height: 24),
              Text(
                'Interactive Layout Showcase',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildActivePickerView(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Picker Controls & Customizations',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButtonFormField<TimelineLayoutMode>(
                  initialValue: _selectedLayout,
                  decoration: const InputDecoration(
                    labelText: 'Layout Style',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: TimelineLayoutMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLayout = val);
                    }
                  },
                ),
                DropdownButtonFormField<TimeSelectionMode>(
                  initialValue: _selectedSelectionMode,
                  decoration: const InputDecoration(
                    labelText: 'Selection Mode',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: TimeSelectionMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedSelectionMode = val);
                    }
                  },
                ),
                DropdownButtonFormField<int>(
                  initialValue: _selectedInterval.inMinutes,
                  decoration: const InputDecoration(
                    labelText: 'Interval',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15 Mins')),
                    DropdownMenuItem(value: 30, child: Text('30 Mins')),
                    DropdownMenuItem(value: 60, child: Text('1 Hour')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(
                        () => _selectedInterval = Duration(minutes: val),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilterChip(
                  label: const Text('24 Hour Format'),
                  selected: _use24Hour,
                  onSelected: (val) => setState(() => _use24Hour = val),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Show End Time'),
                  selected: _showEndTime,
                  onSelected: (val) => setState(() => _showEndTime = val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedInfoCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_seat, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Selected Time Slots:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _selectedSlots.isEmpty
              ? Text(
                  'No time slot selected yet. Tap any slot below!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _selectedSlots.map((slot) {
                    return Chip(
                      backgroundColor: theme.primaryColor,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      label: Text(
                        slot.format(
                          context,
                          use24HourFormat: _use24Hour,
                          showEndTime: _showEndTime,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildActivePickerView(ThemeData theme) {
    TimeLinePickerController currentController;
    switch (_selectedLayout) {
      case TimelineLayoutMode.horizontal:
        currentController = _horizontalController;
        break;
      case TimelineLayoutMode.vertical:
        currentController = _verticalController;
        break;
      case TimelineLayoutMode.grid:
        currentController = _gridController;
        break;
      case TimelineLayoutMode.wrap:
        currentController = _wrapController;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: SizedBox(
          height:
              _selectedLayout == TimelineLayoutMode.vertical ||
                  _selectedLayout == TimelineLayoutMode.grid
              ? 360
              : null,
          child: TimeLinePicker(
            controller: currentController,
            startTime: const TimeOfDay(hour: 8, minute: 0),
            endTime: const TimeOfDay(hour: 22, minute: 0),
            interval: _selectedInterval,
            layoutMode: _selectedLayout,
            selectionMode: _selectedSelectionMode,
            use24HourFormat: _use24Hour,
            showEndTime: _showEndTime,
            shrinkWrap: _selectedLayout == TimelineLayoutMode.wrap,
            gridCrossAxisCount: 3,
            spacing: 8.0,
            runSpacing: 8.0,
            selectedBackgroundColor: theme.primaryColor,
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedBackgroundColor: theme.cardColor,
            unselectedTextStyle: TextStyle(
              color: theme.textTheme.bodyMedium?.color ?? Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            disabledBackgroundColor: theme.disabledColor.withValues(
              alpha: 0.12,
            ),
            disabledTextStyle: TextStyle(
              color: theme.disabledColor,
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
            isSlotDisabled: (slot) {
              if (slot.startTime.hour == 13) return true;
              return false;
            },
            slotIcon: const Icon(Icons.access_time_rounded, size: 14),
            onChange: (slots) {
              setState(() {
                _selectedSlots = slots;
              });
            },
          ),
        ),
      ),
    );
  }
}
