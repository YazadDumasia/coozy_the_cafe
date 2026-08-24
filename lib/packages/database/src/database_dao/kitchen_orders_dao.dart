import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'kitchen_orders_dao.g.dart';

@DriftAccessor(
  tables: [
    OrdersTable,
    OrderItemsTable,
    MenuItemsTable,
    MenuItemVariationsTable,
  ],
)
class KitchenOrdersDao extends DatabaseAccessor<CoozyDatabase>
    with _$KitchenOrdersDaoMixin {
  KitchenOrdersDao(super.db);

  /// Retrieves all active orders that have items needing preparation.
  /// This joins orders with their pending/preparing items, ordered by oldest first (FIFO).
  Future<List<Map<String, dynamic>>> getActiveKitchenOrders() async {
    String sql =
        "SELECT * FROM orders WHERE (is_canceled = 0 OR is_canceled IS NULL) AND (is_deleted = 0 OR is_deleted IS NULL) AND status NOT IN ('completed', 'served')";
    List<Variable> vars = [];
    sql += " ORDER BY creation_date ASC";

    final ordersQuery = await customSelect(sql, variables: vars).get();

    final result = <Map<String, dynamic>>[];

    for (final orderRow in ordersQuery) {
      final orderMap = Map<String, dynamic>.from(orderRow.data);
      final orderId = orderRow.read<int>('id');

      final itemsQuery = await customSelect(
        '''
        SELECT 
          oi.*,
          mi.name as itemName,
          miv.quantity as variationQuantity,
          miv.purchase_unit as variationUnit
        FROM order_items oi
        LEFT JOIN menu_items mi ON oi.item_id = mi.id
        LEFT JOIN menu_item_variations miv ON oi.selected_variation_id = miv.id
        WHERE oi.order_id = ? 
          AND (oi.status IN ('pending', 'preparing', 'placed') OR oi.status IS NULL OR oi.status = '')
        ''',
        variables: [Variable.withInt(orderId)],
      ).get();

      if (itemsQuery.isNotEmpty) {
        orderMap['orderItems'] = itemsQuery.map((row) => row.data).toList();
        result.add(orderMap);
      }
    }
    return result;
  }

  /// Watches all active orders with pending/preparing items in real-time.
  Stream<List<Map<String, dynamic>>> watchActiveKitchenOrders() {
    String sql =
        "SELECT * FROM orders WHERE (is_canceled = 0 OR is_canceled IS NULL) AND (is_deleted = 0 OR is_deleted IS NULL) AND status NOT IN ('completed', 'served') ORDER BY creation_date ASC";

    return customSelect(
      sql,
      readsFrom: {ordersTable, orderItemsTable},
    ).watch().asyncMap((ordersQuery) async {
      final result = <Map<String, dynamic>>[];

      for (final orderRow in ordersQuery) {
        final orderMap = Map<String, dynamic>.from(orderRow.data);
        final orderId = orderRow.read<int>('id');

        final itemsQuery = await customSelect(
          '''
          SELECT 
            oi.*,
            mi.name as itemName,
            miv.quantity as variationQuantity,
            miv.purchase_unit as variationUnit
          FROM order_items oi
          LEFT JOIN menu_items mi ON oi.item_id = mi.id
          LEFT JOIN menu_item_variations miv ON oi.selected_variation_id = miv.id
          WHERE oi.order_id = ? 
            AND (oi.status IN ('pending', 'preparing', 'placed') OR oi.status IS NULL OR oi.status = '')
          ''',
          variables: [Variable.withInt(orderId)],
        ).get();

        if (itemsQuery.isNotEmpty) {
          orderMap['orderItems'] = itemsQuery.map((row) => row.data).toList();
          result.add(orderMap);
        }
      }
      return result;
    });
  }

  /// Updates the status of a specific order item (e.g., 'pending' -> 'preparing' -> 'ready').
  Future<bool> updateOrderItemStatus(int orderItemId, String status) async {
    final rows =
        await (update(orderItemsTable)..where((t) => t.id.equals(orderItemId)))
            .write(OrderItemsTableCompanion(status: Value(status)));
    return rows > 0;
  }

  /// Marks all items in a specific order as a certain status (e.g., 'ready').
  Future<int> updateAllOrderItemsStatus(int orderId, String status) async {
    return await (update(orderItemsTable)..where(
          (t) =>
              t.orderId.equals(orderId) &
              (t.status.isIn(['pending', 'preparing', 'placed']) |
                  t.status.isNull()),
        ))
        .write(OrderItemsTableCompanion(status: Value(status)));
  }

  /// Gets an aggregated list of items to prepare to optimize kitchen flow.
  Future<List<Map<String, dynamic>>> getAggregatedPendingItems() async {
    String sql = '''
      SELECT 
        mi.name as itemName,
        mc.name as categoryName,
        oi.item_id as itemId,
        oi.remarks,
        oi.is_parcel as isParcel,
        o.order_type as orderType,
        SUM(oi.quantity) as totalQuantity,
        COALESCE(oi.status, 'pending') as status
      FROM order_items oi
      JOIN menu_items mi ON oi.item_id = mi.id
      LEFT JOIN menu_categories mc ON mi.category_id = mc.id
      JOIN orders o ON oi.order_id = o.id
      WHERE (oi.status IN ('pending', 'preparing', 'placed', 'ready') OR oi.status IS NULL OR oi.status = '')
        AND (o.is_canceled = 0 OR o.is_canceled IS NULL)
        AND (o.is_deleted = 0 OR o.is_deleted IS NULL)
    ''';
    List<Variable> vars = [];
    sql += '''
      GROUP BY oi.item_id, oi.selected_variation_id, oi.remarks, oi.is_parcel, o.order_type, COALESCE(oi.status, 'pending'), mi.name, mc.name
      ORDER BY 
        CASE COALESCE(oi.status, 'pending')
          WHEN 'preparing' THEN 1
          WHEN 'pending' THEN 2
          WHEN 'placed' THEN 3
          ELSE 4
        END ASC,
        COALESCE(mc.name, 'Uncategorized') ASC,
        mi.name ASC
      ''';

    final rows = await customSelect(sql, variables: vars).get();

    return rows.map((r) => r.data).toList();
  }

  /// Checks if an entire order is ready (all items are marked 'ready' or 'served').
  Future<bool> isEntireOrderReady(int orderId) async {
    final row = await customSelect(
      "SELECT COUNT(*) as pendingCount FROM order_items WHERE order_id = ? AND (status IN ('pending', 'preparing', 'placed') OR status IS NULL OR status = '')",
      variables: [Variable.withInt(orderId)],
    ).getSingle();

    final pendingCount = row.read<int>('pendingCount');
    return pendingCount == 0;
  }
}
