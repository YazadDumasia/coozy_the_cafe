import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

import '../../domain/entities/staff_entities.dart';
import '../../domain/repositories/staff_repository.dart';

class StaffLocalDataSourceImpl implements StaffRepository {
  final CoozyDatabase database;

  StaffLocalDataSourceImpl({required this.database});

  StaffManagementDao get _dao => database.staffManagementDao;

  // --- EMPLOYEES ---
  @override
  Future<List<EmployeeEntity>> getEmployees() async {
    final list = await _dao.getEmployees();
    return list
        .map(
          (e) => EmployeeEntity(
            id: e.id,
            name: e.name,
            phoneNumber: e.phoneNumber,
            isoCode: e.isoCode,
            position: e.position,
            joiningDate: e.joiningDate,
            leavingDate: e.leavingDate,
            startWorkingTime: e.startWorkingTime,
            endWorkingTime: e.endWorkingTime,
            workingHours: e.workingHours,
            email: e.email,
            salary: e.salary,
            addressLine1: e.addressLine1,
            addressLine2: e.addressLine2,
            idProof: e.idProof,
            idProofNumber: e.idProofNumber,
            totalLeaves: e.totalLeaves,
            createdDate: e.creationDate,
            modificationDate: e.modificationDate,
            isDeleted: e.isDeleted,
          ),
        )
        .toList();
  }

  @override
  Future<int> addEmployee(EmployeeEntity employee) async {
    final companion = EmployeesTableCompanion.insert(
      name: Value(employee.name),
      phoneNumber: Value(employee.phoneNumber),
      isoCode: Value(employee.isoCode),
      position: Value(employee.position),
      joiningDate: Value(employee.joiningDate),
      leavingDate: Value(employee.leavingDate),
      startWorkingTime: Value(employee.startWorkingTime),
      endWorkingTime: Value(employee.endWorkingTime),
      workingHours: Value(employee.workingHours),
      email: Value(employee.email),
      salary: Value(employee.salary),
      addressLine1: Value(employee.addressLine1),
      addressLine2: Value(employee.addressLine2),
      idProof: Value(employee.idProof),
      idProofNumber: Value(employee.idProofNumber),
      totalLeaves: Value(employee.totalLeaves),
      creationDate: Value(
        employee.createdDate ?? DateTime.now().toIso8601String(),
      ),
      modificationDate: Value(
        employee.modificationDate ?? DateTime.now().toIso8601String(),
      ),
      isDeleted: Value(employee.isDeleted ?? false),
    );
    return await _dao.addEmployee(companion);
  }

  @override
  Future<int> updateEmployee(EmployeeEntity employee) async {
    final companion = EmployeesTableCompanion(
      id: Value(employee.id!),
      name: Value(employee.name),
      phoneNumber: Value(employee.phoneNumber),
      isoCode: Value(employee.isoCode),
      position: Value(employee.position),
      joiningDate: Value(employee.joiningDate),
      leavingDate: Value(employee.leavingDate),
      startWorkingTime: Value(employee.startWorkingTime),
      endWorkingTime: Value(employee.endWorkingTime),
      workingHours: Value(employee.workingHours),
      email: Value(employee.email),
      salary: Value(employee.salary),
      addressLine1: Value(employee.addressLine1),
      addressLine2: Value(employee.addressLine2),
      idProof: Value(employee.idProof),
      idProofNumber: Value(employee.idProofNumber),
      totalLeaves: Value(employee.totalLeaves),
      creationDate: Value(employee.createdDate),
      modificationDate: Value(DateTime.now().toIso8601String()),
      isDeleted: Value(employee.isDeleted ?? false),
    );
    return await _dao.updateEmployee(companion);
  }

  @override
  Future<int> deleteSoftEmployee(int id) async {
    return await _dao.deleteSoftEmployee(id);
  }

  @override
  Future<int> deletePermanentEmployee(int id) async {
    return await _dao.deletePermanentEmployee(id);
  }

  // --- ATTENDANCE ---
  @override
  Future<List<AttendanceEntity>> getAttendance() async {
    final list = await _dao.getAttendance();
    if (list == null) return [];
    return list
        .map(
          (a) => AttendanceEntity(
            id: a.id,
            employeeId: a.employeeId,
            employeeName: a.employeeName,
            date: a.creationDate ?? a.checkIn,
            status: a.currentStatus?.toString() ?? '1',
            checkIn: a.checkIn,
            checkOut: a.checkOut,
            notes: a.employeeWorkingDurations,
            createdDate: a.creationDate,
            modificationDate: a.modificationDate,
            isDeleted: a.isDeleted,
          ),
        )
        .toList();
  }

