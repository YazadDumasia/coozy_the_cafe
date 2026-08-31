import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'orders_dao.g.dart';

class OrderWithItems {
  final Order order;
  final List<OrderItem> items;

  OrderWithItems({required this.order, required this.items});
}

@DriftAccessor(
  tables: [
    OrdersTable,
    OrderItemsTable,
    CustomersTable,
    MenuItemsTable,
    MenuItemVariationsTable,
    TableInfoTable,
  ],
)
class OrdersDao extends DatabaseAccessor<CoozyDatabase> with _$OrdersDaoMixin {
  OrdersDao(super.db);

  Future<Order?> getOrderByReservationId(int reservationId) async {
    final query = select(ordersTable)
      ..where((t) => t.reservationId.equals(reservationId));
    return query.getSingleOrNull();
  }

  /// Converts a pre-order linked to a reservation into an active dine-in order
  /// when the customer arrives and is seated at a table.
  Future<void> handleReservationArrival({
    required int reservationId,
    required int tableInfoId,
  }) async {
    final order = await getOrderByReservationId(reservationId);
    if (order != null) {
      await (update(ordersTable)..where((t) => t.id.equals(order.id))).write(
        OrdersTableCompanion(
          tableInfoId: Value(tableInfoId),
          status: const Value('inProgress'),
          orderType: const Value('Dine-In'),
          modificationDate: Value(DateTime.now().toUtc().toIso8601String()),
        ),
      );
    }
  }

  /// Marks an order and its items as completed upon successful payment.
  Future<void> markOrderCompleted(int orderId) async {
    final currentDate = DateTime.now().toUtc().toIso8601String();
    await transaction(() async {
      await (update(ordersTable)..where((t) => t.id.equals(orderId))).write(
        OrdersTableCompanion(
          status: const Value('completed'),
          modificationDate: Value(currentDate),
        ),
      );
      await (update(orderItemsTable)..where((t) => t.orderId.equals(orderId))).write(
        const OrderItemsTableCompanion(
          status: Value('completed'),
        ),
      );
    });
  }

  Future<int> createNewOrder({
    required OrdersTableCompanion order,
    required List<OrderItemsTableCompanion> orderItems,
    CustomersTableCompanion? customer,
  }) async {
    return transaction(() async {
      int? customerId = order.customerId.present
          ? order.customerId.value
          : null;

      if (customer != null) {
        customerId = await into(
          customersTable,
        ).insert(customer, mode: InsertMode.replace);
      }

      final finalOrder = customerId != null
          ? order.copyWith(customerId: Value(customerId))
          : order;

      final orderId = await into(
        ordersTable,
      ).insert(finalOrder, mode: InsertMode.replace);

      for (final item in orderItems) {
        await into(orderItemsTable).insert(
          item.copyWith(orderId: Value(orderId)),
          mode: InsertMode.replace,
        );
      }
      return orderId;
    });
  }

  Future<void> updateOrder({
    required int orderId,
    required OrdersTableCompanion order,
    List<OrderItemsTableCompanion>? orderItems,
  }) async {
    await transaction(() async {
      await (update(
        ordersTable,
      )..where((t) => t.id.equals(orderId))).write(order);

      if (orderItems != null) {
        await (delete(
          orderItemsTable,
        )..where((t) => t.orderId.equals(orderId))).go();
        for (final item in orderItems) {
          await into(
            orderItemsTable,
          ).insert(item.copyWith(orderId: Value(orderId)));
        }
      }
    });
  }

  Future<OrderWithItems?> getOrderInfo(int orderId) async {
    return transaction(() async {
      final query = select(ordersTable)..where((t) => t.id.equals(orderId));
      final order = await query.getSingleOrNull();
      if (order == null) return null;

      final items = await (select(
        orderItemsTable,
      )..where((t) => t.orderId.equals(orderId))).get();

      return OrderWithItems(order: order, items: items);
    });
  }

