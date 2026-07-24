import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/staff_entities.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();
  @override
  List<Object?> get props => [];
}

class LoadLeavesEvent extends LeaveEvent {}

class AddLeaveEvent extends LeaveEvent {
  final LeaveEntity leave;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const AddLeaveEvent(this.leave, {this.onSuccess, this.onError});
  @override
  List<Object?> get props => [leave];
}

class UpdateLeaveEvent extends LeaveEvent {
  final LeaveEntity leave;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const UpdateLeaveEvent(this.leave, {this.onSuccess, this.onError});
  @override
  List<Object?> get props => [leave];
}

class UpdateLeavesBatchEvent extends LeaveEvent {
  final List<LeaveEntity> leaves;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const UpdateLeavesBatchEvent(this.leaves, {this.onSuccess, this.onError});
  @override
  List<Object?> get props => [leaves];
}

class DeleteLeaveEvent extends LeaveEvent {
  final int id;
  final bool permanent;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const DeleteLeaveEvent(this.id, {this.permanent = false, this.onSuccess, this.onError});
  @override
  List<Object?> get props => [id, permanent];
}

abstract class LeaveState extends Equatable {
  const LeaveState();
  @override
  List<Object?> get props => [];
}

class LeaveInitialState extends LeaveState {}
class LeaveLoadingState extends LeaveState {}
class LeaveLoadedState extends LeaveState {
  final List<LeaveEntity> leaves;
  const LeaveLoadedState(this.leaves);
  @override
  List<Object?> get props => [leaves];
}
class LeaveErrorState extends LeaveState {
  final String message;
  const LeaveErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
