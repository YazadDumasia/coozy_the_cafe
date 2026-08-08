import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/staff_entities.dart';
import '../../../domain/usecases/staff_usecases.dart';
import 'employee_event_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final GetEmployeesUseCase getEmployeesUseCase;
  final AddEmployeeUseCase addEmployeeUseCase;
  final UpdateEmployeeUseCase updateEmployeeUseCase;
  final DeleteSoftEmployeeUseCase deleteSoftEmployeeUseCase;
  final DeletePermanentEmployeeUseCase deletePermanentEmployeeUseCase;

  List<EmployeeEntity> _allEmployees = [];
  String _currentQuery = '';

  EmployeeBloc({
    required this.getEmployeesUseCase,
    required this.addEmployeeUseCase,
    required this.updateEmployeeUseCase,
    required this.deleteSoftEmployeeUseCase,
    required this.deletePermanentEmployeeUseCase,
  }) : super(EmployeeInitialState()) {
    on<LoadEmployeesEvent>(_onLoadEmployees);
    on<SearchEmployeesEvent>(_onSearchEmployees);
    on<AddEmployeeEvent>(_onAddEmployee);
    on<UpdateEmployeeEvent>(_onUpdateEmployee);
    on<DeleteEmployeeEvent>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployees(
    LoadEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(EmployeeLoadingState());
    try {
      _allEmployees = await getEmployeesUseCase();
      _emitFilteredEmployees(emit);
    } catch (e) {
      emit(EmployeeErrorState(e.toString()));
    }
  }

  void _onSearchEmployees(
    SearchEmployeesEvent event,
    Emitter<EmployeeState> emit,
  ) {
    _currentQuery = event.query.toLowerCase();
    _emitFilteredEmployees(emit);
  }

  void _emitFilteredEmployees(Emitter<EmployeeState> emit) {
    final filtered = _allEmployees.where((e) {
      final nameMatch = (e.name ?? '').toLowerCase().contains(_currentQuery);
      final posMatch = (e.position ?? '').toLowerCase().contains(_currentQuery);
      final phoneMatch = (e.phoneNumber ?? '').toLowerCase().contains(
        _currentQuery,
      );
      return nameMatch || posMatch || phoneMatch;
    }).toList();

    shared.SuspensionUtil.sortListBySuspensionTag(filtered);
    shared.SuspensionUtil.setShowSuspensionStatus(filtered);

    emit(EmployeeLoadedState(filtered));
  }

  Future<void> _onAddEmployee(
    AddEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await addEmployeeUseCase(event.employee);
      event.onSuccess?.call();
      add(LoadEmployeesEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(EmployeeErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      await updateEmployeeUseCase(event.employee);
      event.onSuccess?.call();
      add(LoadEmployeesEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(EmployeeErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployeeEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      if (event.permanent) {
        await deletePermanentEmployeeUseCase(event.id);
      } else {
        await deleteSoftEmployeeUseCase(event.id);
      }
      event.onSuccess?.call();
      add(LoadEmployeesEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(EmployeeErrorState(e.toString()));
    }
  }
}
