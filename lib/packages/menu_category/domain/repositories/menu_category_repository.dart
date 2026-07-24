import '../entities/menu_category.dart';

abstract class MenuCategoryRepository {
  Future<List<MenuCategory>> getCategories();
  Future<int> addCategory(MenuCategory category);
  Future<bool> updateCategory(MenuCategory category);
  Future<bool> deleteCategory(int id);
  Future<void> updateCategoryPositions(List<MenuCategory> categories);
}
