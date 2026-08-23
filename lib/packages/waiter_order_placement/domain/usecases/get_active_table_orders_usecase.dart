import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';

import '../entities/active_table_order.dart';
import '../repositories/waiter_order_placement_repository.dart';

class GetActiveTableOrdersUseCase {
  final WaiterOrderPlacementRepository repository;

  GetActiveTableOrdersUseCase(this.repository);

  Future<Either<Failure, List<ActiveTableOrder>>> call() async {
    return await repository.getActiveTableOrders();
  }

  Stream<List<ActiveTableOrder>> watch() {
    return repository.watchActiveTableOrders();
  }
}
