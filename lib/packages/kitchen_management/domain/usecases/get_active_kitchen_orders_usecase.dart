import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../entities/kitchen_order_entity.dart';
import '../repositories/kitchen_repository.dart';

class GetActiveKitchenOrdersUseCase {
  final KitchenRepository repository;

  GetActiveKitchenOrdersUseCase(this.repository);

  Future<Either<Failure, List<KitchenOrderEntity>>> call() {
    return repository.getActiveKitchenOrders();
  }
}
