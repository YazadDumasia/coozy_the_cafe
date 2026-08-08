part of 'menu_category_full_list_cubit.dart';

sealed class MenuCategoryFullListState {}

class MenuCategoryFullListInitialState extends MenuCategoryFullListState {}

class MenuCategoryFullListLoadingState extends MenuCategoryFullListState {}

class MenuCategoryFullListLoadedState extends MenuCategoryFullListState {
  final Map<String, dynamic>? data;
  final List<GlobalKey<State<StatefulWidget>>?>? expansionTileKeys;
  final List<ExpansibleController>? expandedTitleControllerList;

  MenuCategoryFullListLoadedState({
    this.data,
    this.expansionTileKeys,
    this.expandedTitleControllerList,
  });
}

class MenuCategoryFullListErrorState extends MenuCategoryFullListState {
  final String message;

  MenuCategoryFullListErrorState(this.message);
}
