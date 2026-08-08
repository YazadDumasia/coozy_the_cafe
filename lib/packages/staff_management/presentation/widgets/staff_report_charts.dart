import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AttendanceTrendData {
  final DateTime? date;
  final String periodLabel;
  final int present;
  final int absent;
  final int leave;

  AttendanceTrendData({
    this.date,
    required this.periodLabel,
    required this.present,
    required this.absent,
    required this.leave,
  });
}

class WorkingHoursData {
  final DateTime? date;
  final String periodLabel;
  final double workedHours;
  final double targetHours;

  WorkingHoursData({
    this.date,
    required this.periodLabel,
    required this.workedHours,
    required this.targetHours,
  });
}

class LeaveDistributionData {
  final String leaveType;
  final int count;
  final Color color;

  LeaveDistributionData({
    required this.leaveType,
    required this.count,
    required this.color,
  });
}

class EmployeePerformanceData {
  final String employeeName;
  final double attendanceRate; // in %

  EmployeePerformanceData({
    required this.employeeName,
    required this.attendanceRate,
  });
}

/// Chart 1: Attendance & Leave Trend (Stacked Column Chart)
class AttendanceTrendChart extends StatelessWidget {
  final List<AttendanceTrendData> data;

  const AttendanceTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SfCartesianChart(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      plotAreaBorderWidth: 0,
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        toggleSeriesVisibility: true,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        canShowMarker: true,
        duration: 3000,
        activationMode: ActivationMode.singleTap,
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
        enableMouseWheelZooming: true,
        zoomMode: ZoomMode.x,
      ),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          fontSize: 11,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(
          fontSize: 11,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      series: <CartesianSeries<AttendanceTrendData, String>>[
        StackedColumnSeries<AttendanceTrendData, String>(
          name:
              context.tr(
                shared.LocaleKeys.chartSeriesPresent,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Present',
          dataSource: data,
          xValueMapper: (AttendanceTrendData item, _) => item.periodLabel,
          yValueMapper: (AttendanceTrendData item, _) => item.present,
          color: Colors.green.shade600,
          animationDuration: 1000,
          enableTooltip: true,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        StackedColumnSeries<AttendanceTrendData, String>(
          name:
              context.tr(
                shared.LocaleKeys.chartSeriesAbsent,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Absent',
          dataSource: data,
          xValueMapper: (AttendanceTrendData item, _) => item.periodLabel,
          yValueMapper: (AttendanceTrendData item, _) => item.absent,
          color: Colors.red.shade400,
          animationDuration: 1000,
          enableTooltip: true,
        ),
        StackedColumnSeries<AttendanceTrendData, String>(
          name:
              context.tr(
                shared.LocaleKeys.chartSeriesOnLeave,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'On Leave',
          dataSource: data,
          xValueMapper: (AttendanceTrendData item, _) => item.periodLabel,
          yValueMapper: (AttendanceTrendData item, _) => item.leave,
          color: Colors.orange.shade400,
          animationDuration: 1000,
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// Chart 2: Working Hours vs Target (Spline Area Series Chart with Gradient Fill)
class WorkingHoursChart extends StatelessWidget {
  final List<WorkingHoursData> data;

  const WorkingHoursChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final LinearGradient areaGradient = LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.40),
        primaryColor.withValues(alpha: 0.05),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return SfCartesianChart(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      plotAreaBorderWidth: 0,
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        toggleSeriesVisibility: true,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        canShowMarker: true,
        duration: 3000,
        activationMode: ActivationMode.singleTap,
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
        enableMouseWheelZooming: true,
        zoomMode: ZoomMode.x,
      ),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          fontSize: 11,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        labelFormat: '{value} hrs',
        labelStyle: TextStyle(
          fontSize: 11,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      series: <CartesianSeries<WorkingHoursData, String>>[
        SplineAreaSeries<WorkingHoursData, String>(
          name:
              context.tr(
                shared.LocaleKeys.chartSeriesWorkedHours,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Worked Hours',
          dataSource: data,
          xValueMapper: (WorkingHoursData item, _) => item.periodLabel,
          yValueMapper: (WorkingHoursData item, _) => item.workedHours,
          gradient: areaGradient,
          borderColor: primaryColor,
          borderWidth: 3,
          animationDuration: 1000,
          enableTooltip: true,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
          ),
        ),
        SplineSeries<WorkingHoursData, String>(
          name:
              context.tr(
                shared.LocaleKeys.chartSeriesTargetHours,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Target Hours',
          dataSource: data,
          xValueMapper: (WorkingHoursData item, _) => item.periodLabel,
          yValueMapper: (WorkingHoursData item, _) => item.targetHours,
          color: Colors.amber.shade700,
          dashArray: const <double>[5, 5],
          width: 2.5,
          animationDuration: 1000,
          enableTooltip: true,
          markerSettings: const MarkerSettings(
            isVisible: true,
            height: 5,
            width: 5,
            shape: DataMarkerType.rectangle,
          ),
        ),
      ],
    );
  }
}

/// Chart 3: Leave Distribution (Doughnut Chart with Exploding Slices)
class LeaveDistributionChart extends StatelessWidget {
  final List<LeaveDistributionData> data;

  const LeaveDistributionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final totalLeaves = data.fold<int>(0, (sum, item) => sum + item.count);

    return SfCircularChart(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.wrap,
        toggleSeriesVisibility: true,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        duration: 3000,
        activationMode: ActivationMode.singleTap,
      ),
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$totalLeaves',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                context.tr(
                      shared.LocaleKeys.chartSeriesLeaves,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ) ??
                    'Leaves',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
      series: <CircularSeries<LeaveDistributionData, String>>[
        DoughnutSeries<LeaveDistributionData, String>(
          dataSource: data,
          xValueMapper: (LeaveDistributionData item, _) => item.leaveType,
          yValueMapper: (LeaveDistributionData item, _) => item.count,
          pointColorMapper: (LeaveDistributionData item, _) => item.color,
          innerRadius: '60%',
          radius: '78%',
          explode: true,
          explodeIndex: 0,
          explodeOffset: '8%',
          explodeGesture: ActivationMode.singleTap,
          animationDuration: 1000,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              width: 1.5,
            ),
          ),
          enableTooltip: true,
        ),
      ],
    );
  }
}

/// Chart 4: Employee Attendance Rate (Horizontal Bar Chart)
class EmployeePerformanceChart extends StatelessWidget {
  final List<EmployeePerformanceData> data;

  const EmployeePerformanceChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SfCartesianChart(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      plotAreaBorderWidth: 0,
      legend: const Legend(isVisible: false),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        canShowMarker: true,
        duration: 3000,
        activationMode: ActivationMode.singleTap,
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
        enableMouseWheelZooming: true,
      ),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          fontSize: 11,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      primaryYAxis: NumericAxis(
        maximum: 100,
        axisLine: const AxisLine(width: 0),
        labelFormat: '{value}%',
        labelStyle: TextStyle(
          fontSize: 11,
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      series: <CartesianSeries<EmployeePerformanceData, String>>[
        BarSeries<EmployeePerformanceData, String>(
          name:
              context.tr(
                shared.LocaleKeys.chartSeriesAttendancePercent,
                track: shared.TrackConstants.staffManagementPageTrack,
              ) ??
              'Attendance %',
          dataSource: data,
          xValueMapper: (EmployeePerformanceData item, _) => item.employeeName,
          yValueMapper: (EmployeePerformanceData item, _) =>
              item.attendanceRate,
          animationDuration: 1000,
          enableTooltip: true,
          pointColorMapper: (EmployeePerformanceData item, _) {
            if (item.attendanceRate >= 90) {
              return Colors.teal.shade600;
            } else if (item.attendanceRate >= 75) {
              return Colors.blue.shade600;
            } else if (item.attendanceRate >= 60) {
              return Colors.orange.shade600;
            } else {
              return Colors.red.shade600;
            }
          },
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.outer,
          ),
        ),
      ],
    );
  }
}
