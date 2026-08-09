import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'recipes_dao.g.dart';

@DriftAccessor(tables: [RecipesTable])
class RecipesDao extends DatabaseAccessor<CoozyDatabase>
    with _$RecipesDaoMixin {
  RecipesDao(super.db);

  // ---------------------------------------------------------------------------
  // Constants & private helpers
  // ---------------------------------------------------------------------------

  static const int _defaultChunkSize = 100;

  /// Splits [list] into sub-lists of at most [size] elements.
  List<List<T>> _chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += size) {
      final end = (i + size < list.length) ? i + size : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  // ---------------------------------------------------------------------------
  // INSERT
  // ---------------------------------------------------------------------------

  Future<int> insertSingleRecipe(RecipesTableCompanion recipe) async {
    return await into(recipesTable).insert(recipe);
  }

  Future<bool> updateSingleRecipe(RecipesTableCompanion recipe) async {
    return await update(recipesTable).replace(recipe);
  }

  /// Inserts a list of recipes atomically.
  Future<void> insertRecipes(List<RecipesTableCompanion> recipes) async {
    await transaction(() async {
      for (final recipe in recipes) {
        await into(recipesTable).insert(recipe);
      }
    });
  }

  /// Inserts a large list of recipes in batches of [chunkSize] rows per
  /// transaction. Returns all auto-generated `recipeId` values in order.
  Future<List<int>> insertRecipesInChunks(
    List<RecipesTableCompanion> recipes, {
    int chunkSize = _defaultChunkSize,
  }) async {
    final allIds = <int>[];
    for (final chunk in _chunk(recipes, chunkSize)) {
      await transaction(() async {
        for (final recipe in chunk) {
          final recipeId = await into(recipesTable).insert(recipe);
          allIds.add(recipeId);
        }
      });
    }
    return allIds;
  }

  /// Alias for [insertRecipesInChunks]
  Future<void> insertRecipesChunked(
    List<RecipesTableCompanion> recipes, {
    int chunkSize = _defaultChunkSize,
  }) => insertRecipesInChunks(recipes, chunkSize: chunkSize);

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  /// Updates a list of recipes atomically.
  /// Each companion **must** include `recipeId`.
  Future<void> updateRecipes(List<RecipesTableCompanion> recipes) async {
    await transaction(() async {
      for (final recipe in recipes) {
        await (update(recipesTable)
              ..where((t) => t.recipeId.equals(recipe.recipeId.value)))
            .write(recipe);
      }
    });
  }

  /// Updates a large list of recipes in batches of [chunkSize].
  Future<void> updateRecipesInChunks(
    List<RecipesTableCompanion> recipes, {
    int chunkSize = _defaultChunkSize,
  }) async {
    for (final chunk in _chunk(recipes, chunkSize)) {
      await transaction(() async {
        for (final recipe in chunk) {
          await (update(recipesTable)
                ..where((t) => t.recipeId.equals(recipe.recipeId.value)))
              .write(recipe);
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  /// Deletes a **single** recipe by [id].
  /// Returns the number of rows deleted from [RecipesTable] (0 or 1).
  Future<int> deleteRecipe({required int id}) async {
    return await (delete(
      recipesTable,
    )..where((t) => t.recipeId.equals(id))).go();
  }

  Future<int> deleteAllRecipes() async {
    return await delete(recipesTable).go();
  }

  /// Deletes recipes by [recipeIds] in one transaction.
  Future<void> deleteRecipes(List<int> recipeIds) async {
    await transaction(() async {
      await (delete(
        recipesTable,
      )..where((t) => t.recipeId.isIn(recipeIds))).go();
    });
  }

  /// Deletes a large list of recipe ids in batches.
  Future<void> deleteRecipesInChunks(
    List<int> recipeIds, {
    int chunkSize = _defaultChunkSize,
  }) async {
    for (final chunk in _chunk(recipeIds, chunkSize)) {
      await deleteRecipes(chunk);
    }
  }

  // ---------------------------------------------------------------------------
  // READ — simple queries
  // ---------------------------------------------------------------------------

  /// Returns all [Recipe] rows.
  Future<List<Recipe>?> getRecipes() => select(recipesTable).get();

  /// Returns all bookmarked [Recipe] rows.
  Future<List<Recipe>> getBookmarkedRecipes() =>
      (select(recipesTable)..where((t) => t.isBookmark.equals(true))).get();

  // ---------------------------------------------------------------------------
  // READ — paginated
  // ---------------------------------------------------------------------------

  /// Returns one page of [Recipe] rows ([page] is 1-based).
  Future<RecipePage> getRecipesPaginated({
    int page = 1,
    int pageSize = 20,
  }) async {
    assert(page >= 1, 'page must be >= 1');
    assert(pageSize >= 1, 'pageSize must be >= 1');

    final offset = (page - 1) * pageSize;

    final countExpr = recipesTable.recipeId.count();
    final countQuery = selectOnly(recipesTable)..addColumns([countExpr]);
    final totalCount = await countQuery
        .map((row) => row.read(countExpr) ?? 0)
        .getSingle();

    final dataQuery = select(recipesTable)
      ..orderBy([(t) => OrderingTerm.asc(t.recipeId)])
      ..limit(pageSize, offset: offset);
    final rows = await dataQuery.get();

    return RecipePage(
      recipes: rows,
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Returns all [Recipe] rows fetched page-by-page internally.
  Future<List<Recipe>> getAllRecipes({int pageSize = _defaultChunkSize}) async {
    final all = <Recipe>[];
    var page = 1;
    while (true) {
      final result = await getRecipesPaginated(page: page, pageSize: pageSize);
      all.addAll(result.recipes);
      if (all.length >= result.totalCount) break;
      page++;
    }
    return all;
  }
}

// -----------------------------------------------------------------------------
// Pagination result models
// -----------------------------------------------------------------------------

/// Holds one page of [Recipe] rows together with pagination metadata.
class RecipePage {
  const RecipePage({
    required this.recipes,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<Recipe> recipes;
  final int totalCount;
  final int page;
  final int pageSize;

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNextPage => page < totalPages;

  @override
  String toString() =>
      'RecipePage(page: $page/$totalPages, rows: ${recipes.length}, total: $totalCount)';
}
