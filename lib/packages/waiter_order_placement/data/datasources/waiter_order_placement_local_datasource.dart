import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/kitchen_management/services/order_print_background_service.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/menu_catalog_data.dart';
import '../../domain/entities/order_cart_item.dart';

import '../../domain/entities/active_table_order.dart';
import '../../domain/entities/order_details.dart';

abstract class WaiterOrderPlacementLocalDataSource {
  Future<MenuCatalogData> getActiveMenuCatalog();
  Future<int> submitOrder({
    required int tableId,
    required String tableName,
    required List<OrderCartItem> cartItems,
    int? orderId,
  });
  Future<OrderDetails> getOrderDetails(int orderId);
  Future<List<ActiveTableOrder>> getActiveTableOrders();
  Stream<List<ActiveTableOrder>> watchActiveTableOrders();
  Future<void> deleteTableOrder(int orderId);
}

class _TempOrderData {
  final Order order;
  final TableInfoData? tableInfo;
  int pendingCount = 0;
  int cookingCount = 0;
  int servedCount = 0;

  _TempOrderData({required this.order, this.tableInfo});

  void addItem(OrderItem item) {
    final st = (item.status ?? '').toLowerCase();
    if (st == 'inpreparation' || st == 'cooking' || st == 'in_progress') {
      cookingCount += item.quantity ?? 1;
    } else if (st == 'ready' || st == 'served' || st == 'completed') {
      servedCount += item.quantity ?? 1;
    } else {
      pendingCount += item.quantity ?? 1;
    }
  }

  ActiveTableOrder toActiveTableOrder() {
    final creationTime = DateTime.tryParse(order.creationDate ?? '')?.toLocal();
    final tableNameDisplay = order.tableNameText?.isNotEmpty == true
        ? order.tableNameText!
        : (tableInfo?.tableNo != null
              ? 'TABLE ${tableInfo!.tableNo}'
              : 'TABLE ${order.id}');

    return ActiveTableOrder(
      orderId: order.id,
      tableId: order.tableInfoId,
      tableName: tableNameDisplay.startsWith('TABLE')
          ? tableNameDisplay
          : 'TABLE - $tableNameDisplay',
      tableShape: 'RECTANGLE',
      tableLocationNotes: tableInfo?.tableLabel ?? 'middle table',
      creationDate: creationTime,
      pendingItemCount: pendingCount,
      cookingItemCount: cookingCount,
      servedItemCount: servedCount,
    );
  }
}

