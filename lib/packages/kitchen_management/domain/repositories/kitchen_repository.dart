import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../entities/kitchen_aggregated_item_entity.dart';
import '../entities/kitchen_order_entity.dart';

abstract class KitchenRepository {
  Future<Either<Failure, List<KitchenOrderEntity>>> getActiveKitchenOrders();
  Stream<List<KitchenOrderEntity>> watchActiveKitchenOrders();

  Future<Either<Failure, bool>> updateOrderItemStatus({
    required int orderItemId,
    required String status,
  });
  Future<Either<Failure, int>> updateAllOrderItemsStatus({
    required int orderId,
    required String status,
  });
  Future<Either<Failure, List<KitchenAggregatedItemEntity>>> getAggregatedPendingItems();
}
