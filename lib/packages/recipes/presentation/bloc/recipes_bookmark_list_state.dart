part of 'recipes_bookmark_list_cubit.dart';

sealed class RecipesBookmarkListState extends Equatable {
  const RecipesBookmarkListState();

  @override
  List<Object?> get props => [];
}

class RecipesBookmarkListInitialState extends RecipesBookmarkListState {}

class RecipesBookmarkListLoadingState extends RecipesBookmarkListState {}

class RecipesBookmarkListLoadedState extends RecipesBookmarkListState {
  final List<Recipe>? data;

  const RecipesBookmarkListLoadedState({this.data});

  @override
  List<Object?> get props => [data];
}

class RecipesBookmarkListErrorState extends RecipesBookmarkListState {
  final String? errorMessage;
  const RecipesBookmarkListErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class RecipesBookmarkListNoInternetState extends RecipesBookmarkListState {}
