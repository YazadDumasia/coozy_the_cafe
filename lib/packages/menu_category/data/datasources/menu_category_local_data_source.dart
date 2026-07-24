import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
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

  @override
  Future<List<MenuCategoryModel>> getCategories() async {
    final query = database.select(database.categoriesTable)
      ..orderBy([
        (c) => OrderingTerm(expression: c.position, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return results.map((data) => MenuCategoryModel.fromData(data)).toList();
  }

  @override
  Future<int> insertCategory(MenuCategoryModel category) async {
    return await database
        .into(database.categoriesTable)
        .insert(category.toCompanion());
  }

  @override
  Future<bool> updateCategory(MenuCategoryModel category) async {
    return await database
        .update(database.categoriesTable)
        .replace(category.toCompanion());
  }

  @override
  Future<bool> deleteCategory(int id) async {
    final deleted = await (database.delete(
      database.categoriesTable,
    )..where((c) => c.id.equals(id))).go();
    return deleted > 0;
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