  @override
  Future<int> addAttendance(AttendanceEntity attendance) async {
    final companion = AttendanceTableCompanion.insert(
      employeeId: Value(attendance.employeeId),
      employeeName: Value(attendance.employeeName),
      checkIn: Value(attendance.checkIn ?? attendance.date),
      checkOut: Value(attendance.checkOut),
      currentStatus: Value(int.tryParse(attendance.status ?? '1') ?? 1),
      employeeWorkingDurations: Value(attendance.notes),
      creationDate: Value(
        attendance.createdDate ?? DateTime.now().toIso8601String(),
      ),
      modificationDate: Value(
        attendance.modificationDate ?? DateTime.now().toIso8601String(),
      ),
      isDeleted: Value(attendance.isDeleted ?? false),
    );
    return await _dao.addAttendance(companion);
  }

  @override
  Future<int> updateAttendance(AttendanceEntity attendance) async {
    final companion = AttendanceTableCompanion(
      id: Value(attendance.id!),
      employeeId: Value(attendance.employeeId),
      employeeName: Value(attendance.employeeName),
      checkIn: Value(attendance.checkIn ?? attendance.date),
      checkOut: Value(attendance.checkOut),
      currentStatus: Value(int.tryParse(attendance.status ?? '1') ?? 1),
      employeeWorkingDurations: Value(attendance.notes),
      creationDate: Value(attendance.createdDate),
      modificationDate: Value(DateTime.now().toIso8601String()),
      isDeleted: Value(attendance.isDeleted ?? false),
    );
    return await _dao.updateAttendance(companion);
  }

  @override
  Future<int> deleteAttendance(int id) async {
    return await _dao.deleteAttendance(id);
  }

  @override
  Future<int> deletePermanentlyAttendance(int id) async {
    return await _dao.deletePermanentlyAttendance(id);
  }

  // --- LEAVES ---
  @override
  Future<List<LeaveEntity>> getLeaves() async {
    final list = await _dao.getLeaves();
    return list
        .map(
          (l) => LeaveEntity(
            id: l.id,
            employeeId: l.employeeId,
            employeeName: l.employeeName,
            startDate: l.startDate,
            endDate: l.endDate,
            startDateTime: l.startDate,
            endDateTime: l.endDate,
            leaveType: (l.reason != null && l.reason!.contains('Half Day'))
                ? 'Half Day'
                : 'Full Day',
            status: l.currentStatus?.toString() ?? '1',
            reason: l.reason,
            createdDate: l.creationDate,
            modificationDate: l.modificationDate,
            isDeleted: l.isDeleted,
          ),
        )
        .toList();
  }

  @override
  Future<int> addLeave(LeaveEntity leave) async {
    final companion = LeavesTableCompanion.insert(
      employeeId: Value(leave.employeeId),
      employeeName: Value(leave.employeeName),
      startDate: Value(leave.startDate),
      endDate: Value(leave.endDate),
      currentStatus: Value(int.tryParse(leave.status ?? '1') ?? 1),
      reason: Value(leave.reason),
      creationDate: Value(
        leave.createdDate ?? DateTime.now().toIso8601String(),
      ),
      modificationDate: Value(
        leave.modificationDate ?? DateTime.now().toIso8601String(),
      ),
      isDeleted: Value(leave.isDeleted ?? false),
    );
    return await _dao.addLeave(companion);
  }

  @override
  Future<int> updateLeave(LeaveEntity leave) async {
    final companion = LeavesTableCompanion(
      id: Value(leave.id!),
      employeeId: Value(leave.employeeId),
      employeeName: Value(leave.employeeName),
      startDate: Value(leave.startDate),
      endDate: Value(leave.endDate),
      currentStatus: Value(int.tryParse(leave.status ?? '1') ?? 1),
      reason: Value(leave.reason),
      creationDate: Value(leave.createdDate),
      modificationDate: Value(DateTime.now().toIso8601String()),
      isDeleted: Value(leave.isDeleted ?? false),
    );
    return await _dao.updateLeave(companion);
  }

  @override
  Future<void> updateLeavesBatch(List<LeaveEntity> leaves) async {
    final companions = leaves
        .map(
          (leave) => LeavesTableCompanion(
            id: Value(leave.id!),
            employeeId: Value(leave.employeeId),
            employeeName: Value(leave.employeeName),
            startDate: Value(leave.startDate),
            endDate: Value(leave.endDate),
            currentStatus: Value(int.tryParse(leave.status ?? '1') ?? 1),
            reason: Value(leave.reason),
            creationDate: Value(leave.createdDate),
            modificationDate: Value(DateTime.now().toIso8601String()),
            isDeleted: Value(leave.isDeleted ?? false),
          ),
        )
        .toList();
    await _dao.updateLeavesBatch(companions);
  }

  @override
  Future<int> deleteLeave(int id) async {
    return await _dao.deleteLeave(id);
  }

  @override
  Future<int> deleteLeavePermanent(int id) async {
    return await _dao.deleteLeavePermanent(id);
  }
}