  Future<int> updateOrderIsDeleted({
    required int orderId,
    required bool isDeleted,
  }) async {
    final currentStatus = isDeleted ? 'deleted' : 'newOrder';
    final currentDate = DateTime.now().toUtc().toIso8601String();

    return transaction(() async {
      await (update(ordersTable)..where((t) => t.id.equals(orderId))).write(
        OrdersTableCompanion(
          isDeleted: Value(isDeleted),
          status: Value(currentStatus),
          creationDate: isDeleted ? const Value.absent() : Value(currentDate),
          modificationDate: isDeleted
              ? const Value.absent()
              : Value(currentDate),
        ),
      );

      final itemStatus = isDeleted ? 'deleted' : 'newOrder';
      await (update(orderItemsTable)..where((t) => t.orderId.equals(orderId)))
          .write(OrderItemsTableCompanion(status: Value(itemStatus)));

      final countExpr = orderItemsTable.id.count();
      final query = selectOnly(orderItemsTable)
        ..addColumns([countExpr])
        ..where(orderItemsTable.orderId.equals(orderId));
      final result = await query.getSingle();
      return result.read(countExpr) ?? 0;
    });
  }

  Future<int> updateOrderIsCanceled(int orderId, bool isCanceled) async {
    final currentStatus = isCanceled ? 'cancelled' : 'newOrder';
    final currentDate = DateTime.now().toUtc().toIso8601String();

    return transaction(() async {
      await (update(ordersTable)..where((t) => t.id.equals(orderId))).write(
        OrdersTableCompanion(
          isCanceled: Value(isCanceled),
          status: Value(currentStatus),
          modificationDate: Value(currentDate),
          creationDate: isCanceled ? const Value.absent() : Value(currentDate),
        ),
      );

      if (!isCanceled) {
        await (update(
          orderItemsTable,
        )..where((t) => t.orderId.equals(orderId))).write(
          OrderItemsTableCompanion(
            status: const Value('newOrder'),
            creationDate: Value(currentDate),
          ),
        );
      } else {
        await (update(orderItemsTable)..where((t) => t.orderId.equals(orderId)))
            .write(const OrderItemsTableCompanion(status: Value('cancelled')));
      }

      final countExpr = orderItemsTable.id.count();
      final query = selectOnly(orderItemsTable)
        ..addColumns([countExpr])
        ..where(orderItemsTable.orderId.equals(orderId));
      final result = await query.getSingle();
      return result.read(countExpr) ?? 0;
    });
  }

  Future<List<OrderWithItems>> getAllOrders() async {
    return transaction(() async {
      final query = select(ordersTable);
      final orders =
          await (query..orderBy([
                (t) => OrderingTerm(
                  expression: t.creationDate,
                  mode: OrderingMode.desc,
                ),
              ]))
              .get();
      if (orders.isEmpty) return [];

      final allItems = await select(orderItemsTable).get();
      final itemsMap = <int, List<OrderItem>>{};
      for (final item in allItems) {
        itemsMap.putIfAbsent(item.orderId!, () => []).add(item);
      }

      return orders
          .map((o) => OrderWithItems(order: o, items: itemsMap[o.id] ?? []))
          .toList();
    });
  }

  Future<List<OrderWithItems>> getAllOrdersWithPagination({
    required int limit,
    required int pageNo,
  }) async {
    final offset = (pageNo - 1) * limit;
    return transaction(() async {
      final query = select(ordersTable);
      final orders =
          await (query
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.creationDate,
                    mode: OrderingMode.desc,
                  ),
                ])
                ..limit(limit, offset: offset))
              .get();
      if (orders.isEmpty) return [];

      final orderIds = orders.map((o) => o.id).toList();
      final allItems = await (select(
        orderItemsTable,
      )..where((t) => t.orderId.isIn(orderIds))).get();
      final itemsMap = <int, List<OrderItem>>{};
      for (final item in allItems) {
        itemsMap.putIfAbsent(item.orderId!, () => []).add(item);
      }

