// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_management_dao.dart';

// ignore_for_file: type=lint
mixin _$StaffManagementDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $EmployeesTableTable get employeesTable => attachedDatabase.employeesTable;
  $AttendanceTableTable get attendanceTable => attachedDatabase.attendanceTable;
  $LeavesTableTable get leavesTable => attachedDatabase.leavesTable;
  StaffManagementDaoManager get managers => StaffManagementDaoManager(this);
}

class StaffManagementDaoManager {
  final _$StaffManagementDaoMixin _db;
  StaffManagementDaoManager(this._db);
  $$EmployeesTableTableTableManager get employeesTable =>
      $$EmployeesTableTableTableManager(
        _db.attachedDatabase,
        _db.employeesTable,
      );
  $$AttendanceTableTableTableManager get attendanceTable =>
      $$AttendanceTableTableTableManager(
        _db.attachedDatabase,
        _db.attendanceTable,
      );
  $$LeavesTableTableTableManager get leavesTable =>
      $$LeavesTableTableTableManager(_db.attachedDatabase, _db.leavesTable);
}
