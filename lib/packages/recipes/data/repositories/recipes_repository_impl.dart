import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/repositories/recipes_repository.dart';
import '../datasources/recipes_local_data_source.dart';
import '../models/recipe_model.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipesLocalDataSource localDataSource;

  RecipesRepositoryImpl({required this.localDataSource});

  @override
  Future<void> initializeRecipes({
    void Function(int current, int total)? onProgress,
  }) async {
    await localDataSource.initializeRecipes(onProgress: onProgress);
  }

  @override
  Future<List<Recipe>> getRecipes() async {
    return await localDataSource.getRecipes();
  }

  @override
  Future<List<Recipe>> getBookmarkedRecipes() async {
    return await localDataSource.getBookmarkedRecipes();
  }

  @override
  Future<int> addRecipe(Recipe recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    return await localDataSource.insertRecipe(model);
  }

  @override
  Future<bool> updateRecipe(Recipe recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    return await localDataSource.updateRecipe(model);
  }

  @override
  Future<bool> deleteRecipe(int id) async {
    return await localDataSource.deleteRecipe(id);
  }
}
