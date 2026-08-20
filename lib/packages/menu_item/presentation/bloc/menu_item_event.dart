part of 'menu_item_bloc.dart';

sealed class MenuItemEvent extends Equatable {
  const MenuItemEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuItems extends MenuItemEvent {
  final bool isSilent;
  const LoadMenuItems({this.isSilent = false});

  @override
  List<Object?> get props => [isSilent];
}

class LoadMenuItemsByCategory extends MenuItemEvent {
  final int categoryId;
  const LoadMenuItemsByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class LoadMenuItemsBySubcategory extends MenuItemEvent {
  final int subcategoryId;
  const LoadMenuItemsBySubcategory(this.subcategoryId);

  @override
  List<Object?> get props => [subcategoryId];
}

class AddMenuItem extends MenuItemEvent {
  final MenuItem item;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const AddMenuItem(this.item, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [item];
}

class UpdateMenuItem extends MenuItemEvent {
  final MenuItem item;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const UpdateMenuItem(this.item, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [item];
}

class DeleteMenuItem extends MenuItemEvent {
  final int id;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const DeleteMenuItem(this.id, {this.onSuccess, this.onError});

  @override
  List<Object?> get props => [id];
}
