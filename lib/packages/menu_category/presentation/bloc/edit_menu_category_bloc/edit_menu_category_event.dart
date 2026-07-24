part of 'edit_menu_category_bloc.dart';

abstract class EditMenuCategoryEvent {}

class LoadEditMenuCategoryDataEvent extends EditMenuCategoryEvent {
  final MenuCategory? category;
  LoadEditMenuCategoryDataEvent({required this.category});
}

class UpdateEditMenuCategoryEvent extends EditMenuCategoryEvent {
  final String? value;
  UpdateEditMenuCategoryEvent({this.value});
}

class OnAddNewSubCategoryEditMenuCategoryEvent extends EditMenuCategoryEvent {}

class UpdateSubCategoryEditMenuCategoryEvent extends EditMenuCategoryEvent {
  final String? value;
  final int index;
  UpdateSubCategoryEditMenuCategoryEvent({this.value, required this.index});
}

class DeleteSubCategoryEditMenuEvent extends EditMenuCategoryEvent {
  final int index;
  DeleteSubCategoryEditMenuEvent({required this.index});
}

class SubmitSubCategoryEditMenuEvent extends EditMenuCategoryEvent {
  final String categoryName;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  SubmitSubCategoryEditMenuEvent({
    required this.categoryName,
    this.onSuccess,
    this.onError,
  });
}
