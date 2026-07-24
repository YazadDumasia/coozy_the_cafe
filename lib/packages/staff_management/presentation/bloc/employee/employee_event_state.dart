import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/staff_entities.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();
  @override
  List<Object?> get props => [];
}

class LoadEmployeesEvent extends EmployeeEvent {}

class SearchEmployeesEvent extends EmployeeEvent {
  final String query;
  const SearchEmployeesEvent(this.query);
  @override
  List<Object?> get props => [query];
}

class AddEmployeeEvent extends EmployeeEvent {
  final EmployeeEntity employee;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const AddEmployeeEvent(this.employee, {this.onSuccess, this.onError});
  @override
  List<Object?> get props => [employee];
}

class UpdateEmployeeEvent extends EmployeeEvent {
  final EmployeeEntity employee;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const UpdateEmployeeEvent(this.employee, {this.onSuccess, this.onError});
  @override
  List<Object?> get props => [employee];
}

class DeleteEmployeeEvent extends EmployeeEvent {
  final int id;
  final bool permanent;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;
  const DeleteEmployeeEvent(this.id, {this.permanent = false, this.onSuccess, this.onError});
  @override
  List<Object?> get props => [id, permanent];
}

abstract class EmployeeState extends Equatable {
  const EmployeeState();
  @override
  List<Object?> get props => [];
}

class EmployeeInitialState extends EmployeeState {}
class EmployeeLoadingState extends EmployeeState {}
class EmployeeLoadedState extends EmployeeState {
  final List<EmployeeEntity> employees;
  const EmployeeLoadedState(this.employees);
  @override
  List<Object?> get props => [employees];
}
class EmployeeErrorState extends EmployeeState {
  final String message;
  const EmployeeErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
