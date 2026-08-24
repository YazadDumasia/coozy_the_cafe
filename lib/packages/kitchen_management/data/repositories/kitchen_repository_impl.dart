import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/kitchen_aggregated_item_entity.dart';
import '../../domain/entities/kitchen_order_entity.dart';
import '../../domain/entities/kitchen_order_item_entity.dart';
import '../../domain/repositories/kitchen_repository.dart';
import '../datasources/kitchen_local_datasource.dart';

class KitchenRepositoryImpl implements KitchenRepository {
  final KitchenLocalDataSource localDataSource;

  KitchenRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<KitchenOrderEntity>>>
  getActiveKitchenOrders() async {
    try {
      final rawOrders = await localDataSource.getActiveKitchenOrders();
      final orders = rawOrders.map((rawOrder) {
        final rawItems = (rawOrder['orderItems'] as List<dynamic>?) ?? [];
        final items = rawItems.map((rawItem) {
          final itemMap = Map<String, dynamic>.from(rawItem as Map);
          return KitchenOrderItemEntity(
            id: itemMap['id'] as int,
            orderId: itemMap['order_id'] as int?,
            itemId: itemMap['item_id'] as int?,
            itemName: (itemMap['itemName'] as String?) ?? 'Unknown Item',
            quantity: (itemMap['quantity'] as int?) ?? 1,
            status: (itemMap['status'] as String?) ?? 'pending',
            remarks: itemMap['remarks'] as String?,
            isParcel: (itemMap['is_parcel'] as int? ?? 0) == 1,
            variationQuantity: itemMap['variationQuantity']?.toString(),
            variationUnit: itemMap['variationUnit']?.toString(),
          );
        }).toList();

        return KitchenOrderEntity(
          id: rawOrder['id'] as int,
          tableInfoId: rawOrder['table_info_id'] as int?,
          tableNameText: rawOrder['table_name_text'] as String?,
          creationDate: rawOrder['creation_date'] as String?,
          status: rawOrder['status'] as String?,
          orderType: rawOrder['order_type'] as String?,
          customerName: rawOrder['customer_name'] as String?,
          items: items,
        );
      }).toList();

      return Right(orders);
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to fetch kitchen orders: $e'),
      );
    }
  }

  @override
  Stream<List<KitchenOrderEntity>> watchActiveKitchenOrders() {
    return localDataSource.watchActiveKitchenOrders().map((rawOrders) {
      return rawOrders.map((rawOrder) {
        final rawItems = (rawOrder['orderItems'] as List<dynamic>?) ?? [];
        final items = rawItems.map((rawItem) {
          final itemMap = Map<String, dynamic>.from(rawItem as Map);
          return KitchenOrderItemEntity(
            id: itemMap['id'] as int,
            orderId: itemMap['order_id'] as int?,
            itemId: itemMap['item_id'] as int?,
            itemName: (itemMap['itemName'] as String?) ?? 'Unknown Item',
            quantity: (itemMap['quantity'] as int?) ?? 1,
            status: (itemMap['status'] as String?) ?? 'pending',
            remarks: itemMap['remarks'] as String?,
            isParcel: (itemMap['is_parcel'] as int? ?? 0) == 1,
            variationQuantity: itemMap['variationQuantity']?.toString(),
            variationUnit: itemMap['variationUnit']?.toString(),
          );
        }).toList();

        return KitchenOrderEntity(
          id: rawOrder['id'] as int,
          tableInfoId: rawOrder['table_info_id'] as int?,
          tableNameText: rawOrder['table_name_text'] as String?,
          creationDate: rawOrder['creation_date'] as String?,
          status: rawOrder['status'] as String?,
          orderType: rawOrder['order_type'] as String?,
          customerName: rawOrder['customer_name'] as String?,
          items: items,
        );
      }).toList();
    });
  }

  @override
  Future<Either<Failure, bool>> updateOrderItemStatus({
    required int orderItemId,
    required String status,
  }) async {
    try {
      final success = await localDataSource.updateOrderItemStatus(
        orderItemId: orderItemId,
        status: status,
      );
      return Right(success);
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to update order item status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, int>> updateAllOrderItemsStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final updatedCount = await localDataSource.updateAllOrderItemsStatus(
        orderId: orderId,
        status: status,
      );
      return Right(updatedCount);
    } catch (e) {
      return Left(
        DatabaseFailure(message: 'Failed to bump all order items: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<KitchenAggregatedItemEntity>>>
  getAggregatedPendingItems() async {
    try {
      final rawAggregated = await localDataSource.getAggregatedPendingItems();
      final items = rawAggregated.map((row) {
        return KitchenAggregatedItemEntity(
          itemName: (row['itemName'] as String?) ?? 'Unknown Item',
          categoryName: row['categoryName'] as String?,
          itemId: row['itemId'] as int?,
          remarks: row['remarks'] as String?,
          isParcel: (row['isParcel'] as int? ?? 0) == 1,
          orderType: row['orderType'] as String?,
          totalQuantity: (row['totalQuantity'] as num?)?.toInt() ?? 0,
          status: (row['status'] as String?) ?? 'pending',
        );
      }).toList();

      return Right(items);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Failed to fetch aggregated pending items: $e',
        ),
      );
    }
  }
}
