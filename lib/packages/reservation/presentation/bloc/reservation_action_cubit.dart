import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/usecases/reservation_usecases.dart';

abstract class ReservationActionState extends Equatable {
  const ReservationActionState();
  @override
  List<Object?> get props => [];
}

class ReservationActionInitial extends ReservationActionState {}

class ReservationActionLoading extends ReservationActionState {}

class ReservationActionSuccess extends ReservationActionState {
  final String message;
  const ReservationActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ReservationActionError extends ReservationActionState {
  final String message;
  const ReservationActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class ReservationActionCubit extends Cubit<ReservationActionState> {
  final CreateReservationUseCase createReservationUseCase;
  final UpdateReservationUseCase updateReservationUseCase;
  final DeleteReservationUseCase deleteReservationUseCase;
  final UpdateReservationStatusUseCase updateReservationStatusUseCase;

  ReservationActionCubit({
    required this.createReservationUseCase,
    required this.updateReservationUseCase,
    required this.deleteReservationUseCase,
    required this.updateReservationStatusUseCase,
  }) : super(ReservationActionInitial());

  Future<void> createReservation(ReservationEntity reservation) async {
    emit(ReservationActionLoading());
    try {
      await createReservationUseCase(reservation);
      emit(const ReservationActionSuccess('Reservation created successfully'));
    } catch (e) {
      emit(ReservationActionError(e.toString()));
    }
  }

  Future<void> updateReservation(ReservationEntity reservation) async {
    emit(ReservationActionLoading());
    try {
      await updateReservationUseCase(reservation);
      emit(const ReservationActionSuccess('Reservation updated successfully'));
    } catch (e) {
      emit(ReservationActionError(e.toString()));
    }
  }

  Future<void> updateReservationStatus({
    required int id,
    required int status,
  }) async {
    emit(ReservationActionLoading());
    try {
      await updateReservationStatusUseCase(id: id, status: status);
      emit(const ReservationActionSuccess('Status updated successfully'));
    } catch (e) {
      emit(ReservationActionError(e.toString()));
    }
  }

  Future<void> deleteReservation(int id) async {
    emit(ReservationActionLoading());
    try {
      await deleteReservationUseCase(id);
      emit(const ReservationActionSuccess('Reservation deleted successfully'));
    } catch (e) {
      emit(ReservationActionError(e.toString()));
    }
  }
}
