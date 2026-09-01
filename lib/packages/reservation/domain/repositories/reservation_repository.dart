import '../entities/reservation_entity.dart';

abstract class ReservationRepository {
  Future<List<ReservationEntity>> getCurrentReservations();

  Future<List<ReservationEntity>> getUpcomingReservations({
    required int limit,
    required int pageNo,
  });

  Future<int> getUpcomingReservationsCount();

  Future<List<ReservationEntity>> searchReservations({
    required String query,
    required int limit,
    required int pageNo,
  });

  Future<ReservationEntity?> getReservationById(int id);

  Future<int> createReservation(ReservationEntity reservation);

  Future<bool> updateReservation(ReservationEntity reservation);

  Future<bool> updateReservationStatus({required int id, required int status});

  Future<int> deleteReservation(int id);

  Future<int> convertReservationToOrder(ReservationEntity reservation);
}
