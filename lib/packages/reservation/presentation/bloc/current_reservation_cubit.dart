import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/usecases/reservation_usecases.dart';

abstract class CurrentReservationState extends Equatable {
  const CurrentReservationState();
  @override
  List<Object?> get props => [];
}

class CurrentReservationInitial extends CurrentReservationState {}

class CurrentReservationLoading extends CurrentReservationState {}

class CurrentReservationLoaded extends CurrentReservationState {
  final List<ReservationEntity> reservations;
  const CurrentReservationLoaded(this.reservations);
  @override
  List<Object?> get props => [reservations];
}

class CurrentReservationError extends CurrentReservationState {
  final String message;
  const CurrentReservationError(this.message);
  @override
  List<Object?> get props => [message];
}

class CurrentReservationCubit extends Cubit<CurrentReservationState> {
  final GetCurrentReservationsUseCase getCurrentReservationsUseCase;

  CurrentReservationCubit({required this.getCurrentReservationsUseCase})
    : super(CurrentReservationInitial());

  Future<void> fetchCurrentReservations() async {
    emit(CurrentReservationLoading());
    try {
      final list = await getCurrentReservationsUseCase();
      emit(CurrentReservationLoaded(list));
    } catch (e) {
      emit(CurrentReservationError(e.toString()));
    }
  }

  void removeReservation(int id) {
    if (state is CurrentReservationLoaded) {
      final currentList = (state as CurrentReservationLoaded).reservations;
      final updatedList = currentList.where((item) => item.id != id).toList();
      emit(CurrentReservationLoaded(updatedList));
    }
  }

  void updateOrAddReservation(ReservationEntity reservation) {
    if (state is CurrentReservationLoaded) {
      final currentList = List<ReservationEntity>.from(
        (state as CurrentReservationLoaded).reservations,
      );
      final index = currentList.indexWhere((item) => item.id == reservation.id);
      if (index != -1) {
        currentList[index] = reservation;
        emit(CurrentReservationLoaded(currentList));
      } else {
        fetchCurrentReservations();
      }
    } else {
      fetchCurrentReservations();
    }
  }
}
