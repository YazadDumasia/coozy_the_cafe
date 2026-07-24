import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/menu_subcategory.dart';

sealed class MenuSubcategoryEvent extends Equatable {
  const MenuSubcategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuSubcategories extends MenuSubcategoryEvent {}

class LoadMenuSubcategoriesByCategory extends MenuSubcategoryEvent {
  final int categoryId;
  const LoadMenuSubcategoriesByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class AddMenuSubcategory extends MenuSubcategoryEvent {
  final MenuSubcategory subcategory;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const AddMenuSubcategory(
    this.subcategory, {
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [subcategory];
}

class UpdateMenuSubcategory extends MenuSubcategoryEvent {
  final MenuSubcategory subcategory;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const UpdateMenuSubcategory(
    this.subcategory, {
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [subcategory];
}

class DeleteMenuSubcategory extends MenuSubcategoryEvent {
  final int id;
  final VoidCallback? onSuccess;
  final void Function(String)? onError;

  const DeleteMenuSubcategory(
    this.id, {
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [id];
}

class ReorderMenuSubcategories extends MenuSubcategoryEvent {
  final int oldIndex;
  final int newIndex;
  const ReorderMenuSubcategories(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class ToggleSubcategoryReorderMode extends MenuSubcategoryEvent {}
