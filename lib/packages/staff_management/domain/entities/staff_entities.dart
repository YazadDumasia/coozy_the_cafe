import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

// ignore: must_be_immutable
class EmployeeEntity extends Equatable implements shared.ISuspensionBean {
  final int? id;
  final String? name;
  final String? phoneNumber;
  final String? isoCode;
  final String? email;
  final String? addressLine1;
  final String? addressLine2;
  final String? idProof;
  final String? idProofNumber;
  final int? totalLeaves;
  final String? position;
  final double? salary;
  final String? joiningDate;
  final String? leavingDate;
  final String? startWorkingTime;
  final String? endWorkingTime;
  final String? workingHours;
  final String? createdDate;
  final String? modificationDate;
  final bool? isDeleted;

  @override
  bool isShowSuspension = false;

  EmployeeEntity({
    this.id,
    this.name,
    this.phoneNumber,
    this.isoCode,
    this.email,
    this.addressLine1,
    this.addressLine2,
    this.idProof,
    this.idProofNumber,
    this.totalLeaves,
    this.position,
    this.salary,
    this.joiningDate,
    this.leavingDate,
    this.startWorkingTime,
    this.endWorkingTime,
    this.workingHours,
    this.createdDate,
    this.modificationDate,
    this.isDeleted,
    this.isShowSuspension = false,
  });

  @override
  String getSuspensionTag() {
    if (name != null && name!.isNotEmpty) {
      final tag = name![0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(tag)) {
        return tag;
      }
    }
    return '#';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    isoCode,
    email,
    addressLine1,
    addressLine2,
    idProof,
    idProofNumber,
    totalLeaves,
    position,
    salary,
    createdDate,
    modificationDate,
    isDeleted,
    // New fields
    joiningDate,
    leavingDate,
    startWorkingTime,
    endWorkingTime,
    workingHours,
    isShowSuspension,
  ];
}

class AttendanceEntity extends Equatable {
  final int? id;
  final int? employeeId;
  final String? employeeName;
  final String? date;
  final String? status;
  // New fields matching AttendanceTable
  final String? checkIn;
  final String? checkOut;
  final String? employeeWorkingDurations;
  final String? workingTimeDurations;
  final String? notes;
  final String? createdDate;
  final String? modificationDate;
  final bool? isDeleted;

  const AttendanceEntity({
    this.id,
    this.employeeId,
    this.employeeName,
    this.date,
    this.status,
    // New fields
    this.checkIn,
    this.checkOut,
    this.employeeWorkingDurations,
    this.workingTimeDurations,
    this.notes,
    this.createdDate,
    this.modificationDate,
    this.isDeleted,
  });

  @override
  List<Object?> get props => [
    id,
    employeeId,
    employeeName,
    date,
    status,
    // New fields
    checkIn,
    checkOut,
    employeeWorkingDurations,
    workingTimeDurations,
    notes,
    createdDate,
    modificationDate,
    isDeleted,
  ];
}

class LeaveEntity extends Equatable {
  final int? id;
  final int? employeeId;
  final String? employeeName;
  final String? startDate;
  final String? endDate;
  // New fields
  final String? startDateTime;
  final String? endDateTime;
  final String? leaveType;
  final String? status;
  final String? reason;
  final String? appliedDate;
  final String? createdDate;
  final String? modificationDate;
  final bool? isDeleted;

  const LeaveEntity({
    this.id,
    this.employeeId,
    this.employeeName,
    this.startDate,
    this.endDate,
    // New fields
    this.startDateTime,
    this.endDateTime,
    this.leaveType,
    this.status,
    this.reason,
    this.appliedDate,
    this.createdDate,
    this.modificationDate,
    this.isDeleted,
  });

  @override
  List<Object?> get props => [
    id,
    employeeId,
    employeeName,
    startDate,
    endDate,
    // New fields
    startDateTime,
    endDateTime,
    leaveType,
    status,
    reason,
    appliedDate,
    createdDate,
    modificationDate,
    isDeleted,
  ];
}
