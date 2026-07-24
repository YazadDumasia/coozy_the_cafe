import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/staff_entities.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class LoadAttendanceEvent extends AttendanceEvent {}

class AddAttendanceEvent extends AttendanceEvent {
  final AttendanceEntity attendance;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const AddAttendanceEvent(this.attendance, {this.onSuccess, this.onError});
  @override
  List<Object?> get props => [attendance];
}

class UpdateAttendanceEvent extends AttendanceEvent {
  final AttendanceEntity attendance;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const UpdateAttendanceEvent(this.attendance, {this.onSuccess, this.onError});
  @override
  List<Object?> get props => [attendance];
}

class DeleteAttendanceEvent extends AttendanceEvent {
  final int id;
  final bool permanent;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const DeleteAttendanceEvent(this.id, {this.permanent = false, this.onSuccess, this.onError});
  @override
  List<Object?> get props => [id, permanent];
}

abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitialState extends AttendanceState {}
class AttendanceLoadingState extends AttendanceState {}
class AttendanceLoadedState extends AttendanceState {
  final List<AttendanceEntity> attendanceList;
  const AttendanceLoadedState(this.attendanceList);
  @override
  List<Object?> get props => [attendanceList];
}
class AttendanceErrorState extends AttendanceState {
  final String message;
  const AttendanceErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
