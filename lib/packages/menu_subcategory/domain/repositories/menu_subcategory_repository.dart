import '../entities/menu_subcategory.dart';

abstract class MenuSubcategoryRepository {
  Future<List<MenuSubcategory>> getSubcategories();
  Future<List<MenuSubcategory>> getSubcategoriesByCategoryId(int categoryId);
  Future<int> addSubcategory(MenuSubcategory subcategory);
  Future<bool> updateSubcategory(MenuSubcategory subcategory);
  Future<bool> deleteSubcategory(int id);
  Future<void> updateSubcategoryPositions(List<MenuSubcategory> subcategories);
}
