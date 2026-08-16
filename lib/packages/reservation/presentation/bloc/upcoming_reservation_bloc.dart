import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/usecases/reservation_usecases.dart';

abstract class UpcomingReservationEvent extends Equatable {
  const UpcomingReservationEvent();
  @override
  List<Object?> get props => [];
}

class FetchUpcomingReservations extends UpcomingReservationEvent {
  final bool isRefresh;
  const FetchUpcomingReservations({this.isRefresh = false});
  @override
  List<Object?> get props => [isRefresh];
}

class SearchUpcomingReservations extends UpcomingReservationEvent {
  final String query;
  const SearchUpcomingReservations(this.query);
  @override
  List<Object?> get props => [query];
}

class RemoveUpcomingReservation extends UpcomingReservationEvent {
  final int id;
  const RemoveUpcomingReservation(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateUpcomingReservation extends UpcomingReservationEvent {
  final ReservationEntity reservation;
  const UpdateUpcomingReservation(this.reservation);
  @override
  List<Object?> get props => [reservation];
}

abstract class UpcomingReservationState extends Equatable {
  const UpcomingReservationState();
  @override
  List<Object?> get props => [];
}

class UpcomingReservationInitial extends UpcomingReservationState {}

class UpcomingReservationLoading extends UpcomingReservationState {}

class UpcomingReservationLoaded extends UpcomingReservationState {
  final List<ReservationEntity> reservations;
  final bool hasReachedMax;
  final int pageNo;
  final String searchQuery;

  const UpcomingReservationLoaded({
    required this.reservations,
    required this.hasReachedMax,
    required this.pageNo,
    this.searchQuery = '',
  });

  UpcomingReservationLoaded copyWith({
    List<ReservationEntity>? reservations,
    bool? hasReachedMax,
    int? pageNo,
    String? searchQuery,
  }) {
    return UpcomingReservationLoaded(
      reservations: reservations ?? this.reservations,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      pageNo: pageNo ?? this.pageNo,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [reservations, hasReachedMax, pageNo, searchQuery];
}

class UpcomingReservationError extends UpcomingReservationState {
  final String message;
  const UpcomingReservationError(this.message);
  @override
  List<Object?> get props => [message];
}

class UpcomingReservationBloc
    extends Bloc<UpcomingReservationEvent, UpcomingReservationState> {
  final GetUpcomingReservationsUseCase getUpcomingReservationsUseCase;
  final SearchReservationsUseCase searchReservationsUseCase;
  static const int _limit = 15;

  UpcomingReservationBloc({
    required this.getUpcomingReservationsUseCase,
    required this.searchReservationsUseCase,
  }) : super(UpcomingReservationInitial()) {
    on<FetchUpcomingReservations>(_onFetchUpcoming);
    on<SearchUpcomingReservations>(_onSearchUpcoming);
    on<RemoveUpcomingReservation>(_onRemoveUpcoming);
    on<UpdateUpcomingReservation>(_onUpdateUpcoming);
  }

  void _onRemoveUpcoming(
    RemoveUpcomingReservation event,
    Emitter<UpcomingReservationState> emit,
  ) {
    if (state is UpcomingReservationLoaded) {
      final currentState = state as UpcomingReservationLoaded;
      final updatedList = currentState.reservations
          .where((item) => item.id != event.id)
          .toList();
      emit(currentState.copyWith(reservations: updatedList));
    }
  }

  void _onUpdateUpcoming(
    UpdateUpcomingReservation event,
    Emitter<UpcomingReservationState> emit,
  ) {
    if (state is UpcomingReservationLoaded) {
      final currentState = state as UpcomingReservationLoaded;
      final currentList = List<ReservationEntity>.from(
        currentState.reservations,
      );
      final index = currentList.indexWhere(
        (item) => item.id == event.reservation.id,
      );
      if (index != -1) {
        currentList[index] = event.reservation;
        emit(currentState.copyWith(reservations: currentList));
      } else {
        add(const FetchUpcomingReservations(isRefresh: true));
      }
    } else {
      add(const FetchUpcomingReservations(isRefresh: true));
    }
  }

  Future<void> _onFetchUpcoming(
    FetchUpcomingReservations event,
    Emitter<UpcomingReservationState> emit,
  ) async {
    if (event.isRefresh || state is UpcomingReservationInitial) {
      emit(UpcomingReservationLoading());
      try {
        final reservations = await getUpcomingReservationsUseCase(
          limit: _limit,
          pageNo: 1,
        );
        emit(
          UpcomingReservationLoaded(
            reservations: reservations,
            hasReachedMax: reservations.length < _limit,
            pageNo: 1,
          ),
        );
      } catch (e) {
        emit(UpcomingReservationError(e.toString()));
      }
      return;
    }

    if (state is UpcomingReservationLoaded) {
      final currentState = state as UpcomingReservationLoaded;
      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.pageNo + 1;
        final List<ReservationEntity> newItems;

        if (currentState.searchQuery.isNotEmpty) {
          newItems = await searchReservationsUseCase(
            query: currentState.searchQuery,
            limit: _limit,
            pageNo: nextPage,
          );
        } else {
          newItems = await getUpcomingReservationsUseCase(
            limit: _limit,
            pageNo: nextPage,
          );
        }

        emit(
          newItems.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : UpcomingReservationLoaded(
                  reservations: currentState.reservations + newItems,
                  hasReachedMax: newItems.length < _limit,
                  pageNo: nextPage,
                  searchQuery: currentState.searchQuery,
                ),
        );
      } catch (e) {
        emit(UpcomingReservationError(e.toString()));
      }
    }
  }

  Future<void> _onSearchUpcoming(
    SearchUpcomingReservations event,
    Emitter<UpcomingReservationState> emit,
  ) async {
    emit(UpcomingReservationLoading());
    try {
      if (event.query.trim().isEmpty) {
        final reservations = await getUpcomingReservationsUseCase(
          limit: _limit,
          pageNo: 1,
        );
        emit(
          UpcomingReservationLoaded(
            reservations: reservations,
            hasReachedMax: reservations.length < _limit,
            pageNo: 1,
            searchQuery: '',
          ),
        );
      } else {
        final reservations = await searchReservationsUseCase(
          query: event.query.trim(),
          limit: _limit,
          pageNo: 1,
        );
        emit(
          UpcomingReservationLoaded(
            reservations: reservations,
            hasReachedMax: reservations.length < _limit,
            pageNo: 1,
            searchQuery: event.query.trim(),
          ),
        );
      }
    } catch (e) {
      emit(UpcomingReservationError(e.toString()));
    }
  }
}
