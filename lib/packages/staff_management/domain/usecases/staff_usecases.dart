import '../entities/staff_entities.dart';
import '../repositories/staff_repository.dart';

class GetEmployeesUseCase {
  final StaffRepository repository;
  GetEmployeesUseCase(this.repository);
  Future<List<EmployeeEntity>> call() => repository.getEmployees();
}

class AddEmployeeUseCase {
  final StaffRepository repository;
  AddEmployeeUseCase(this.repository);
  Future<int> call(EmployeeEntity employee) => repository.addEmployee(employee);
}

class UpdateEmployeeUseCase {
  final StaffRepository repository;
  UpdateEmployeeUseCase(this.repository);
  Future<int> call(EmployeeEntity employee) =>
      repository.updateEmployee(employee);
}

class DeleteSoftEmployeeUseCase {
  final StaffRepository repository;
  DeleteSoftEmployeeUseCase(this.repository);
  Future<int> call(int id) => repository.deleteSoftEmployee(id);
}

class DeletePermanentEmployeeUseCase {
  final StaffRepository repository;
  DeletePermanentEmployeeUseCase(this.repository);
  Future<int> call(int id) => repository.deletePermanentEmployee(id);
}

// Attendance
class GetAttendanceUseCase {
  final StaffRepository repository;
  GetAttendanceUseCase(this.repository);
  Future<List<AttendanceEntity>> call() => repository.getAttendance();
}

class AddAttendanceUseCase {
  final StaffRepository repository;
  AddAttendanceUseCase(this.repository);
  Future<int> call(AttendanceEntity attendance) =>
      repository.addAttendance(attendance);
}

class UpdateAttendanceUseCase {
  final StaffRepository repository;
  UpdateAttendanceUseCase(this.repository);
  Future<int> call(AttendanceEntity attendance) =>
      repository.updateAttendance(attendance);
}

class DeleteAttendanceUseCase {
  final StaffRepository repository;
  DeleteAttendanceUseCase(this.repository);
  Future<int> call(int id) => repository.deleteAttendance(id);
}

class DeletePermanentlyAttendanceUseCase {
  final StaffRepository repository;
  DeletePermanentlyAttendanceUseCase(this.repository);
  Future<int> call(int id) => repository.deletePermanentlyAttendance(id);
}

// Leaves
class GetLeavesUseCase {
  final StaffRepository repository;
  GetLeavesUseCase(this.repository);
  Future<List<LeaveEntity>> call() => repository.getLeaves();
}

class AddLeaveUseCase {
  final StaffRepository repository;
  AddLeaveUseCase(this.repository);
  Future<int> call(LeaveEntity leave) => repository.addLeave(leave);
}

class UpdateLeaveUseCase {
  final StaffRepository repository;
  UpdateLeaveUseCase(this.repository);
  Future<int> call(LeaveEntity leave) => repository.updateLeave(leave);
}

class UpdateLeavesBatchUseCase {
  final StaffRepository repository;
  UpdateLeavesBatchUseCase(this.repository);
  Future<void> call(List<LeaveEntity> leaves) =>
      repository.updateLeavesBatch(leaves);
}

class DeleteLeaveUseCase {
  final StaffRepository repository;
  DeleteLeaveUseCase(this.repository);
  Future<int> call(int id) => repository.deleteLeave(id);
}

class DeleteLeavePermanentUseCase {
  final StaffRepository repository;
  DeleteLeavePermanentUseCase(this.repository);
  Future<int> call(int id) => repository.deleteLeavePermanent(id);
}
