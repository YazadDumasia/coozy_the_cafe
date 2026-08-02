import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [CategoriesTable, SubcategoriesTable])
class CategoriesDao extends DatabaseAccessor<CoozyDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  /// Add a category
  Future<int?> addCategory(CategoriesTableCompanion category) async {
    return transaction(() async {
      // Use a subquery to get the maximum sortOrderIndex
      final maxPositionExpr = categoriesTable.position.max();
      final query = selectOnly(categoriesTable)..addColumns([maxPositionExpr]);
      final maxRow = await query.getSingle();
      final int maxPosition = maxRow.read(maxPositionExpr) ?? -1;

      // Automatically generate position based on the last position
      final newCategory = category.copyWith(position: Value(maxPosition + 1));

      // Check if category exists
      final model = await getCategoryBasedOnName(name: category.name.value);
      if (model == null) {
        return await into(
          categoriesTable,
        ).insert(newCategory, mode: InsertMode.replace);
      }
      return null;
    });
  }

  /// Get all categories
  Future<List<Category>> getCategories() {
    final query = select(categoriesTable);
    query.orderBy([
      (t) => OrderingTerm(expression: t.position, mode: OrderingMode.asc),
    ]);
    return query.get();
  }

  /// Update a category
  Future<int?> updateCategory(int id, CategoriesTableCompanion category) async {
    final rows = await (update(
      categoriesTable,
    )..where((t) => t.id.equals(id))).write(category);
    return rows > 0 ? rows : null;
  }

  /// Get a category based on its name.
  Future<Category?> getCategoryBasedOnName({String? name}) async {
    if (name != null && name.isNotEmpty) {
      final query = select(categoriesTable)..where((t) => t.name.equals(name));
      query.orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
      ]);
      query.limit(1);
      return query.getSingleOrNull();
    } else {
      return null;
    }
  }

  /// Get a category based on its ID.
  Future<Category?> getCategoryBasedOnCategoryId({
    required int? categoryId,
  }) async {
    if (categoryId == null) {
      return null;
    } else {
      final query = select(categoriesTable)
        ..where((t) => t.id.equals(categoryId));
      query.limit(1);
      return query.getSingleOrNull();
    }
  }

  /// Delete a category
  Future<int?> deleteCategory(Category? model) async {
    if (model == null) return null;

    return transaction(() async {
      final int sortRecordIndexToDelete = model.position ?? 0;

      // Step 1: Delete the item from the database
      final int rowsAffected = await (delete(
        categoriesTable,
      )..where((t) => t.id.equals(model.id))).go();

      // Step 2: Update sortOrderIndex for items with a higher index in batches
      // We can use customUpdate to efficiently run the UPDATE query.
      await customUpdate(
        'UPDATE ${categoriesTable.actualTableName} SET position = position - 1 WHERE position > ?',
        variables: [Variable.withInt(sortRecordIndexToDelete)],
        updates: {categoriesTable},
      );

      return rowsAffected;
    });
  }

  // Subcategory CRUD operations

  ///Create a new subcategory with automatic position calculation at the end of the category
  Future<int> createSubcategory(SubcategoriesTableCompanion subcategory) async {
    return transaction(() async {
      final categoryId = subcategory.categoryId.value;
      int maxPosition = -1;
      if (categoryId != null) {
        final maxPositionExpr = subcategoriesTable.position.max();
        final query = selectOnly(subcategoriesTable)
          ..where(subcategoriesTable.categoryId.equals(categoryId))
          ..addColumns([maxPositionExpr]);
        final maxRow = await query.getSingle();
        maxPosition = maxRow.read(maxPositionExpr) ?? -1;
      }

      final newSubcategory = subcategory.copyWith(
        position: Value(maxPosition + 1),
      );

      return into(subcategoriesTable).insert(
        newSubcategory,
        mode: InsertMode.replace,
      );
    });
  }

  /// Get all subcategories
  Future<List<Subcategory>?> getSubcategories() async {
    final query = select(subcategoriesTable);
    query.orderBy([
      (t) => OrderingTerm(expression: t.position, mode: OrderingMode.asc),
    ]);
    final results = await query.get();
    return results.isNotEmpty ? results : null;
  }

  /// Get a subcategory based on its Category ID.
  Future<List<Subcategory>?> getSubcategoryBaseCategoryId(
    int categoryId,
  ) async {
    final query = select(subcategoriesTable)
      ..where((t) => t.categoryId.equals(categoryId));
    query.orderBy([
      (t) => OrderingTerm(expression: t.position, mode: OrderingMode.asc),
    ]);
    final results = await query.get();
    return results.isNotEmpty ? results : null;
  }

  /// Update a subcategory
  Future<int?> updateSubcategory(
    int id,
    SubcategoriesTableCompanion subcategory,
  ) async {
    final rows = await (update(
      subcategoriesTable,
    )..where((t) => t.id.equals(id))).write(subcategory);
    return rows > 0 ? rows : null;
  }

  /// Delete a subcategory
  Future<int?> deleteSubcategory(int id) async {
    try {
      final rows = await (delete(
        subcategoriesTable,
      )..where((t) => t.id.equals(id))).go();
      return rows > 0 ? rows : null;
    } catch (e) {
      return null;
    }
  }

  /// Delete all subcategories base on categoryId in batches
  Future<int?> deleteAllSubcategoryBasedOnCategoryId({int? categoryId}) async {
    if (categoryId == null) return null;

    try {
      return transaction(() async {
        final rows = await (delete(
          subcategoriesTable,
        )..where((t) => t.categoryId.equals(categoryId))).go();
        return rows > 0 ? rows : 0;
      });
    } catch (e) {
      return null;
    }
  }

  ///Insert a subcategories in batch with the specified ID from the database.
  Future<void> insertSubCategoriesForCategoryId({
    required int? categoryId,
    required List<SubcategoriesTableCompanion> subCategories,
  }) async {
    if (categoryId == null || subCategories.isEmpty) return;

    await batch((batch) {
      for (final subCategory in subCategories) {
        batch.insert(
          subcategoriesTable,
          subCategory.copyWith(categoryId: Value(categoryId)),
          mode: InsertMode.replace,
        );
      }
    });
  }
}
