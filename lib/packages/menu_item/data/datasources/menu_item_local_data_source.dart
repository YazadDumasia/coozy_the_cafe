import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart' as db;
import '../models/menu_item_model.dart';
import '../models/menu_item_variation_model.dart';

abstract class MenuItemLocalDataSource {
  Future<List<MenuItemModel>> getMenuItems();
  Future<List<MenuItemModel>> getMenuItemsByCategory(int categoryId);
  Future<List<MenuItemModel>> getMenuItemsBySubcategory(int subcategoryId);
  Future<MenuItemModel?> getMenuItemById(int id);
  Future<int> insertMenuItem(MenuItemModel item);
  Future<bool> updateMenuItem(MenuItemModel item);
  Future<bool> deleteMenuItem(int id);
}

class MenuItemLocalDataSourceImpl implements MenuItemLocalDataSource {
  final db.CoozyDatabase database;

  MenuItemLocalDataSourceImpl({required this.database});

  Future<List<MenuItemVariationModel>> _getVariationsForItem(int itemId) async {
    final query = database.select(database.menuItemVariationsTable)
      ..where((v) => v.menuItemId.equals(itemId))
      ..orderBy([
        (v) =>
            OrderingTerm(expression: v.sortOrderIndex, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return results.map((v) => MenuItemVariationModel.fromData(v)).toList();
  }

  Future<List<MenuItemModel>> _mapItemsWithVariations(
    List<db.MenuItem> itemsData,
  ) async {
    List<MenuItemModel> items = [];
    for (var itemData in itemsData) {
      final variations = await _getVariationsForItem(itemData.id);
      items.add(MenuItemModel.fromData(itemData, variations));
    }
    return items;
  }

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    final query = database.select(database.menuItemsTable)
      ..orderBy([
        (m) =>
            OrderingTerm(expression: m.sortOrderIndex, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return _mapItemsWithVariations(results);
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory(int categoryId) async {
    final query = database.select(database.menuItemsTable)
      ..where((m) => m.categoryId.equals(categoryId))
      ..orderBy([
        (m) =>
            OrderingTerm(expression: m.sortOrderIndex, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return _mapItemsWithVariations(results);
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsBySubcategory(
    int subcategoryId,
  ) async {
    final query = database.select(database.menuItemsTable)
      ..where((m) => m.subcategoryId.equals(subcategoryId))
      ..orderBy([
        (m) =>
            OrderingTerm(expression: m.sortOrderIndex, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return _mapItemsWithVariations(results);
  }

  @override
  Future<MenuItemModel?> getMenuItemById(int id) async {
    final query = database.select(database.menuItemsTable)
      ..where((m) => m.id.equals(id));
    final itemData = await query.getSingleOrNull();
    if (itemData != null) {
      final variations = await _getVariationsForItem(itemData.id);
      return MenuItemModel.fromData(itemData, variations);
    }
    return null;
  }

  @override
  Future<int> insertMenuItem(MenuItemModel item) async {
    return await database.transaction(() async {
      // 1. Insert item
      final itemId = await database
          .into(database.menuItemsTable)
          .insert(item.toCompanion());

      // 2. Insert variations
      for (var variation in item.variations) {
        final companion = MenuItemVariationModel.fromEntity(
          variation,
        ).toCompanion().copyWith(menuItemId: Value(itemId));
        await database.into(database.menuItemVariationsTable).insert(companion);
      }
      return itemId;
    });
  }

  @override
  Future<bool> updateMenuItem(MenuItemModel item) async {
    if (item.id == null) return false;

    return await database.transaction(() async {
      // 1. Update main item
      await database
          .update(database.menuItemsTable)
          .replace(item.toCompanion());

      // 2. Delete old variations
      await (database.delete(
        database.menuItemVariationsTable,
      )..where((v) => v.menuItemId.equals(item.id!))).go();

      // 3. Insert new variations
      for (var variation in item.variations) {
        final companion = MenuItemVariationModel.fromEntity(
          variation,
        ).toCompanion().copyWith(menuItemId: Value(item.id!));
        await database.into(database.menuItemVariationsTable).insert(companion);
      }
      return true;
    });
  }

  @override
  Future<bool> deleteMenuItem(int id) async {
    // Variations are automatically deleted due to ON DELETE CASCADE setup in schema.
    final deleted = await (database.delete(
      database.menuItemsTable,
    )..where((m) => m.id.equals(id))).go();
    return deleted > 0;
  }
}
