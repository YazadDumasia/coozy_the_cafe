import '../../domain/entities/staff_entities.dart';
import '../../domain/repositories/staff_repository.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRepository localDataSource;

  StaffRepositoryImpl({required this.localDataSource});

  @override
  Future<List<EmployeeEntity>> getEmployees() => localDataSource.getEmployees();

  @override
  Future<int> addEmployee(EmployeeEntity employee) =>
      localDataSource.addEmployee(employee);

  @override
  Future<int> updateEmployee(EmployeeEntity employee) =>
      localDataSource.updateEmployee(employee);

  @override
  Future<int> deleteSoftEmployee(int id) =>
      localDataSource.deleteSoftEmployee(id);

  @override
  Future<int> deletePermanentEmployee(int id) =>
      localDataSource.deletePermanentEmployee(id);

  @override
  Future<List<AttendanceEntity>> getAttendance() =>
      localDataSource.getAttendance();

  @override
  Future<int> addAttendance(AttendanceEntity attendance) =>
      localDataSource.addAttendance(attendance);

  @override
  Future<int> updateAttendance(AttendanceEntity attendance) =>
      localDataSource.updateAttendance(attendance);

  @override
  Future<int> deleteAttendance(int id) => localDataSource.deleteAttendance(id);

  @override
  Future<int> deletePermanentlyAttendance(int id) =>
      localDataSource.deletePermanentlyAttendance(id);

  @override
  Future<List<LeaveEntity>> getLeaves() => localDataSource.getLeaves();

  @override
  Future<int> addLeave(LeaveEntity leave) => localDataSource.addLeave(leave);

  @override
  Future<int> updateLeave(LeaveEntity leave) =>
      localDataSource.updateLeave(leave);

  @override
  Future<void> updateLeavesBatch(List<LeaveEntity> leaves) =>
      localDataSource.updateLeavesBatch(leaves);

  @override
  Future<int> deleteLeave(int id) => localDataSource.deleteLeave(id);

  @override
  Future<int> deleteLeavePermanent(int id) =>
      localDataSource.deleteLeavePermanent(id);
}
