part of 'add_new_menu_subcategory_cubit.dart';

sealed class AddNewMenuSubcategoryState {
  const AddNewMenuSubcategoryState();
}

final class AddNewMenuSubcategoryInitial extends AddNewMenuSubcategoryState {}

final class AddNewMenuSubcategoryUpdated extends AddNewMenuSubcategoryState {
  final MenuCategory? selectedCategory;
  final bool isCreatingNewCategory;
  final List<String> subCategoryList;

  const AddNewMenuSubcategoryUpdated({
    required this.selectedCategory,
    this.isCreatingNewCategory = false,
    required this.subCategoryList,
  });
}
