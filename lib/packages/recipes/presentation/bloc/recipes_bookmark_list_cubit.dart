import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/usecases/recipes_usecases.dart';

part 'recipes_bookmark_list_state.dart';

class RecipesBookmarkListCubit extends Cubit<RecipesBookmarkListState> {
  final GetBookmarkedRecipesUseCase getBookmarkedRecipesUseCase;
  final UpdateRecipeUseCase updateRecipeUseCase;
  final DeleteRecipeUseCase deleteRecipeUseCase;

  RecipesBookmarkListCubit({
    required this.getBookmarkedRecipesUseCase,
    required this.updateRecipeUseCase,
    required this.deleteRecipeUseCase,
  }) : super(RecipesBookmarkListInitialState());

  final BehaviorSubject<RecipesBookmarkListState> _stateSubject = BehaviorSubject();
  Stream<RecipesBookmarkListState> get stateStream => _stateSubject.stream;

  List<Recipe>? list;

  Future<void> loadData() async {
    try {
      emit(RecipesBookmarkListLoadingState());
      final List<Recipe> result = await getBookmarkedRecipesUseCase();
      list = result;
      emit(RecipesBookmarkListLoadedState(data: result));
    } catch (e) {
      emit(RecipesBookmarkListErrorState(e.toString()));
    }
  }

  Future<void> updateRecipe(Recipe updatedRecipe) async {
    try {
      emit(RecipesBookmarkListLoadingState());
      await updateRecipeUseCase(updatedRecipe);
      final List<Recipe> result = await getBookmarkedRecipesUseCase();
      list = result;
      emit(RecipesBookmarkListLoadedState(data: result));
    } catch (e) {
      emit(RecipesBookmarkListErrorState(e.toString()));
    }
  }

  Future<void> deleteRecipe(int recipeId) async {
    try {
      emit(RecipesBookmarkListLoadingState());
      final success = await deleteRecipeUseCase(recipeId);
      if (success) {
        list?.removeWhere((recipe) => recipe.recipeId == recipeId);
        emit(RecipesBookmarkListLoadedState(data: list));
      } else {
        emit(const RecipesBookmarkListErrorState("Failed to delete recipe."));
      }
    } catch (e) {
      emit(RecipesBookmarkListErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _stateSubject.close();
    return super.close();
  }
}
