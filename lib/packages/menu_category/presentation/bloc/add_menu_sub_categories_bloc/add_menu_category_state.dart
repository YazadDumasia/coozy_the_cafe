part of 'add_menu_categories_cubit.dart';

sealed class AddMenuCategoryState {}

class AddMenuCategoryInitial extends AddMenuCategoryState {}

class AddMenuCategoryUpdated extends AddMenuCategoryState {
  final String categoryName;
  final List<String> subCategoryList;

  AddMenuCategoryUpdated({
    required this.categoryName,
    required this.subCategoryList,
  });
}
