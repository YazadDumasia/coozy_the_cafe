import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../repositories/kitchen_repository.dart';

class UpdateAllOrderItemsStatusUseCase {
  final KitchenRepository repository;

  UpdateAllOrderItemsStatusUseCase(this.repository);

  Future<Either<Failure, int>> call({
    required int orderId,
    required String status,
  }) {
    return repository.updateAllOrderItemsStatus(
      orderId: orderId,
      status: status,
    );
  }
}
