import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../bloc/employee/employee_bloc.dart';
import '../bloc/employee/employee_event_state.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event_state.dart';
import '../bloc/leave/leave_bloc.dart';
import '../bloc/leave/leave_event_state.dart';
import '../../domain/entities/staff_entities.dart';
import '../widgets/report_duration_enum.dart';
import '../widgets/staff_report_charts.dart';

class StaffReportSubScreen extends StatefulWidget {
  const StaffReportSubScreen({super.key});

  @override
  State<StaffReportSubScreen> createState() => _StaffReportSubScreenState();
}

class _StaffReportSubScreenState extends State<StaffReportSubScreen>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<ReportDuration> _selectedDurationNotifier =
      ValueNotifier<ReportDuration>(ReportDuration.monthly);
  final ValueNotifier<int?> _selectedEmployeeIdNotifier =
      ValueNotifier<int?>(null);
  final ValueNotifier<SfRangeValues> _sliderRangeValuesNotifier =
      ValueNotifier<SfRangeValues>(const SfRangeValues(0.0, 100.0));

  late final Listenable _filterListenable;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _filterListenable = Listenable.merge([
      _selectedDurationNotifier,
      _selectedEmployeeIdNotifier,
      _sliderRangeValuesNotifier,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAllData();
    });
  }

  @override
  void dispose() {
    _selectedDurationNotifier.dispose();
    _selectedEmployeeIdNotifier.dispose();
    _sliderRangeValuesNotifier.dispose();
    super.dispose();
  }

  void _refreshAllData() {
    context.read<EmployeeBloc>().add(LoadEmployeesEvent());
    context.read<AttendanceBloc>().add(LoadAttendanceEvent());
    context.read<LeaveBloc>().add(LoadLeavesEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<EmployeeBloc>().add(LoadEmployeesEvent());
          context.read<AttendanceBloc>().add(LoadAttendanceEvent());
          context.read<LeaveBloc>().add(LoadLeavesEvent());
        },
        child: AnimatedBuilder(
          animation: _filterListenable,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Controls Card (Duration & Employee Selector)
                  _buildHeaderFilterCard(theme),
                  const SizedBox(height: 16),

                  // Syncfusion Interactive Range Slider Component
                  _buildSyncfusionRangeSliderCard(theme),
                  const SizedBox(height: 20),

                  // BlocBuilder for combined data summary & charts
                  BlocBuilder<EmployeeBloc, EmployeeState>(
                    builder: (context, employeeState) {
                      return BlocBuilder<AttendanceBloc, AttendanceState>(
                        builder: (context, attendanceState) {
                          return BlocBuilder<LeaveBloc, LeaveState>(
                            builder: (context, leaveState) {
                              final employees = employeeState is EmployeeLoadedState
                                  ? employeeState.employees
                                  : <EmployeeEntity>[];
                              final attendanceList =
                                  attendanceState is AttendanceLoadedState
                                  ? attendanceState.attendanceList
                                  : <AttendanceEntity>[];
                              final leaves = leaveState is LeaveLoadedState
                                  ? leaveState.leaves
                                  : <LeaveEntity>[];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // KPI Cards Summary
                                  _buildKpiMetricsGrid(
                                    theme: theme,
                                    employees: employees,
                                    attendanceList: attendanceList,
                                    leaves: leaves,
                                  ),
                                  const SizedBox(height: 24),

                                  // Chart 1: Attendance Trend
                                  _buildChartCard(
                                    theme: theme,
                                    title: 'Attendance & Leave Trend',
                                    subtitle:
                                        '${_selectedDurationNotifier.value.displayName} overview of Present, Absent, and On Leave days',
                                    child: SizedBox(
                                      height: 280,
                                      child: AttendanceTrendChart(
                                        data: _generateAttendanceTrendData(
                                          attendanceList,
                                          leaves,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Chart 2: Working Hours vs Target
                                  _buildChartCard(
                                    theme: theme,
                                    title: 'Working Hours vs Target',
                                    subtitle:
                                        'Tracked staff working hours against standard targets',
                                    child: SizedBox(
                                      height: 280,
                                      child: WorkingHoursChart(
                                        data: _generateWorkingHoursData(
                                          attendanceList,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Two Grid Charts: Leave Distribution & Top Attendance
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isWide = constraints.maxWidth > 700;
                                      final leaveWidget = _buildChartCard(
                                        theme: theme,
                                        title: 'Leave Distribution',
                                        subtitle: 'Breakdown of leaves by category',
                                        child: SizedBox(
                                          height: 300,
                                          child: LeaveDistributionChart(
                                            data: _generateLeaveDistributionData(
                                              leaves,
                                            ),
                                          ),
                                        ),
                                      );

                                      final perfWidget = _buildChartCard(
                                        theme: theme,
                                        title: 'Employee Attendance Rate',
                                        subtitle:
                                            'Attendance percentage per staff member',
                                        child: SizedBox(
                                          height: 300,
                                          child: EmployeePerformanceChart(
                                            data: _generateEmployeePerformanceData(
                                              employees,
                                              attendanceList,
                                            ),
                                          ),
                                        ),
                                      );

                                      if (isWide) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: leaveWidget),
                                            const SizedBox(width: 16),
                                            Expanded(child: perfWidget),
                                          ],
                                        );
                                      } else {
                                        return Column(
                                          children: [
                                            leaveWidget,
                                            const SizedBox(height: 20),
                                            perfWidget,
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Header filter section with Duration Chips, Employee Dropdown & Seed Data Button
  Widget _buildHeaderFilterCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    runAlignment: WrapAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.analytics_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Staff Analytics & Reports',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocBuilder<EmployeeBloc, EmployeeState>(
                              builder: (context, state) {
                                final employees = state is EmployeeLoadedState
                                    ? state.employees
                                    : <EmployeeEntity>[];
                                return DropdownButtonHideUnderline(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.dividerColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: DropdownButton<int?>(
                                      value: _selectedEmployeeIdNotifier.value,
                                      hint: const Text('All Employees'),
                                      isDense: true,
                                      items: [
                                        const DropdownMenuItem<int?>(
                                          value: null,
                                          child: Text('All Employees'),
                                        ),
                                        ...employees.map(
                                          (e) => DropdownMenuItem<int?>(
                                            value: e.id,
                                            child: Text(
                                              e.name ?? 'Staff #${e.id}',
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        _selectedEmployeeIdNotifier.value = val;
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Report Duration:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              children: ReportDuration.values.map((duration) {
                final isSelected = _selectedDurationNotifier.value == duration;
                return FilterChip(
                  selected: isSelected,
                  label: Text(duration.displayName),
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color,
                    fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    if (selected) {
                      _selectedDurationNotifier.value = duration;
                      _sliderRangeValuesNotifier.value = const SfRangeValues(0.0, 100.0);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Syncfusion Range Slider for adjusting the active timeline window
  Widget _buildSyncfusionRangeSliderCard(ThemeData theme) {
    final now = DateTime.now();
    final fullRange = _selectedDurationNotifier.value.getDateRange(now);
    final rangeDays = fullRange.end.difference(fullRange.start).inDays + 1;

    final activeStartDays = (rangeDays * (_sliderRangeValuesNotifier.value.start / 100))
        .round();
    final activeEndDays = (rangeDays * (_sliderRangeValuesNotifier.value.end / 100)).round();

    final activeStartDate = fullRange.start.add(
      Duration(days: activeStartDays),
    );
    final activeEndDate = fullRange.start.add(Duration(days: activeEndDays));

    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Interactive Time Window',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dateFormat.format(activeStartDate)} - ${dateFormat.format(activeEndDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SfRangeSliderTheme(
              data: SfRangeSliderThemeData(
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor: theme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
                thumbColor: theme.colorScheme.primary,
                overlayColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                tooltipBackgroundColor: theme.colorScheme.primary,
                tooltipTextStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 11,
                ),
              ),
              child: SfRangeSlider(
                min: 0.0,
                max: 100.0,
                values: _sliderRangeValuesNotifier.value,
                interval: 25.0,
                showTicks: true,
                showLabels: true,
                enableTooltip: true,
                numberFormat: NumberFormat('#'),
                labelFormatterCallback:
                    (dynamic actualValue, String formattedText) {
                      return '$formattedText%';
                    },
                tooltipTextFormatterCallback:
                    (dynamic actualValue, String formattedText) {
                      return '${double.parse(actualValue.toString()).toStringAsFixed(0)}%';
                    },
                onChanged: (SfRangeValues newValues) {
                  _sliderRangeValuesNotifier.value = newValues;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Grid of Key Performance Indicator cards
  Widget _buildKpiMetricsGrid({
    required ThemeData theme,
    required List<EmployeeEntity> employees,
    required List<AttendanceEntity> attendanceList,
    required List<LeaveEntity> leaves,
  }) {
    final filteredAttendance = _filterAttendance(attendanceList);
    final filteredLeaves = _filterLeaves(leaves);

    final totalPresent = filteredAttendance
        .where((a) => a.status?.toLowerCase() == 'present' || a.status == '1')
        .length;
    final totalRecords = filteredAttendance.length;
    final attendanceRate = totalRecords > 0
        ? ((totalPresent / totalRecords) * 100).toStringAsFixed(1)
        : '0.0';

    final totalLeavesCount = filteredLeaves.length;
    final activeStaffCount = employees.where((e) => e.isDeleted != true).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 500
            ? 2
            : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildMetricCard(
              theme: theme,
              title: 'Total Active Staff',
              value: '$activeStaffCount',
              icon: Icons.people_alt_rounded,
              color: Colors.blue,
            ),
            _buildMetricCard(
              theme: theme,
              title: 'Attendance Rate',
              value: '$attendanceRate%',
              icon: Icons.fact_check_rounded,
              color: Colors.teal,
            ),
            _buildMetricCard(
              theme: theme,
              title: 'Leaves Requested',
              value: '$totalLeavesCount',
              icon: Icons.event_busy_rounded,
              color: Colors.orange,
            ),
            _buildMetricCard(
              theme: theme,
              title: 'Present Days',
              value: '$totalPresent',
              icon: Icons.check_circle_rounded,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required Widget child,
    VoidCallback? onRefresh,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  iconSize: 20,
                  tooltip: 'Refresh chart',
                  onPressed: onRefresh ?? _refreshAllData,
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // --- Helpers for Filtering & Chart Data generation ---

  List<AttendanceEntity> _filterAttendance(List<AttendanceEntity> list) {
    if (_selectedEmployeeIdNotifier.value == null) return list;
    return list.where((a) => a.employeeId == _selectedEmployeeIdNotifier.value).toList();
  }

  List<LeaveEntity> _filterLeaves(List<LeaveEntity> list) {
    if (_selectedEmployeeIdNotifier.value == null) return list;
    return list.where((l) => l.employeeId == _selectedEmployeeIdNotifier.value).toList();
  }

  List<AttendanceTrendData> _generateAttendanceTrendData(
    List<AttendanceEntity> attendanceList,
    List<LeaveEntity> leaves,
  ) {
    final filtered = _filterAttendance(attendanceList);

    if (filtered.isEmpty) {
      return [];
    }

    final Map<String, Map<String, int>> map = {};
    for (final a in filtered) {
      final label = a.date ?? 'N/A';
      map.putIfAbsent(label, () => {'present': 0, 'absent': 0, 'leave': 0});
      final status = (a.status ?? '1').toLowerCase();
      if (status == 'present' || status == '1') {
        map[label]!['present'] = (map[label]!['present'] ?? 0) + 1;
      } else if (status == 'absent' || status == '2') {
        map[label]!['absent'] = (map[label]!['absent'] ?? 0) + 1;
      } else {
        map[label]!['leave'] = (map[label]!['leave'] ?? 0) + 1;
      }
    }
    return map.entries
        .map(
          (e) => AttendanceTrendData(
            periodLabel: e.key,
            present: e.value['present']!,
            absent: e.value['absent']!,
            leave: e.value['leave']!,
          ),
        )
        .toList();
  }

  List<WorkingHoursData> _generateWorkingHoursData(
    List<AttendanceEntity> attendanceList,
  ) {
    final filtered = _filterAttendance(attendanceList);
    if (filtered.isEmpty) {
      return [];
    }

    final Map<String, double> workedMap = {};
    for (final a in filtered) {
      final label = a.date ?? 'N/A';
      final double durationHours =
          double.tryParse(
            a.employeeWorkingDurations ?? a.workingTimeDurations ?? '8.0',
          ) ??
          8.0;
      workedMap[label] = (workedMap[label] ?? 0.0) + durationHours;
    }

    return workedMap.entries
        .map(
          (e) => WorkingHoursData(
            periodLabel: e.key,
            workedHours: e.value,
            targetHours: 8.0,
          ),
        )
        .toList();
  }

  List<LeaveDistributionData> _generateLeaveDistributionData(
    List<LeaveEntity> leaves,
  ) {
    final filtered = _filterLeaves(leaves);
    if (filtered.isEmpty) {
      return [];
    }

    final Map<String, int> counts = {};
    for (final l in filtered) {
      final type = l.leaveType ?? 'Casual Leave';
      counts[type] = (counts[type] ?? 0) + 1;
    }
    final colors = [
      Colors.blue.shade600,
      Colors.orange.shade600,
      Colors.teal.shade600,
      Colors.purple.shade400,
      Colors.pink.shade400,
    ];
    int i = 0;
    return counts.entries.map((e) {
      final color = colors[i % colors.length];
      i++;
      return LeaveDistributionData(
        leaveType: e.key,
        count: e.value,
        color: color,
      );
    }).toList();
  }

  List<EmployeePerformanceData> _generateEmployeePerformanceData(
    List<EmployeeEntity> employees,
    List<AttendanceEntity> attendanceList,
  ) {
    if (employees.isEmpty) {
      return [];
    }

    return employees.where((e) => e.isDeleted != true).map((e) {
      final name = e.name ?? 'Staff #${e.id}';
      final empAttendance = attendanceList.where((a) => a.employeeId == e.id);
      final total = empAttendance.length;
      final present = empAttendance
          .where((a) => a.status?.toLowerCase() == 'present' || a.status == '1')
          .length;
      final rate = total > 0 ? (present / total) * 100 : 0.0;
      return EmployeePerformanceData(employeeName: name, attendanceRate: rate);
    }).toList();
  }
}
