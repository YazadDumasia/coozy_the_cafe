import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/staff_usecases.dart';
import 'attendance_event_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetAttendanceUseCase getAttendanceUseCase;
  final AddAttendanceUseCase addAttendanceUseCase;
  final UpdateAttendanceUseCase updateAttendanceUseCase;
  final DeleteAttendanceUseCase deleteAttendanceUseCase;
  final DeletePermanentlyAttendanceUseCase deletePermanentlyAttendanceUseCase;

  AttendanceBloc({
    required this.getAttendanceUseCase,
    required this.addAttendanceUseCase,
    required this.updateAttendanceUseCase,
    required this.deleteAttendanceUseCase,
    required this.deletePermanentlyAttendanceUseCase,
  }) : super(AttendanceInitialState()) {
    on<LoadAttendanceEvent>(_onLoadAttendance);
    on<AddAttendanceEvent>(_onAddAttendance);
    on<UpdateAttendanceEvent>(_onUpdateAttendance);
    on<DeleteAttendanceEvent>(_onDeleteAttendance);
  }

  Future<void> _onLoadAttendance(
      LoadAttendanceEvent event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoadingState());
    try {
      final list = await getAttendanceUseCase();
      emit(AttendanceLoadedState(list));
    } catch (e) {
      emit(AttendanceErrorState(e.toString()));
    }
  }

  Future<void> _onAddAttendance(
      AddAttendanceEvent event, Emitter<AttendanceState> emit) async {
    try {
      await addAttendanceUseCase(event.attendance);
      event.onSuccess?.call();
      add(LoadAttendanceEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(AttendanceErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateAttendance(
      UpdateAttendanceEvent event, Emitter<AttendanceState> emit) async {
    try {
      await updateAttendanceUseCase(event.attendance);
      event.onSuccess?.call();
      add(LoadAttendanceEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(AttendanceErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteAttendance(
      DeleteAttendanceEvent event, Emitter<AttendanceState> emit) async {
    try {
      if (event.permanent) {
        await deletePermanentlyAttendanceUseCase(event.id);
      } else {
        await deleteAttendanceUseCase(event.id);
      }
      event.onSuccess?.call();
      add(LoadAttendanceEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(AttendanceErrorState(e.toString()));
    }
  }
}
