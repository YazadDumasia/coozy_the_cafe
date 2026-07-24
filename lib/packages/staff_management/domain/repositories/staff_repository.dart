import '../entities/staff_entities.dart';

abstract class StaffRepository {
  // Employee operations
  Future<List<EmployeeEntity>> getEmployees();
  Future<int> addEmployee(EmployeeEntity employee);
  Future<int> updateEmployee(EmployeeEntity employee);
  Future<int> deleteSoftEmployee(int id);
  Future<int> deletePermanentEmployee(int id);

  // Attendance operations
  Future<List<AttendanceEntity>> getAttendance();
  Future<int> addAttendance(AttendanceEntity attendance);
  Future<int> updateAttendance(AttendanceEntity attendance);
  Future<int> deleteAttendance(int id);
  Future<int> deletePermanentlyAttendance(int id);

  // Leave operations
  Future<List<LeaveEntity>> getLeaves();
  Future<int> addLeave(LeaveEntity leave);
  Future<int> updateLeave(LeaveEntity leave);
  Future<void> updateLeavesBatch(List<LeaveEntity> leaves);
  Future<int> deleteLeave(int id);
  Future<int> deleteLeavePermanent(int id);
}
