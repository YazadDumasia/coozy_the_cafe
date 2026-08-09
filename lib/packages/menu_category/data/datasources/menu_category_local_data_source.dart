import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../models/menu_category_model.dart';

abstract class MenuCategoryLocalDataSource {
  Future<List<MenuCategoryModel>> getCategories();
  Future<int> insertCategory(MenuCategoryModel category);
  Future<bool> updateCategory(MenuCategoryModel category);
  Future<bool> deleteCategory(int id);
  Future<void> updatePositions(List<MenuCategoryModel> categories);
}

class MenuCategoryLocalDataSourceImpl implements MenuCategoryLocalDataSource {
  final CoozyDatabase database;

  MenuCategoryLocalDataSourceImpl({required this.database});

  CategoriesDao get _categoriesDao => database.categoriesDao;

  @override
  Future<List<MenuCategoryModel>> getCategories() async {
    final results = await _categoriesDao.getCategories();
    return results.map((data) => MenuCategoryModel.fromData(data)).toList();
  }

  @override
  Future<int> insertCategory(MenuCategoryModel category) async {
    final result = await _categoriesDao.addCategory(category.toCompanion());
    return result ?? 0;
  }

  @override
  Future<bool> updateCategory(MenuCategoryModel category) async {
    if (category.id != null) {
      final result = await _categoriesDao.updateCategory(
        category.id!,
        category.toCompanion(),
      );
      return result != null && result > 0;
    }
    return false;
  }

  @override
  Future<bool> deleteCategory(int id) async {
    final cat = await _categoriesDao.getCategoryBasedOnCategoryId(
      categoryId: id,
    );
    if (cat != null) {
      final result = await _categoriesDao.deleteCategory(cat);
      return result != null && result > 0;
    }
    return false;
  }

  @override
  Future<void> updatePositions(List<MenuCategoryModel> categories) async {
    await database.batch((batch) {
      for (final cat in categories) {
        batch.update(
          database.categoriesTable,
          cat.toCompanion(),
          where: (c) => c.id.equals(cat.id!),
        );
      }
    });
  }
}
