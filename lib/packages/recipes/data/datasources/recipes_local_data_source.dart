import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:flutter/services.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

abstract class RecipesLocalDataSource {
  Future<void> initializeRecipes({
    void Function(int current, int total)? onProgress,
  });
  Future<List<RecipeModel>> getRecipes();
  Future<List<RecipeModel>> getBookmarkedRecipes();
  Future<int> insertRecipe(RecipeModel recipe);
  Future<bool> updateRecipe(RecipeModel recipe);
  Future<bool> deleteRecipe(int id);

  /// Debug-only: resets the seeding flag and clears all recipe data so the
  /// app will re-seed from the JSON asset on the next launch.
  static Future<void> resetRecipeSeedingData(CoozyDatabase database) async {
    assert(() {
      return true;
    }(), 'resetRecipeSeedingData should only be called in debug mode');

    // 1. Clear seeding flag — setting it to true means "first time" again
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferencesKeys.recipeList.name, true);

    // 2. Clear DB tables
    await database.delete(database.recipesTable).go();

    PlatformUtils.debugLog(
      RecipesLocalDataSource,
      'Recipe seeding data reset. App will re-seed on next recipes load.',
    );
  }
}

class RecipesLocalDataSourceImpl implements RecipesLocalDataSource {
  final CoozyDatabase database;

  RecipesLocalDataSourceImpl({required this.database});

  static Future<List<RecipeModel>> _parseJsonInIsolate(
    String jsonString,
  ) async {
    return await Isolate.run(() {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<void> initializeRecipes({
    void Function(int current, int total)? onProgress,
  }) async {
    final bool isFirstTime = await Constants.isFirstTime(
      PreferencesKeys.recipeList.name,
    );
    if (!isFirstTime) {
      PlatformUtils.debugLog(
        RecipesLocalDataSource,
        "Recipes dataset already seeded.",
      );
      return;
    }

    try {
      PlatformUtils.debugLog(
        RecipesLocalDataSource,
        "Loading Recipes from JSON asset...",
      );
      final String jsonString = await rootBundle.loadString(
        Assets.data.recipesDataset,
      );
      final List<RecipeModel> recipes;
      if (kIsWeb) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        recipes = decoded
            .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        recipes = await _parseJsonInIsolate(jsonString);
      }
      PlatformUtils.debugLog(
        RecipesLocalDataSource,
        "Parsed ${recipes.length} recipes. Inserting into SQLite database in chunks...",
      );

      // Convert to companion objects
      final List<RecipesTableCompanion> companions = recipes
          .map((r) => r.toCompanion())
          .toList();

      // Batch insert into Drift table in chunks of 200.
      const int chunkSize = 200;
      for (int i = 0; i < companions.length; i += chunkSize) {
        final int end = (i + chunkSize < companions.length)
            ? i + chunkSize
            : companions.length;
        final chunk = companions.sublist(i, end);
        await database.recipesDao.insertRecipesChunked(chunk);
        if (onProgress != null) {
          onProgress(end, companions.length);
        }
        PlatformUtils.debugLog(
          RecipesLocalDataSource,
          'Inserted chunk ${i ~/ chunkSize + 1} '
          '(recipes ${i + 1}–${i + chunk.length} of ${companions.length}).',
        );
      }
      PlatformUtils.debugLog(
        RecipesLocalDataSource,
        'Recipes seeding complete — ${companions.length} recipes inserted.',
      );
    } catch (e) {
      PlatformUtils.debugLog(
        RecipesLocalDataSource,
        "Error during recipes initialization: $e",
      );
      // Reset the preference value so it can attempt again next time
      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.setBool(PreferencesKeys.recipeList.name, true);
      rethrow;
    }
  }

  @override
  Future<List<RecipeModel>> getRecipes() async {
    final results = await database.recipesDao.getRecipes();
    if (results == null) return [];
    return results.map((r) => RecipeModel.fromData(r)).toList();
  }

  @override
  Future<List<RecipeModel>> getBookmarkedRecipes() async {
    final results = await database.recipesDao.getBookmarkedRecipes();
    return results.map((r) => RecipeModel.fromData(r)).toList();
  }

  @override
  Future<int> insertRecipe(RecipeModel recipe) async {
    final companion = recipe.toCompanion();
    return await database.into(database.recipesTable).insert(companion);
  }

  @override
  Future<bool> updateRecipe(RecipeModel recipe) async {
    final companion = recipe.toCompanion();
    return await database.update(database.recipesTable).replace(companion);
  }

  @override
  Future<bool> deleteRecipe(int id) async {
    final count = await database.recipesDao.deleteRecipe(id: id);
    return count > 0;
  }
}
