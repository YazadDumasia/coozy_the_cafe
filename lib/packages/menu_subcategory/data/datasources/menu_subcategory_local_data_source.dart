import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
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

  @override
  Future<List<MenuSubcategoryModel>> getSubcategories() async {
    final query = database.select(database.subcategoriesTable)
      ..orderBy([
        (s) => OrderingTerm(expression: s.position, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return results.map((data) => MenuSubcategoryModel.fromData(data)).toList();
  }

  @override
  Future<List<MenuSubcategoryModel>> getSubcategoriesByCategoryId(
    int categoryId,
  ) async {
    final query = database.select(database.subcategoriesTable)
      ..where((s) => s.categoryId.equals(categoryId))
      ..orderBy([
        (s) => OrderingTerm(expression: s.position, mode: OrderingMode.asc),
      ]);
    final results = await query.get();
    return results.map((data) => MenuSubcategoryModel.fromData(data)).toList();
  }

  @override
  Future<int> insertSubcategory(MenuSubcategoryModel subcategory) async {
    return await database
        .into(database.subcategoriesTable)
        .insert(subcategory.toCompanion());
  }

  @override
  Future<bool> updateSubcategory(MenuSubcategoryModel subcategory) async {
    return await database
        .update(database.subcategoriesTable)
        .replace(subcategory.toCompanion());
  }

  @override
  Future<bool> deleteSubcategory(int id) async {
    final deleted = await (database.delete(
      database.subcategoriesTable,
    )..where((s) => s.id.equals(id))).go();
    return deleted > 0;
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
