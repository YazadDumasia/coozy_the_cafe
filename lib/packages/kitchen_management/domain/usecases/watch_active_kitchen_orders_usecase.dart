import '../entities/kitchen_order_entity.dart';
import '../repositories/kitchen_repository.dart';

class WatchActiveKitchenOrdersUseCase {
  final KitchenRepository repository;

  WatchActiveKitchenOrdersUseCase(this.repository);

  Stream<List<KitchenOrderEntity>> call() {
    return repository.watchActiveKitchenOrders();
  }
}
