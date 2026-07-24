import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';

import 'data/datasources/staff_local_data_source.dart';
import 'data/repositories/staff_repository_impl.dart';
import 'domain/repositories/staff_repository.dart';
import 'domain/usecases/staff_usecases.dart';
import 'presentation/bloc/employee/employee_bloc.dart';
import 'presentation/bloc/attendance/attendance_bloc.dart';
import 'presentation/bloc/leave/leave_bloc.dart';

void registerStaffManagementDependencies(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<StaffLocalDataSourceImpl>(
    () => StaffLocalDataSourceImpl(database: sl<CoozyDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(localDataSource: sl<StaffLocalDataSourceImpl>()),
  );

  // Use Cases - Employee
  sl.registerLazySingleton(() => GetEmployeesUseCase(sl()));
  sl.registerLazySingleton(() => AddEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSoftEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => DeletePermanentEmployeeUseCase(sl()));

  // Use Cases - Attendance
  sl.registerLazySingleton(() => GetAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => AddAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => DeletePermanentlyAttendanceUseCase(sl()));

  // Use Cases - Leaves
  sl.registerLazySingleton(() => GetLeavesUseCase(sl()));
  sl.registerLazySingleton(() => AddLeaveUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLeaveUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLeavesBatchUseCase(sl()));
  sl.registerLazySingleton(() => DeleteLeaveUseCase(sl()));
  sl.registerLazySingleton(() => DeleteLeavePermanentUseCase(sl()));

  // BLoCs
  sl.registerLazySingleton(
    () => EmployeeBloc(
      getEmployeesUseCase: sl(),
      addEmployeeUseCase: sl(),
      updateEmployeeUseCase: sl(),
      deleteSoftEmployeeUseCase: sl(),
      deletePermanentEmployeeUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => AttendanceBloc(
      getAttendanceUseCase: sl(),
      addAttendanceUseCase: sl(),
      updateAttendanceUseCase: sl(),
      deleteAttendanceUseCase: sl(),
      deletePermanentlyAttendanceUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => LeaveBloc(
      getLeavesUseCase: sl(),
      addLeaveUseCase: sl(),
      updateLeaveUseCase: sl(),
      updateLeavesBatchUseCase: sl(),
      deleteLeaveUseCase: sl(),
      deleteLeavePermanentUseCase: sl(),
    ),
  );
}
