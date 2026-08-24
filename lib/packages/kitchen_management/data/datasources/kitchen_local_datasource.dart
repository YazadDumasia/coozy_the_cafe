import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

abstract class KitchenLocalDataSource {
  Future<List<Map<String, dynamic>>> getActiveKitchenOrders();
  Stream<List<Map<String, dynamic>>> watchActiveKitchenOrders();
  Future<bool> updateOrderItemStatus({
    required int orderItemId,
    required String status,
  });
  Future<int> updateAllOrderItemsStatus({
    required int orderId,
    required String status,
  });
  Future<List<Map<String, dynamic>>> getAggregatedPendingItems();
}

class KitchenLocalDataSourceImpl implements KitchenLocalDataSource {
  final CoozyDatabase database;

  KitchenLocalDataSourceImpl(this.database);

  @override
  Future<List<Map<String, dynamic>>> getActiveKitchenOrders() {
    return database.kitchenOrdersDao.getActiveKitchenOrders();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchActiveKitchenOrders() {
    return database.kitchenOrdersDao.watchActiveKitchenOrders();
  }


  @override
  Future<bool> updateOrderItemStatus({
    required int orderItemId,
    required String status,
  }) {
    return database.kitchenOrdersDao.updateOrderItemStatus(orderItemId, status);
  }

  @override
  Future<int> updateAllOrderItemsStatus({
    required int orderId,
    required String status,
  }) {
    return database.kitchenOrdersDao.updateAllOrderItemsStatus(orderId, status);
  }

  @override
  Future<List<Map<String, dynamic>>> getAggregatedPendingItems() {
    return database.kitchenOrdersDao.getAggregatedPendingItems();
  }
}