      return orders
          .map((o) => OrderWithItems(order: o, items: itemsMap[o.id] ?? []))
          .toList();
    });
  }

  Future<List<OrderWithItems>> getAllActiveOrders() async {
    return transaction(() async {
      final query = select(ordersTable)
        ..where((t) => (t.isDeleted.equals(false) | t.isDeleted.isNull()));
      final orders =
          await (query..orderBy([
                (t) => OrderingTerm(
                  expression: t.creationDate,
                  mode: OrderingMode.asc,
                ),
              ]))
              .get();
      if (orders.isEmpty) return [];

      final orderIds = orders.map((o) => o.id).toList();
      final allItems = await (select(
        orderItemsTable,
      )..where((t) => t.orderId.isIn(orderIds))).get();
      final itemsMap = <int, List<OrderItem>>{};
      for (final item in allItems) {
        itemsMap.putIfAbsent(item.orderId!, () => []).add(item);
      }

      return orders
          .map((o) => OrderWithItems(order: o, items: itemsMap[o.id] ?? []))
          .toList();
    });
  }

  Future<List<OrderWithItems>> getInProgressOrders() async {
    return transaction(() async {
      final query = select(ordersTable)
        ..where(
          (t) =>
              t.status.equals('inProgress') &
              (t.isCanceled.equals(false) | t.isCanceled.isNull()) &
              (t.isDeleted.equals(false) | t.isDeleted.isNull()),
        );
      final orders =
          await (query..orderBy([
                (t) => OrderingTerm(
                  expression: t.creationDate,
                  mode: OrderingMode.asc,
                ),
              ]))
              .get();
      if (orders.isEmpty) return [];

      final orderIds = orders.map((o) => o.id).toList();
      final allItems = await (select(
        orderItemsTable,
      )..where((t) => t.orderId.isIn(orderIds))).get();
      final itemsMap = <int, List<OrderItem>>{};
      for (final item in allItems) {
        itemsMap.putIfAbsent(item.orderId!, () => []).add(item);
      }

      return orders
          .map((o) => OrderWithItems(order: o, items: itemsMap[o.id] ?? []))
          .toList();
    });
  }

  Future<List<OrderWithItems>> getNewOrders() async {
    return transaction(() async {
      final query = select(ordersTable)
        ..where(
          (t) =>
              t.status.equals('newOrder') &
              (t.isCanceled.equals(false) | t.isCanceled.isNull()) &
              (t.isDeleted.equals(false) | t.isDeleted.isNull()),
        );
      final orders =
          await (query..orderBy([
                (t) => OrderingTerm(
                  expression: t.creationDate,
                  mode: OrderingMode.asc,
                ),
              ]))
              .get();
      if (orders.isEmpty) return [];

      final orderIds = orders.map((o) => o.id).toList();
      final allItems = await (select(
        orderItemsTable,
      )..where((t) => t.orderId.isIn(orderIds))).get();
      final itemsMap = <int, List<OrderItem>>{};
      for (final item in allItems) {
        itemsMap.putIfAbsent(item.orderId!, () => []).add(item);
      }

      return orders
          .map((o) => OrderWithItems(order: o, items: itemsMap[o.id] ?? []))
          .toList();
    });
  }

  Future<List<OrderWithItems>> getCurrentOrdersInfo() async {
    final inProgress = await getInProgressOrders();
    final newOrders = await getNewOrders();
    return [...inProgress, ...newOrders];
  }

  Future<List<Map<String, dynamic>>> getOrderedItemsAndNumbersByStatus(
    String status, {
    int chunkSize = 1000,
  }) async {
    final baseQuery = '''
      SELECT 
        mi.name AS menuItemName, 
        SUM(oi.quantity) AS itemQuantity, 
        GROUP_CONCAT(DISTINCT ti.name) AS tableNames
      FROM order_items oi
      INNER JOIN menu_items mi ON oi.item_id = mi.id
      INNER JOIN orders o ON oi.order_id = o.id
      INNER JOIN table_info ti ON o.table_info_id = ti.id
      WHERE o.is_canceled = 0 
        AND o.is_deleted = 0
        AND o.status = ?
        AND oi.status IN ('newOrder', 'inPreparation')
      GROUP BY mi.name
      ORDER BY mi.name ASC
      LIMIT ? OFFSET ?
    ''';

    final countQuery = '''
      SELECT COUNT(DISTINCT mi.name) as totalCount
      FROM order_items oi
      INNER JOIN menu_items mi ON oi.item_id = mi.id
      INNER JOIN orders o ON oi.order_id = o.id
      WHERE o.is_canceled = 0 
        AND o.is_deleted = 0
        AND o.status = ?
        AND oi.status IN ('newOrder', 'inPreparation')
    ''';

    final countResult = await customSelect(
      countQuery,
      variables: [Variable.withString(status)],
    ).getSingle();
    final totalCount = countResult.read<int>('totalCount');

    List<Map<String, dynamic>> allResults = [];
    for (int offset = 0; offset < totalCount; offset += chunkSize) {
      final chunkResults = await customSelect(
        baseQuery,
        variables: [
          Variable.withString(status),
          Variable.withInt(chunkSize),
          Variable.withInt(offset),
        ],
      ).get();

      allResults.addAll(
        chunkResults.map((row) {
          final concatenatedTables = row.read<String?>('tableNames');
          final q = row.data['itemQuantity'];
          return {
            'itemName': row.read<String?>('menuItemName') ?? '',
            'quantity': (q is num) ? q.toInt() : 0,
            'tableList': concatenatedTables?.split(',') ?? <String>[],
          };
        }),
      );
    }
    return allResults;
  }

  Future<List<Map<String, dynamic>>> getOrderedItemsForKitchen(
    String status, {
    int chunkSize = 100,
  }) async {
    final baseQuery = '''
      SELECT
        mi.name AS menuItemName,
        SUM(oi.quantity) AS TotalOrderedQuantity,
        CASE
          WHEN oi.is_menu_item = 1 THEN mi.quantity
          ELSE miv.quantity
        END AS quantity,
        CASE
          WHEN oi.is_menu_item = 1 THEN mi.purchase_unit
          ELSE miv.purchase_unit
        END AS purchaseUnit,
        GROUP_CONCAT(ti.name) AS tableInfoNames
      FROM order_items oi
      LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id AND oi.is_menu_item = 1
      LEFT JOIN menu_item_variations miv ON oi.selected_variation_id = miv.id AND oi.is_menu_item = 0
      LEFT JOIN orders o ON oi.order_id = o.id
      LEFT JOIN table_info ti ON o.table_info_id = ti.id
      WHERE o.is_canceled = 0 AND o.is_deleted = 0
        AND o.status = ?
        AND oi.status IN ('inPreparation', 'newOrder')
      GROUP BY mi.name, mi.quantity, mi.purchase_unit, miv.quantity, miv.purchase_unit
      ORDER BY o.creation_date ASC
      LIMIT ? OFFSET ?
    ''';

    final countQuery = '''
      SELECT COUNT(*) as total FROM order_items oi 
      LEFT JOIN orders o ON oi.order_id = o.id
      WHERE o.is_canceled = 0 AND o.is_deleted = 0 AND o.status = ? AND oi.status IN ('inPreparation', 'newOrder')
    ''';

    final countResult = await customSelect(
      countQuery,
      variables: [Variable.withString(status)],
    ).getSingle();
    final totalCount = countResult.read<int>('total');

    List<Map<String, dynamic>> allResults = [];
    for (int offset = 0; offset < totalCount; offset += chunkSize) {
      final chunkResults = await customSelect(
        baseQuery,
        variables: [
          Variable.withString(status),
          Variable.withInt(chunkSize),
          Variable.withInt(offset),
        ],
      ).get();

      allResults.addAll(
        chunkResults.map((row) {
          final tableNamesStr = row.read<String?>('tableInfoNames');
          return {
            'orderItemName': row.read<String?>('menuItemName'),
            'TotalOrderedQuantity': row.read<int?>('TotalOrderedQuantity'),
            'measureInfoQuantity': row.data['quantity'],
            'measureInfoPurchaseUnit': row.read<String?>('purchaseUnit'),
            'tableInfoNames': tableNamesStr != null
                ? tableNamesStr.split(',').map((e) => e.trim()).toList()
                : <String>[],
          };
        }),
      );
    }
    return allResults;
  }
}
