import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/staff_usecases.dart';
import 'leave_event_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final GetLeavesUseCase getLeavesUseCase;
  final AddLeaveUseCase addLeaveUseCase;
  final UpdateLeaveUseCase updateLeaveUseCase;
  final UpdateLeavesBatchUseCase updateLeavesBatchUseCase;
  final DeleteLeaveUseCase deleteLeaveUseCase;
  final DeleteLeavePermanentUseCase deleteLeavePermanentUseCase;

  LeaveBloc({
    required this.getLeavesUseCase,
    required this.addLeaveUseCase,
    required this.updateLeaveUseCase,
    required this.updateLeavesBatchUseCase,
    required this.deleteLeaveUseCase,
    required this.deleteLeavePermanentUseCase,
  }) : super(LeaveInitialState()) {
    on<LoadLeavesEvent>(_onLoadLeaves);
    on<AddLeaveEvent>(_onAddLeave);
    on<UpdateLeaveEvent>(_onUpdateLeave);
    on<UpdateLeavesBatchEvent>(_onUpdateLeavesBatch);
    on<DeleteLeaveEvent>(_onDeleteLeave);
  }

  Future<void> _onLoadLeaves(
      LoadLeavesEvent event, Emitter<LeaveState> emit) async {
    emit(LeaveLoadingState());
    try {
      final list = await getLeavesUseCase();
      emit(LeaveLoadedState(list));
    } catch (e) {
      emit(LeaveErrorState(e.toString()));
    }
  }

  Future<void> _onAddLeave(
      AddLeaveEvent event, Emitter<LeaveState> emit) async {
    try {
      await addLeaveUseCase(event.leave);
      event.onSuccess?.call();
      add(LoadLeavesEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(LeaveErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateLeave(
      UpdateLeaveEvent event, Emitter<LeaveState> emit) async {
    try {
      await updateLeaveUseCase(event.leave);
      event.onSuccess?.call();
      add(LoadLeavesEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(LeaveErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateLeavesBatch(
      UpdateLeavesBatchEvent event, Emitter<LeaveState> emit) async {
    try {
      await updateLeavesBatchUseCase(event.leaves);
      event.onSuccess?.call();
      add(LoadLeavesEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(LeaveErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteLeave(
      DeleteLeaveEvent event, Emitter<LeaveState> emit) async {
    try {
      if (event.permanent) {
        await deleteLeavePermanentUseCase(event.id);
      } else {
        await deleteLeaveUseCase(event.id);
      }
      event.onSuccess?.call();
      add(LoadLeavesEvent());
    } catch (e) {
      event.onError?.call(e.toString());
      emit(LeaveErrorState(e.toString()));
    }
  }
}
