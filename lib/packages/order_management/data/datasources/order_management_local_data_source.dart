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

    final models =
        rawOrders.map((o) => OrderManagementModel.fromDrift(o)).toList();

    return (models, count);
  }

  @override
  Future<OrderManagementModel?> getOrderInfo(int orderId) async {
    final orderWithItems = await ordersDao.getOrderInfo(orderId);
    if (orderWithItems == null) return null;
    return OrderManagementModel.fromDrift(orderWithItems);
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
