import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../entities/order_cart_item.dart';
import '../repositories/waiter_order_placement_repository.dart';

class SubmitOrderUseCase {
  final WaiterOrderPlacementRepository repository;

  SubmitOrderUseCase(this.repository);

  Future<Either<Failure, int>> call({
    required int tableId,
    required String tableName,
    required List<OrderCartItem> cartItems,
  }) async {
    return await repository.submitOrder(
      tableId: tableId,
      tableName: tableName,
      cartItems: cartItems,
    );
  }
}
