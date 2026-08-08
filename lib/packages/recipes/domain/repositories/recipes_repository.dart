import '../entities/recipe.dart';

abstract class RecipesRepository {
  Future<void> initializeRecipes({
    void Function(int current, int total)? onProgress,
  });
  Future<List<Recipe>> getRecipes();
  Future<List<Recipe>> getBookmarkedRecipes();
  Future<int> addRecipe(Recipe recipe);
  Future<bool> updateRecipe(Recipe recipe);
  Future<bool> deleteRecipe(int id);
}
