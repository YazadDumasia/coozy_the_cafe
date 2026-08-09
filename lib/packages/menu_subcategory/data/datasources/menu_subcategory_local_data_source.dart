import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../models/menu_subcategory_model.dart';

abstract class MenuSubcategoryLocalDataSource {
  Future<List<MenuSubcategoryModel>> getSubcategories();
  Future<List<MenuSubcategoryModel>> getSubcategoriesByCategoryId(
    int categoryId,
  );
  Future<int> insertSubcategory(MenuSubcategoryModel subcategory);
  Future<bool> updateSubcategory(MenuSubcategoryModel subcategory);
  Future<bool> deleteSubcategory(int id);
  Future<void> updatePositions(List<MenuSubcategoryModel> subcategories);
}

class MenuSubcategoryLocalDataSourceImpl
    implements MenuSubcategoryLocalDataSource {
  final CoozyDatabase database;

  MenuSubcategoryLocalDataSourceImpl({required this.database});

  CategoriesDao get _categoriesDao => database.categoriesDao;

  @override
  Future<List<MenuSubcategoryModel>> getSubcategories() async {
    final results = await _categoriesDao.getSubcategories();
    return (results ?? [])
        .map((data) => MenuSubcategoryModel.fromData(data))
        .toList();
  }

  @override
  Future<List<MenuSubcategoryModel>> getSubcategoriesByCategoryId(
    int categoryId,
  ) async {
    final results = await _categoriesDao.getSubcategoryBaseCategoryId(
      categoryId,
    );
    return (results ?? [])
        .map((data) => MenuSubcategoryModel.fromData(data))
        .toList();
  }

  @override
  Future<int> insertSubcategory(MenuSubcategoryModel subcategory) async {
    return await _categoriesDao.createSubcategory(subcategory.toCompanion());
  }

  @override
  Future<bool> updateSubcategory(MenuSubcategoryModel subcategory) async {
    if (subcategory.id != null) {
      final result = await _categoriesDao.updateSubcategory(
        subcategory.id!,
        subcategory.toCompanion(),
      );
      return result != null && result > 0;
    }
    return false;
  }

  @override
  Future<bool> deleteSubcategory(int id) async {
    final deleted = await _categoriesDao.deleteSubcategory(id);
    return deleted != null && deleted > 0;
  }

  @override
  Future<void> updatePositions(List<MenuSubcategoryModel> subcategories) async {
    await database.batch((batch) {
      for (final sub in subcategories) {
        batch.update(
          database.subcategoriesTable,
          sub.toCompanion(),
          where: (s) => s.id.equals(sub.id!),
        );
      }
    });
  }
}
