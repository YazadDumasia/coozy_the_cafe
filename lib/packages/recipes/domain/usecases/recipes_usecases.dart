import '../entities/recipe.dart';
import '../repositories/recipes_repository.dart';

class InitializeRecipesUseCase {
  final RecipesRepository repository;

  InitializeRecipesUseCase(this.repository);

  Future<void> call({void Function(int current, int total)? onProgress}) async {
    await repository.initializeRecipes(onProgress: onProgress);
  }
}

class GetRecipesUseCase {
  final RecipesRepository repository;

  GetRecipesUseCase(this.repository);

  Future<List<Recipe>> call() async {
    return await repository.getRecipes();
  }
}

class GetBookmarkedRecipesUseCase {
  final RecipesRepository repository;

  GetBookmarkedRecipesUseCase(this.repository);

  Future<List<Recipe>> call() async {
    return await repository.getBookmarkedRecipes();
  }
}

class AddRecipeUseCase {
  final RecipesRepository repository;

  AddRecipeUseCase(this.repository);

  Future<int> call(Recipe recipe) async {
    return await repository.addRecipe(recipe);
  }
}

class UpdateRecipeUseCase {
  final RecipesRepository repository;

  UpdateRecipeUseCase(this.repository);

  Future<bool> call(Recipe recipe) async {
    return await repository.updateRecipe(recipe);
  }
}

class DeleteRecipeUseCase {
  final RecipesRepository repository;

  DeleteRecipeUseCase(this.repository);

  Future<bool> call(int id) async {
    return await repository.deleteRecipe(id);
  }
}
