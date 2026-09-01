import '../entities/reservation_entity.dart';
import '../repositories/reservation_repository.dart';

class ConvertReservationToOrderUseCase {
  final ReservationRepository repository;

  ConvertReservationToOrderUseCase(this.repository);

  Future<int> call(ReservationEntity reservation) {
    return repository.convertReservationToOrder(reservation);
  }
}
