import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/domain/usecases/menu_category_usecases.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/usecases/menu_subcategory_usecases.dart';

part 'add_new_menu_subcategory_state.dart';

class AddNewMenuSubcategoryCubit extends Cubit<AddNewMenuSubcategoryState> {
  final AddMenuSubcategoryUseCase addMenuSubcategoryUseCase;
  final GetMenuSubcategoriesByCategoryUseCase getSubcategoriesByCategoryUseCase;
  final AddMenuCategoryUseCase addMenuCategoryUseCase;

  AddNewMenuSubcategoryCubit({
    required this.addMenuSubcategoryUseCase,
    required this.getSubcategoriesByCategoryUseCase,
    required this.addMenuCategoryUseCase,
  }) : super(AddNewMenuSubcategoryInitial());

  MenuCategory? selectedCategory;
  bool isCreatingNewCategory = false;
  TextEditingController newCategoryNameController = TextEditingController();
  FocusNode newCategoryNameFocusNode = FocusNode();

  final BehaviorSubject<List<String>> _subCategoryListController =
      BehaviorSubject<List<String>>.seeded(<String>[]);

  Stream<List<String>> get subCategoryListStream =>
      _subCategoryListController.stream;

  void toggleCreatingNewCategory(bool value) {
    isCreatingNewCategory = value;
    if (isCreatingNewCategory) {
      selectedCategory = null;
    } else {
      newCategoryNameController.clear();
    }
    emit(
      AddNewMenuSubcategoryUpdated(
        selectedCategory: selectedCategory,
        isCreatingNewCategory: isCreatingNewCategory,
        subCategoryList: _subCategoryListController.value,
      ),
    );
  }

  void setSelectedCategory(MenuCategory? category) {
    selectedCategory = category;
    isCreatingNewCategory = false;
    newCategoryNameController.clear();
    emit(
      AddNewMenuSubcategoryUpdated(
        selectedCategory: selectedCategory,
        isCreatingNewCategory: isCreatingNewCategory,
        subCategoryList: _subCategoryListController.value,
      ),
    );
  }

  void addSubCategory(String subCategory) {
    final List<String> currentList = List<String>.from(
      _subCategoryListController.value,
    );
    currentList.add(subCategory);
    _subCategoryListController.add(currentList);

    emit(
      AddNewMenuSubcategoryUpdated(
        selectedCategory: selectedCategory,
        isCreatingNewCategory: isCreatingNewCategory,
        subCategoryList: currentList,
      ),
    );
  }

  void resetData() {
    selectedCategory = null;
    isCreatingNewCategory = false;
    newCategoryNameController.clear();
    final List<String> currentList = <String>[];
    _subCategoryListController.add(currentList);

    emit(
      AddNewMenuSubcategoryUpdated(
        selectedCategory: null,
        isCreatingNewCategory: false,
        subCategoryList: currentList,
      ),
    );
  }

  void onChangeSubCategory(String subCategory, int index) {
    final List<String> currentList = List<String>.from(
      _subCategoryListController.value,
    );
    if (index >= 0 && index < currentList.length) {
      currentList[index] = subCategory;
      _subCategoryListController.add(currentList);

      emit(
        AddNewMenuSubcategoryUpdated(
          selectedCategory: selectedCategory,
          isCreatingNewCategory: isCreatingNewCategory,
          subCategoryList: currentList,
        ),
      );
    }
  }

  void removeSubCategory(int index) {
    final List<String> currentList = List<String>.from(
      _subCategoryListController.value,
    );
    if (index >= 0 && index < currentList.length) {
      currentList.removeAt(index);
      _subCategoryListController.add(currentList);

      emit(
        AddNewMenuSubcategoryUpdated(
          selectedCategory: selectedCategory,
          isCreatingNewCategory: isCreatingNewCategory,
          subCategoryList: currentList,
        ),
      );
    }
  }

  Future<void> saveSubcategories({
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    int targetCategoryId;

    try {
      if (isCreatingNewCategory) {
        final categoryName = newCategoryNameController.text.trim();
        if (categoryName.isEmpty) {
          onError?.call('Category name is required.');
          return;
        }

        final newCategory = MenuCategory(
          hashId: const Uuid().v4(),
          name: categoryName,
          isActive: true,
          createdDate: DateTime.now().toIso8601String(),
          position: 0,
        );

        targetCategoryId = await addMenuCategoryUseCase(newCategory);
        if (targetCategoryId <= 0) {
          onError?.call('Failed to create new category.');
          return;
        }
      } else {
        if (selectedCategory == null || selectedCategory!.id == null) {
          onError?.call('Please select a valid category.');
          return;
        }
        targetCategoryId = selectedCategory!.id!;
      }

      final List<String> subCategoryList = _subCategoryListController.value;
      if (subCategoryList.isEmpty) {
        onError?.call('Please add at least one sub-category.');
        return;
      }

      bool errorOccurred = false;
      for (int i = 0; i < subCategoryList.length; i++) {
        final name = subCategoryList[i].trim();
        if (name.isNotEmpty) {
          final subCategory = MenuSubcategory(
            hashId: const Uuid().v4(),
            categoryId: targetCategoryId,
            name: name,
            isActive: true,
            createdDate: DateTime.now().toIso8601String(),
          );

          final result = await addMenuSubcategoryUseCase(subCategory);
          if (result <= 0) {
            errorOccurred = true;
          }
        }
      }

      if (errorOccurred) {
        onError?.call('Some subcategories failed to save.');
      } else {
        onSuccess?.call();
      }
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  @override
  Future<void> close() {
    _subCategoryListController.close();
    return super.close();
  }
}
