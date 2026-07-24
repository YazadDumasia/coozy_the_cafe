import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/menu_category.dart';
import '../../../domain/usecases/menu_category_usecases.dart';
import '../../../../menu_subcategory/domain/entities/menu_subcategory.dart';
import '../../../../menu_subcategory/domain/usecases/menu_subcategory_usecases.dart';

part 'edit_menu_category_event.dart';
part 'edit_menu_category_state.dart';

class EditMenuCategoryBloc extends Bloc<EditMenuCategoryEvent, EditMenuCategoryState> {
  final UpdateMenuCategoryUseCase updateMenuCategoryUseCase;
  final GetMenuSubcategoriesByCategoryUseCase getMenuSubcategoriesByCategoryUseCase;
  final AddMenuSubcategoryUseCase addMenuSubcategoryUseCase;
  final DeleteMenuSubcategoryUseCase deleteMenuSubcategoryUseCase;

  MenuCategory? initialCategory;
  List<MenuSubcategory>? initialSubCategories = <MenuSubcategory>[];
  List<TextEditingController>? listController = <TextEditingController>[];

  EditMenuCategoryBloc({
    required this.updateMenuCategoryUseCase,
    required this.getMenuSubcategoriesByCategoryUseCase,
    required this.addMenuSubcategoryUseCase,
    required this.deleteMenuSubcategoryUseCase,
  }) : super(EditMenuCategoryInitial()) {
    on<LoadEditMenuCategoryDataEvent>(_handleInitialLoadingData);
    on<OnAddNewSubCategoryEditMenuCategoryEvent>(_handleOnAddNewSubCategoryData);
    on<DeleteSubCategoryEditMenuEvent>(_handleDeleteSubCategoryData);
    on<SubmitSubCategoryEditMenuEvent>(_handleSubmitSubCategoryData);
  }

  Future<void> _handleInitialLoadingData(
    LoadEditMenuCategoryDataEvent event,
    Emitter<EditMenuCategoryState> emit,
  ) async {
    initialCategory = event.category;
    initialSubCategories = <MenuSubcategory>[];
    listController = <TextEditingController>[];
    emit(EditMenuCategoryLoadingState());

    try {
      initialSubCategories = await getMenuSubcategoriesByCategoryUseCase(event.category?.id ?? 0);
    } catch (e) {
      emit(EditMenuCategoryErrorState(e.toString()));
      return;
    }

    listController = <TextEditingController>[];
    if (initialSubCategories != null && initialSubCategories!.isNotEmpty) {
      for (int i = 0; i < initialSubCategories!.length; i++) {
        final subCategory = initialSubCategories![i];
        listController!.add(TextEditingController(text: subCategory.name));
      }
    }

    emit(EditMenuCategoryLoadedState(
      initialCategory: initialCategory,
      initialSubCategories: initialSubCategories,
      listController: listController,
    ));
  }

  Future<void> _handleOnAddNewSubCategoryData(
    OnAddNewSubCategoryEditMenuCategoryEvent event,
    Emitter<EditMenuCategoryState> emit,
  ) async {
    listController!.add(TextEditingController());
    emit(EditMenuCategoryLoadedState(
      initialCategory: initialCategory,
      initialSubCategories: initialSubCategories,
      listController: listController,
    ));
  }

  Future<void> _handleDeleteSubCategoryData(
    DeleteSubCategoryEditMenuEvent event,
    Emitter<EditMenuCategoryState> emit,
  ) async {
    listController![event.index].clear();
    listController![event.index].dispose();
    listController!.removeAt(event.index);

    emit(EditMenuCategoryLoadedState(
      initialCategory: initialCategory,
      initialSubCategories: initialSubCategories,
      listController: listController,
    ));
  }

  Future<void> _handleSubmitSubCategoryData(
    SubmitSubCategoryEditMenuEvent event,
    Emitter<EditMenuCategoryState> emit,
  ) async {
    final categoryName = event.categoryName;
    final list = listController!.map((controller) => controller.text).toList();

    final category = initialCategory!.copyWith(name: categoryName);

    try {
      await updateMenuCategoryUseCase(category);
    } catch (e) {
      event.onError?.call('crud_error_update');
      return;
    }

    try {
      // Manual deletion of old subcategories since repository doesn't have deleteAll
      if (initialSubCategories != null) {
        for (final sub in initialSubCategories!) {
          await deleteMenuSubcategoryUseCase(sub.id!);
        }
      }

      // Re-insert
      if (list.isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          if (list[i].trim().isNotEmpty) {
             final newSub = MenuSubcategory(
                hashId: const Uuid().v4(),
                categoryId: initialCategory!.id!,
                name: list[i].trim(),
                isActive: true,
                createdDate: DateTime.now().toIso8601String(),
                position: i,
             );
             await addMenuSubcategoryUseCase(newSub);
          }
        }
      }
    } catch (e) {
      event.onError?.call('crud_error_update');
      return;
    }

    event.onSuccess?.call();
  }

  @override
  Future<void> close() {
    for (var controller in listController ?? []) {
      controller.dispose();
    }
    return super.close();
  }
}
