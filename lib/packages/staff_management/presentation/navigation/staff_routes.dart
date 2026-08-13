import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../bloc/employee/employee_bloc.dart';
import '../bloc/employee/employee_event_state.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event_state.dart';
import '../bloc/leave/leave_bloc.dart';
import '../bloc/leave/leave_event_state.dart';
import '../pages/attendance/attendance_sub_screen.dart';
import '../pages/employee/employee_sub_screen.dart';
import '../pages/leave/leave_sub_screen.dart';
import '../pages/staff_report/staff_report_sub_screen.dart';
import '../pages/staff_management/staff_management_screen.dart';

class StaffRoutes {
  static List<RouteBase> get routes => [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<EmployeeBloc>.value(
              value: GetIt.instance<EmployeeBloc>()..add(LoadEmployeesEvent()),
            ),
            BlocProvider<AttendanceBloc>.value(
              value: GetIt.instance<AttendanceBloc>()
                ..add(LoadAttendanceEvent()),
            ),
            BlocProvider<LeaveBloc>.value(
              value: GetIt.instance<LeaveBloc>()..add(LoadLeavesEvent()),
            ),
          ],
          child: StaffManagementScreen(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutePath.staffManagementScreenRoute,
              name: AppRouteName.staffManagement,
              builder: (context, state) => const EmployeeSubScreen(),
              routes: [
                GoRoute(
                  path: AppRoutePath.employeeListScreenRoute,
                  name: AppRouteName.employeeList,
                  builder: (context, state) => const EmployeeSubScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path:
                  '${AppRoutePath.staffManagementScreenRoute}/${AppRoutePath.employeeAttendanceScreenRoute}',
              name: AppRouteName.employeeAttendance,
              builder: (context, state) => const AttendanceSubScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path:
                  '${AppRoutePath.staffManagementScreenRoute}/${AppRoutePath.employeeLeaveScreenRoute}',
              name: AppRouteName.employeeLeave,
              builder: (context, state) => const LeaveSubScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path:
                  '${AppRoutePath.staffManagementScreenRoute}/${AppRoutePath.employeesReportsScreenRoute}',
              name: AppRouteName.employeesReports,
              builder: (context, state) => const StaffReportSubScreen(),
            ),
          ],
        ),
      ],
    ),
  ];
}
