import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/menu_category.dart';
import '../../../domain/usecases/menu_category_usecases.dart';
import '../../../../menu_subcategory/domain/entities/menu_subcategory.dart';
import '../../../../menu_subcategory/domain/usecases/menu_subcategory_usecases.dart';

part 'add_menu_category_state.dart';

class AddMenuCategoryCubit extends Cubit<AddMenuCategoryState> {
  final AddMenuCategoryUseCase addMenuCategoryUseCase;
  final AddMenuSubcategoryUseCase addMenuSubcategoryUseCase;

  AddMenuCategoryCubit({
    required this.addMenuCategoryUseCase,
    required this.addMenuSubcategoryUseCase,
  }) : super(AddMenuCategoryInitial());

  FocusNode menuCategoryNameFocusNode = FocusNode();
  TextEditingController menuCategoryNameController = TextEditingController(
    text: '',
  );

  final BehaviorSubject<List<String>?> _subCategoryListController =
      BehaviorSubject<List<String>>.seeded(<String>[]);

  Stream<List<String>?> get subCategoryListStream =>
      _subCategoryListController.stream;

  void addSubCategory(String subCategory) {
    final List<String> currentList =
        _subCategoryListController.value ?? <String>[];
    currentList.add(subCategory);
    _subCategoryListController.add(currentList);

    emit(
      AddMenuCategoryUpdated(
        categoryName: menuCategoryNameController.text,
        subCategoryList: currentList,
      ),
    );
  }

  void resetData() {
    menuCategoryNameController = TextEditingController(text: '');
    menuCategoryNameFocusNode = FocusNode();
    final List<String> currentList = <String>[];
    _subCategoryListController.add(currentList);

    emit(
      AddMenuCategoryUpdated(
        categoryName: menuCategoryNameController.text,
        subCategoryList: currentList,
      ),
    );
  }

  void onChangeSubCategory(String subCategory, int index) {
    final List<String> currentList =
        _subCategoryListController.value ?? <String>[];
    currentList[index] = subCategory;
    _subCategoryListController.add(currentList);

    emit(
      AddMenuCategoryUpdated(
        categoryName: menuCategoryNameController.text,
        subCategoryList: currentList,
      ),
    );
  }

  void removeSubCategory(int index) {
    final List<String> currentList =
        _subCategoryListController.value ?? <String>[];
    currentList.removeAt(index);
    _subCategoryListController.add(currentList);

    emit(
      AddMenuCategoryUpdated(
        categoryName: menuCategoryNameController.text,
        subCategoryList: currentList,
      ),
    );
  }

  Future saveCategory({
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final newCategory = MenuCategory(
        hashId: const Uuid().v4(),
        name: menuCategoryNameController.text,
        isActive: true,
        createdDate: DateTime.now().toIso8601String(),
        position: 0,
      );

      final categoryId = await addMenuCategoryUseCase(newCategory);

      if (categoryId > 0) {
        final List<String> subCategoryList =
            _subCategoryListController.value ?? <String>[];
        bool errorOccurred = false;

        for (int i = 0; i < subCategoryList.length; i++) {
          if (subCategoryList[i].isNotEmpty) {
            final subCategory = MenuSubcategory(
              hashId: const Uuid().v4(),
              categoryId: categoryId,
              name: subCategoryList[i],
              isActive: true,
              createdDate: DateTime.now().toIso8601String(),
              position: i,
            );

            final subId = await addMenuSubcategoryUseCase(subCategory);
            if (subId <= 0) {
              errorOccurred = true;
              break;
            }
          }
        }

        if (errorOccurred) {
          onError?.call('crud_error_add');
        } else {
          onSuccess?.call();
        }
      } else {
        onError?.call('crud_error_add');
      }
    } catch (e) {
      onError?.call('crud_error_add');
    }
  }

  @override
  Future<void> close() {
    menuCategoryNameController.dispose();
    _subCategoryListController.close();
    return super.close();
  }
}
