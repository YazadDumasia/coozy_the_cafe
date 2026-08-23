import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../entities/order_details.dart';
import '../repositories/waiter_order_placement_repository.dart';

class GetOrderDetailsUseCase {
  final WaiterOrderPlacementRepository repository;

  GetOrderDetailsUseCase(this.repository);

  Future<Either<Failure, OrderDetails>> call(int orderId) async {
    return await repository.getOrderDetails(orderId);
  }
}
