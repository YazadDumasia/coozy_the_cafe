import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';

import '../repositories/waiter_order_placement_repository.dart';

class DeleteTableOrderUseCase {
  final WaiterOrderPlacementRepository repository;

  DeleteTableOrderUseCase(this.repository);

  Future<Either<Failure, void>> call(int orderId) async {
    return await repository.deleteTableOrder(orderId);
  }
}
