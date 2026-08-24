import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../repositories/kitchen_repository.dart';

class UpdateOrderItemStatusUseCase {
  final KitchenRepository repository;

  UpdateOrderItemStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required int orderItemId,
    required String status,
  }) {
    return repository.updateOrderItemStatus(
      orderItemId: orderItemId,
      status: status,
    );
  }
}
