import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'staff_management_dao.g.dart';

@DriftAccessor(tables: [EmployeesTable, AttendanceTable, LeavesTable])
class StaffManagementDao extends DatabaseAccessor<CoozyDatabase>
    with _$StaffManagementDaoMixin {
  StaffManagementDao(super.db);

  // ---- EMPLOYEES ----

  /// Create a new employee
  Future<int> addEmployee(EmployeesTableCompanion employee) async {
    return await transaction(() async {
      return await into(
        employeesTable,
      ).insert(employee, mode: InsertMode.replace);
    });
  }

  /// Update an existing employee record
  Future<int> updateEmployee(EmployeesTableCompanion employee) async {
    return await transaction(() async {
      await update(employeesTable).replace(employee);
      return 1;
    });
  }

  /// Soft delete an employee by marking `isDeleted` and update the modification date
  Future<int> deleteSoftEmployee(int id) async {
    return await transaction(() async {
      final currentDate = DateTime.now()
          .toIso8601String(); // DateUtil.dateToString if we want, but Iso is fine for drift
      final rowsAffected =
          await (update(employeesTable)..where((t) => t.id.equals(id))).write(
            EmployeesTableCompanion(
              isDeleted: const Value(true),
              modificationDate: Value(currentDate),
            ),
          );
      return rowsAffected;
    });
  }

  /// Permanently delete an employee record
  Future<int> deletePermanentEmployee(int id) async {
    return await transaction(() async {
      final rowsAffected = await (delete(
        employeesTable,
      )..where((t) => t.id.equals(id))).go();
      return rowsAffected;
    });
  }

  /// Fetch all non-deleted employees ordered by descending id
  Future<List<Employee>> getEmployees() async {
    return await transaction(() async {
      final query = select(employeesTable)
        ..where((t) => t.isDeleted.equals(false) | t.isDeleted.isNull());
      return await (query..orderBy([
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ]))
          .get();
    });
  }

  /// Fetch a paginated list of non-deleted employees, ordered by descending id
  Future<List<Employee>> getEmployeesPaged({
    int pageNumber = 1,
    int limit = 20,
  }) async {
    return await transaction(() async {
      final offset = (pageNumber - 1) * limit;
      final query = select(employeesTable)
        ..where((t) => t.isDeleted.equals(false) | t.isDeleted.isNull());
      return await (query
            ..orderBy([
              (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
            ])
            ..limit(limit, offset: offset))
          .get();
    });
  }

  // ---- ATTENDANCE ----

  /// Fetch all non-deleted attendance records ordered by descending id
  Future<List<AttendanceRecord>?> getAttendance() async {
    return await transaction(() async {
      final query = select(attendanceTable)
        ..where((t) => t.isDeleted.equals(false) | t.isDeleted.isNull());
      final results =
          await (query..orderBy([
                (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
              ]))
              .get();
      return results.isNotEmpty ? results : null;
    });
  }

  /// Insert a new attendance record
  Future<int> addAttendance(AttendanceTableCompanion attendance) async {
    return await transaction(() async {
      return await into(
        attendanceTable,
      ).insert(attendance, mode: InsertMode.replace);
    });
  }

  /// Update an existing attendance record
  Future<int> updateAttendance(AttendanceTableCompanion attendance) async {
    return await transaction(() async {
      await update(attendanceTable).replace(attendance);
      return 1;
    });
  }

  /// Soft delete an attendance record by marking `isDeleted` and update the modification date
  Future<int> deleteAttendance(int id) async {
    final currentDate = DateTime.now().toIso8601String();
    return await transaction(() async {
      final rowsAffected =
          await (update(attendanceTable)..where((t) => t.id.equals(id))).write(
            AttendanceTableCompanion(
              isDeleted: const Value(true),
              modificationDate: Value(currentDate),
            ),
          );
      return rowsAffected;
    });
  }

  /// Permanently delete an attendance record by id
  Future<int> deletePermanentlyAttendance(int id) async {
    return await transaction(() async {
      return await (delete(
        attendanceTable,
      )..where((t) => t.id.equals(id))).go();
    });
  }

  // ---- LEAVES ----

  /// Get all non-deleted leaves
  Future<List<LeaveRecord>> getLeaves() async {
    final query = select(leavesTable)
      ..where((t) => t.isDeleted.equals(false) | t.isDeleted.isNull());
    final results =
        await (query..orderBy([
              (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
            ]))
            .get();
    return results;
  }

  /// Insert a new leave record
  Future<int> addLeave(LeavesTableCompanion leave) async {
    return await into(leavesTable).insert(leave, mode: InsertMode.replace);
  }

  /// Update a single leave record
  Future<int> updateLeave(LeavesTableCompanion leave) async {
    await update(leavesTable).replace(leave);
    return 1;
  }

  /// Update multiple leave records in batch
  Future<void> updateLeavesBatch(List<LeavesTableCompanion> leaves) async {
    await transaction(() async {
      for (final leave in leaves) {
        await update(leavesTable).replace(leave);
      }
    });
  }

  /// Soft delete a leave record
  Future<int> deleteLeave(int id) async {
    return await transaction(() async {
      final rowsAffected =
          await (update(leavesTable)..where((t) => t.id.equals(id))).write(
            LeavesTableCompanion(
              isDeleted: const Value(true),
              modificationDate: Value(DateTime.now().toIso8601String()),
            ),
          );
      return rowsAffected;
    });
  }

  /// Hard delete a leave record (permanent)
  Future<int> deleteLeavePermanent(int id) async {
    return await transaction(() async {
      return await (delete(leavesTable)..where((t) => t.id.equals(id))).go();
    });
  }
}
