import '../entities/menu_item.dart';

abstract class MenuItemRepository {
  Future<List<MenuItem>> getMenuItems();
  Future<List<MenuItem>> getMenuItemsByCategory(int categoryId);
  Future<List<MenuItem>> getMenuItemsBySubcategory(int subcategoryId);
  Future<MenuItem?> getMenuItemById(int id);
  Future<int> addMenuItem(MenuItem item);
  Future<bool> updateMenuItem(MenuItem item);
  Future<bool> deleteMenuItem(int id);
}
