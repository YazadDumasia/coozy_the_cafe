import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
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
  final CoozyDatabase database;

  MenuItemLocalDataSourceImpl({required this.database});

  MenuItemsDao get _menuItemsDao => database.menuItemsDao;

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    final results = await _menuItemsDao.getAllMenuItems();
    if (results == null) return [];
    return results.map((m) {
      final variations = m.variations
          .map((v) => MenuItemVariationModel.fromData(v))
          .toList();
      return MenuItemModel.fromData(m.item, variations);
    }).toList();
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsByCategory(int categoryId) async {
    final all = await getMenuItems();
    return all.where((item) => item.categoryId == categoryId).toList();
  }

  @override
  Future<List<MenuItemModel>> getMenuItemsBySubcategory(
    int subcategoryId,
  ) async {
    final all = await getMenuItems();
    return all.where((item) => item.subcategoryId == subcategoryId).toList();
  }

  @override
  Future<MenuItemModel?> getMenuItemById(int id) async {
    final m = await _menuItemsDao.getMenuItemById(id);
    if (m == null) return null;
    final variations = m.variations
        .map((v) => MenuItemVariationModel.fromData(v))
        .toList();
    return MenuItemModel.fromData(m.item, variations);
  }

  @override
  Future<int> insertMenuItem(MenuItemModel item) async {
    final variationsCompanions = item.variations
        .map((v) => MenuItemVariationModel.fromEntity(v).toCompanion())
        .toList();
    return await _menuItemsDao.createMenuItem(
      item: item.toCompanion(),
      variations: variationsCompanions,
    );
  }

  @override
  Future<bool> updateMenuItem(MenuItemModel item) async {
    if (item.id == null) return false;
    final variationsCompanions = item.variations
        .map((v) => MenuItemVariationModel.fromEntity(v).toCompanion())
        .toList();
    return await _menuItemsDao.updateMenuItem(
      id: item.id!,
      item: item.toCompanion(),
      variations: variationsCompanions,
    );
  }

  @override
  Future<bool> deleteMenuItem(int id) async {
    await _menuItemsDao.deleteMenuItem(id);
    return true;
  }
}
