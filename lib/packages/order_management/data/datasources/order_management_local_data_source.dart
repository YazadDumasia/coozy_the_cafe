import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../models/order_management_model.dart';

abstract class OrderManagementLocalDataSource {
  Future<(List<OrderManagementModel>, int)> getPaginatedOrders({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? status,
  });

  Future<OrderManagementModel?> getOrderInfo(int orderId);

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  });
}

class OrderManagementLocalDataSourceImpl
    implements OrderManagementLocalDataSource {
  final OrdersDao ordersDao;

  OrderManagementLocalDataSourceImpl({required this.ordersDao});

  @override
  Future<(List<OrderManagementModel>, int)> getPaginatedOrders({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? status,
  }) async {
    final rawOrders = await ordersDao.getPaginatedOrdersWithFilters(
      limit: limit,
      pageNo: pageNo,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      status: status,
    );
    final count = await ordersDao.getOrdersCountWithFilters(
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      status: status,
    );

    final allItems = rawOrders.expand((o) => o.items).toList();
    final itemNamesMap = await _getItemNamesMap(allItems);
    final models = rawOrders
        .map((o) => OrderManagementModel.fromDrift(o, itemNamesMap: itemNamesMap))
        .toList();

    return (models, count);
  }

  @override
  Future<OrderManagementModel?> getOrderInfo(int orderId) async {
    final orderWithItems = await ordersDao.getOrderInfo(orderId);
    if (orderWithItems == null) return null;
    final itemNamesMap = await _getItemNamesMap(orderWithItems.items);
    return OrderManagementModel.fromDrift(
      orderWithItems,
      itemNamesMap: itemNamesMap,
    );
  }

  Future<Map<int, String>> _getItemNamesMap(List<OrderItem> items) async {
    final db = ordersDao.attachedDatabase;
    final itemNamesMap = <int, String>{};
    for (final item in items) {
      final menuItemId = item.menuItemId ?? item.itemId;
      if (menuItemId == null || itemNamesMap.containsKey(item.id)) continue;

      final menuItem = await (db.select(db.menuItemsTable)
            ..where((m) => m.id.equals(menuItemId)))
          .getSingleOrNull();

      if (menuItem != null && menuItem.name.isNotEmpty) {
        String name = menuItem.name;
        if (item.selectedVariationId != null) {
          final variation = await (db.select(db.menuItemVariationsTable)
                ..where((v) => v.id.equals(item.selectedVariationId!)))
              .getSingleOrNull();
          if (variation != null &&
              variation.name != null &&
              variation.name!.isNotEmpty) {
            name = '$name (${variation.name})';
          }
        }
        itemNamesMap[item.id] = name;
      }
    }
    return itemNamesMap;
  }

  @override
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    if (status == 'completed') {
      await ordersDao.markOrderCompleted(orderId);
    } else if (status == 'cancelled') {
      await ordersDao.updateOrderIsCanceled(orderId, true);
    } else if (status == 'deleted') {
      await ordersDao.updateOrderIsDeleted(orderId: orderId, isDeleted: true);
    }
  }
}
