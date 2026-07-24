part of 'edit_menu_category_bloc.dart';

abstract class EditMenuCategoryState {}

class EditMenuCategoryInitial extends EditMenuCategoryState {}

class EditMenuCategoryLoadingState extends EditMenuCategoryState {}

class EditMenuCategoryLoadedState extends EditMenuCategoryState {
  final MenuCategory? initialCategory;
  final List<MenuSubcategory>? initialSubCategories;
  final List<TextEditingController>? listController;

  EditMenuCategoryLoadedState({
    this.initialCategory,
    this.initialSubCategories,
    this.listController,
  });
}

class EditMenuCategoryErrorState extends EditMenuCategoryState {
  final String? errorMessage;
  EditMenuCategoryErrorState(this.errorMessage);
}
