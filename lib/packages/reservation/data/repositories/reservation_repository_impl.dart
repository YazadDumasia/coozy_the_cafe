import '../../domain/entities/reservation_entity.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_local_data_source.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationLocalDataSource localDataSource;

  ReservationRepositoryImpl(this.localDataSource);

  @override
  Future<List<ReservationEntity>> getCurrentReservations() {
    return localDataSource.getCurrentReservations();
  }

  @override
  Future<List<ReservationEntity>> getUpcomingReservations({
    required int limit,
    required int pageNo,
  }) {
    return localDataSource.getUpcomingReservations(
      limit: limit,
      pageNo: pageNo,
    );
  }

  @override
  Future<List<ReservationEntity>> searchReservations({
    required String query,
    required int limit,
    required int pageNo,
  }) {
    return localDataSource.searchReservations(
      query: query,
      limit: limit,
      pageNo: pageNo,
    );
  }

  @override
  Future<ReservationEntity?> getReservationById(int id) {
    return localDataSource.getReservationById(id);
  }

  @override
  Future<int> createReservation(ReservationEntity reservation) {
    return localDataSource.createReservation(reservation);
  }

  @override
  Future<bool> updateReservation(ReservationEntity reservation) {
    return localDataSource.updateReservation(reservation);
  }

  @override
  Future<bool> updateReservationStatus({required int id, required int status}) {
    return localDataSource.updateReservationStatus(id: id, status: status);
  }

  @override
  Future<int> deleteReservation(int id) {
    return localDataSource.deleteReservation(id);
  }
}
