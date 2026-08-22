import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/menu_catalog_data.dart';
import '../../domain/entities/order_cart_item.dart';

abstract class WaiterOrderPlacementLocalDataSource {
  Future<MenuCatalogData> getActiveMenuCatalog();
  Future<int> submitOrder({
    required int tableId,
    required String tableName,
    required List<OrderCartItem> cartItems,
  });
}

class WaiterOrderPlacementLocalDataSourceImpl
    implements WaiterOrderPlacementLocalDataSource {
  final CoozyDatabase db;
  late final CategoriesDao _categoriesDao;
  late final MenuItemsDao _menuItemsDao;

  WaiterOrderPlacementLocalDataSourceImpl(this.db) {
    _categoriesDao = CategoriesDao(db);
    _menuItemsDao = MenuItemsDao(db);
  }

  @override
  Future<MenuCatalogData> getActiveMenuCatalog() async {
    // 1. Fetch active categories ordered by position
    final allCategories = await _categoriesDao.getCategories();
    final activeCategories = allCategories
        .where((c) => c.isActive == true)
        .toList()
      ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

    // 2. Fetch all active menu items with variations
    final availableMenuItems = await _menuItemsDao.getAvailableMenuItems();

    // 3. For each active category, fetch subcategories and group menu items
    final categoryDataList = <MenuCatalogCategoryData>[];

    for (final category in activeCategories) {
      final subcategories = await _categoriesDao.getSubcategoryBaseCategoryId(category.id);
      final activeSubcategories = (subcategories ?? [])
          .where((s) => s.isActive == true)
          .toList()
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
  }) async {
    return await db.transaction(() async {
      final nowStr = DateTime.now().toIso8601String();
      final orderId = await db.into(db.ordersTable).insert(
            OrdersTableCompanion.insert(
              tableInfoId: Value(tableId),
              tableNameText: Value(tableName),
              creationDate: Value(nowStr),
              status: const Value('placed'),
              isCanceled: const Value(false),
              isDeleted: const Value(false),
            ),
          );

      for (final cartItem in cartItems) {
        await db.into(db.orderItemsTable).insert(
              OrderItemsTableCompanion.insert(
                orderId: Value(orderId),
                itemId: Value(cartItem.menuItemId),
                menuItemId: Value(cartItem.menuItemId),
                selectedVariationId: Value(cartItem.variationId),
                quantity: Value(cartItem.quantity),
                sellingPrice: Value(cartItem.price),
                remarks: Value(cartItem.remarks),
                creationDate: Value(nowStr),
              ),
            );
      }
      return orderId;
    });
  }
}
