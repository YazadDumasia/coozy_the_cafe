import '../entities/reservation_entity.dart';
import '../repositories/reservation_repository.dart';

class GetCurrentReservationsUseCase {
  final ReservationRepository repository;

  GetCurrentReservationsUseCase(this.repository);

  Future<List<ReservationEntity>> call() {
    return repository.getCurrentReservations();
  }
}

class GetUpcomingReservationsUseCase {
  final ReservationRepository repository;

  GetUpcomingReservationsUseCase(this.repository);

  Future<List<ReservationEntity>> call({
    required int limit,
    required int pageNo,
  }) {
    return repository.getUpcomingReservations(limit: limit, pageNo: pageNo);
  }
}

class SearchReservationsUseCase {
  final ReservationRepository repository;

  SearchReservationsUseCase(this.repository);

  Future<List<ReservationEntity>> call({
    required String query,
    required int limit,
    required int pageNo,
  }) {
    return repository.searchReservations(
      query: query,
      limit: limit,
      pageNo: pageNo,
    );
  }
}

class CreateReservationUseCase {
  final ReservationRepository repository;

  CreateReservationUseCase(this.repository);

  Future<int> call(ReservationEntity reservation) {
    return repository.createReservation(reservation);
  }
}

class UpdateReservationUseCase {
  final ReservationRepository repository;

  UpdateReservationUseCase(this.repository);

  Future<bool> call(ReservationEntity reservation) {
    return repository.updateReservation(reservation);
  }
}

class DeleteReservationUseCase {
  final ReservationRepository repository;

  DeleteReservationUseCase(this.repository);

  Future<int> call(int id) {
    return repository.deleteReservation(id);
  }
}

class UpdateReservationStatusUseCase {
  final ReservationRepository repository;

  UpdateReservationStatusUseCase(this.repository);

  Future<bool> call({required int id, required int status}) {
    return repository.updateReservationStatus(id: id, status: status);
  }
}