class WaiterOrderPlacementLocalDataSourceImpl
    implements WaiterOrderPlacementLocalDataSource {
  final CoozyDatabase db;
  late final CategoriesDao _categoriesDao;
  late final MenuItemsDao _menuItemsDao;
  late final OrdersDao _ordersDao;

  WaiterOrderPlacementLocalDataSourceImpl(this.db) {
    _categoriesDao = CategoriesDao(db);
    _menuItemsDao = MenuItemsDao(db);
    _ordersDao = OrdersDao(db);
  }

  @override
  Future<MenuCatalogData> getActiveMenuCatalog() async {
    // 1. Fetch active categories ordered by position
    final allCategories = await _categoriesDao.getCategories();
    final activeCategories =
        allCategories.where((c) => c.isActive == true).toList()
          ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

    // 2. Fetch all active menu items with variations
    final availableMenuItems = await _menuItemsDao.getAvailableMenuItems();

    // 3. For each active category, fetch subcategories and group menu items
    final categoryDataList = <MenuCatalogCategoryData>[];

    for (final category in activeCategories) {
      final subcategories = await _categoriesDao.getSubcategoryBaseCategoryId(
        category.id,
      );
      final activeSubcategories =
          (subcategories ?? []).where((s) => s.isActive == true).toList()
            ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

      final itemsForCategory = availableMenuItems.where((itemWithVar) {
        return itemWithVar.item.categoryId == category.id;
      }).toList();

      final activeSubcatIds = activeSubcategories.map((s) => s.id).toSet();

      final uncategorizedItems = itemsForCategory.where((itemWithVar) {
        final subId = itemWithVar.item.subcategoryId;
        return subId == null || !activeSubcatIds.contains(subId);
      }).toList();

      final subcategoryItemsMap = <int, List<MenuItemWithVariations>>{};
      for (final subcat in activeSubcategories) {
        final itemsForSubcat = itemsForCategory.where((itemWithVar) {
          return itemWithVar.item.subcategoryId == subcat.id;
        }).toList();
        subcategoryItemsMap[subcat.id] = itemsForSubcat;
      }

      categoryDataList.add(
        MenuCatalogCategoryData(
          category: category,
          subcategories: activeSubcategories,
          uncategorizedItems: uncategorizedItems,
          subcategoryItems: subcategoryItemsMap,
        ),
      );
    }

    return MenuCatalogData(
      activeCategories: activeCategories,
      categoryDataList: categoryDataList,
    );
  }

  @override
  Future<int> submitOrder({
    required int tableId,
    required String tableName,
    required List<OrderCartItem> cartItems,
    int? orderId,
  }) async {
    return await db.transaction(() async {
      final nowStr = DateTime.now().toIso8601String();
      final int targetOrderId;

      if (orderId != null) {
        targetOrderId = orderId;
        await (db.update(
          db.ordersTable,
        )..where((t) => t.id.equals(orderId))).write(
          OrdersTableCompanion(
            tableInfoId: Value(tableId),
            tableNameText: Value(tableName),
            modificationDate: Value(nowStr),
            status: const Value('placed'),
          ),
        );
        await (db.delete(
          db.orderItemsTable,
        )..where((t) => t.orderId.equals(orderId))).go();
      } else {
        targetOrderId = await db
            .into(db.ordersTable)
            .insert(
              OrdersTableCompanion.insert(
                tableInfoId: Value(tableId),
                tableNameText: Value(tableName),
                creationDate: Value(nowStr),
                status: const Value('placed'),
                isCanceled: const Value(false),
                isDeleted: const Value(false),
              ),
            );
      }

      for (final cartItem in cartItems) {
        await db
            .into(db.orderItemsTable)
            .insert(
              OrderItemsTableCompanion.insert(
                orderId: Value(targetOrderId),
                itemId: Value(cartItem.menuItemId),
                menuItemId: Value(cartItem.menuItemId),
                selectedVariationId: Value(cartItem.variationId),
                quantity: Value(cartItem.quantity),
                sellingPrice: Value(cartItem.price),
                remarks: Value(cartItem.remarks),
                creationDate: Value(nowStr),
                status: Value(OrderItemStatus.pending.value),
              ),
            );
      }

      // Trigger background processing for KOT auto printing & notification
      OrderPrintBackgroundService.instance.processNewOrderPlaced(
        orderId: targetOrderId,
        tableName: tableName,
        cartItems: cartItems,
      );

      return targetOrderId;
    });
  }

  @override
  Future<OrderDetails> getOrderDetails(int orderId) async {
    final orderWithItems = await _ordersDao.getOrderInfo(orderId);
    if (orderWithItems == null) {
      throw Exception('Order #$orderId not found');
    }

    final order = orderWithItems.order;
    final items = orderWithItems.items;

    TableInfoData? tableInfo;
    if (order.tableInfoId != null) {
      tableInfo = await (db.select(
        db.tableInfoTable,
      )..where((t) => t.id.equals(order.tableInfoId!))).getSingleOrNull();
    }

    final tableNameDisplay = order.tableNameText?.isNotEmpty == true
        ? order.tableNameText!
        : (tableInfo?.tableNo != null
              ? 'TABLE ${tableInfo!.tableNo}'
              : 'TABLE ${order.id}');

    final cartItems = <OrderCartItem>[];
    for (final item in items) {
      final menuItemId = item.menuItemId ?? item.itemId;
      if (menuItemId == null) continue;

      final menuItem = await (db.select(
        db.menuItemsTable,
      )..where((m) => m.id.equals(menuItemId))).getSingleOrNull();

      MenuItemVariation? variation;
      if (item.selectedVariationId != null) {
        variation =
            await (db.select(db.menuItemVariationsTable)
                  ..where((v) => v.id.equals(item.selectedVariationId!)))
                .getSingleOrNull();
      }

      final itemName = menuItem?.name ?? 'Item #$menuItemId';
      final price =
          item.sellingPrice ??
          variation?.sellingPrice ??
          menuItem?.sellingPrice ??
          0.0;

      cartItems.add(
        OrderCartItem(
          menuItemId: menuItemId,
          name: itemName,
          variationId: item.selectedVariationId,
          variationName: variation?.name,
          price: price,
          quantity: item.quantity ?? 1,
          remarks: item.remarks,
          subcategoryId: menuItem?.subcategoryId,
          categoryId: menuItem?.categoryId,
        ),
      );
    }

    return OrderDetails(
      orderId: order.id,
      tableId: order.tableInfoId,
      tableName: tableNameDisplay,
      cartItems: cartItems,
    );
  }

  @override
  Future<List<ActiveTableOrder>> getActiveTableOrders() async {
    final activeOrdersWithItems = await _ordersDao.getAllActiveOrders();
    final unpaidOrders = activeOrdersWithItems.where((o) {
      final isNotCanceled = o.order.isCanceled != true;
      final isNotDeleted = o.order.isDeleted != true;
      final isNotPaid =
          o.order.status != 'paid' && o.order.status != 'completed';
      return isNotCanceled && isNotDeleted && isNotPaid;
    }).toList();

    final result = <ActiveTableOrder>[];

    for (final orderWithItems in unpaidOrders) {
      final order = orderWithItems.order;
      final items = orderWithItems.items;

      TableInfoData? tableInfo;
      if (order.tableInfoId != null) {
        tableInfo = await (db.select(
          db.tableInfoTable,
        )..where((t) => t.id.equals(order.tableInfoId!))).getSingleOrNull();
      }

      int pendingCount = 0;
      int cookingCount = 0;
      int servedCount = 0;

      for (final item in items) {
        final st = item.status?.toLowerCase() ?? '';
        if (st == 'inpreparation' || st == 'cooking' || st == 'in_progress') {
          cookingCount += item.quantity ?? 1;
        } else if (st == 'ready' || st == 'served' || st == 'completed') {
          servedCount += item.quantity ?? 1;
        } else {
          pendingCount += item.quantity ?? 1;
        }
      }

      final creationTime = DateTime.tryParse(
        order.creationDate ?? '',
      )?.toLocal();
      final tableNameDisplay = order.tableNameText?.isNotEmpty == true
          ? order.tableNameText!
          : (tableInfo?.tableNo != null
                ? 'TABLE ${tableInfo!.tableNo}'
                : 'TABLE ${order.id}');

      result.add(
        ActiveTableOrder(
          orderId: order.id,
          tableId: order.tableInfoId,
          tableName: tableNameDisplay.startsWith('TABLE')
              ? tableNameDisplay
              : 'TABLE - $tableNameDisplay',
          tableShape: 'RECTANGLE',
          tableLocationNotes: tableInfo?.tableLabel ?? 'middle table',
          creationDate: creationTime,
          pendingItemCount: pendingCount,
          cookingItemCount: cookingCount,
          servedItemCount: servedCount,
        ),
      );
    }

    return result;
  }

  @override
  Stream<List<ActiveTableOrder>> watchActiveTableOrders() {
    final query =
        db.select(db.ordersTable).join([
            leftOuterJoin(
              db.tableInfoTable,
              db.tableInfoTable.id.equalsExp(db.ordersTable.tableInfoId),
            ),
            leftOuterJoin(
              db.orderItemsTable,
              db.orderItemsTable.orderId.equalsExp(db.ordersTable.id),
            ),
          ])
          ..where(
            (db.ordersTable.isCanceled.equals(false) |
                    db.ordersTable.isCanceled.isNull()) &
                (db.ordersTable.isDeleted.equals(false) |
                    db.ordersTable.isDeleted.isNull()) &
                db.ordersTable.status.equals('paid').not() &
                db.ordersTable.status.equals('completed').not(),
          )
          ..orderBy([
            OrderingTerm(
              expression: db.ordersTable.creationDate,
              mode: OrderingMode.desc,
            ),
          ]);

    return query.watch().map((rows) {
      final ordersMap = <int, _TempOrderData>{};

      for (final row in rows) {
        final order = row.readTable(db.ordersTable);
        final tableInfo = row.readTableOrNull(db.tableInfoTable);
        final item = row.readTableOrNull(db.orderItemsTable);

        final data = ordersMap.putIfAbsent(
          order.id,
          () => _TempOrderData(order: order, tableInfo: tableInfo),
        );

        if (item != null) {
          data.addItem(item);
        }
      }

      return ordersMap.values.map((data) => data.toActiveTableOrder()).toList();
    });
  }

  @override
  Future<void> deleteTableOrder(int orderId) async {
    await _ordersDao.updateOrderIsDeleted(orderId: orderId, isDeleted: true);
  }
}
