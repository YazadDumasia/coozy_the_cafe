import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/menu_category.dart';
import '../../../domain/usecases/menu_category_usecases.dart';
import '../../../../menu_subcategory/domain/entities/menu_subcategory.dart';
import '../../../../menu_subcategory/domain/usecases/menu_subcategory_usecases.dart';

part 'menu_category_full_list_state.dart';

class MenuCategoryFullListCubit extends Cubit<MenuCategoryFullListState> {
  final GetMenuCategoriesUseCase getCategoriesUseCase;
  final GetMenuSubcategoriesUseCase getSubcategoriesUseCase;
  final UpdateMenuCategoryUseCase updateCategoryUseCase;
  final DeleteMenuCategoryUseCase deleteCategoryUseCase;
  final DeleteMenuSubcategoryUseCase deleteSubcategoryUseCase;
  final UpdateMenuSubcategoryUseCase updateSubcategoryUseCase;

  MenuCategoryFullListCubit({
    required this.getCategoriesUseCase,
    required this.getSubcategoriesUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.deleteSubcategoryUseCase,
    required this.updateSubcategoryUseCase,
  }) : super(MenuCategoryFullListInitialState());

  List<MenuCategory>? categoryList;
  List<MenuSubcategory>? subCategoryList;
  List<GlobalKey<State<StatefulWidget>>?>? expansionTileKeys;
  List<ExpansibleController>? expandedTitleControllerList;

  Future<void> loadData({
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      emit(MenuCategoryFullListLoadingState());
      final data = await fetchDataFromApi();

      if (data == null || data.isEmpty) {
        expansionTileKeys = [];
        expandedTitleControllerList = [];
        emit(
          MenuCategoryFullListLoadedState(
            data: null,
            expansionTileKeys: null,
            expandedTitleControllerList: [],
          ),
        );
      } else {
        expansionTileKeys = List.generate(
          data['categories'].length,
          (index) => GlobalKey(),
        );

        expandedTitleControllerList = List.generate(
          data['categories'].length,
          (index) => ExpansibleController(),
        );

        emit(
          MenuCategoryFullListLoadedState(
            data: data,
            expansionTileKeys: expansionTileKeys,
            expandedTitleControllerList: expandedTitleControllerList,
          ),
        );
      }
      onSuccess?.call();
    } catch (e) {
      onError?.call('An error occurred: $e');
      emit(MenuCategoryFullListErrorState('An error occurred: $e'));
    }
  }

  Future<void> deletecategory({
    int? categoryId,
    MenuCategory? category,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      if (categoryId != null) {
        // Delete associated subcategories first since we don't know if backend cascades
        final subcategories = await getSubcategoriesUseCase();
        final associated = subcategories
            .where((sub) => sub.categoryId == categoryId)
            .toList();
        for (var sub in associated) {
          await deleteSubcategoryUseCase(sub.id!);
        }
        await deleteCategoryUseCase(categoryId);
      }

      onSuccess?.call();
      await loadData();
    } catch (e) {
      onError?.call('crud_error_delete');
      emit(MenuCategoryFullListErrorState('An error occurred: $e'));
    }
  }

  Future<Map<String, dynamic>?> fetchDataFromApi() async {
    try {
      categoryList = await getCategoriesUseCase();
      subCategoryList = await getSubcategoriesUseCase();

      final result = <String, List<Map<String, Object?>>>{
        'categories':
            categoryList?.map((category) {
              final subCategories =
                  subCategoryList
                      ?.where((sub) => sub.categoryId == category.id)
                      .map(
                        (sub) => {
                          'id': sub.id,
                          'hashId': sub.hashId,
                          'categoryId': sub.categoryId,
                          'name': sub.name,
                          'isActive': sub.isActive ?? false,
                          'position': sub.position,
                          'createdDate': sub.createdDate,
                        },
                      )
                      .toList() ??
                  [];
              return <String, Object?>{
                'id': category.id,
                'hashId': category.hashId,
                'name': category.name,
                'isActive': category.isActive ?? false,
                'createdDate': category.createdDate,
                'position': category.position,
                'subCategories': subCategories,
              };
            }).toList() ??
            [],
      };

      return result;
    } catch (e) {
      return null;
    }
  }

  Future<void> handleIsEnableCategory(
    BuildContext context,
    MenuCategory category,
    bool isEnable, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final updated = category.copyWith(isActive: isEnable);
      await updateCategoryUseCase(updated);

      // Patch only this category in the existing state — no full reload
      if (state is MenuCategoryFullListLoadedState) {
        final current = state as MenuCategoryFullListLoadedState;
        final categories = current.data?['categories'] as List?;
        if (categories != null) {
          final updatedCategories = categories.map((item) {
            final c = Map<String, dynamic>.from(item as Map);
            if (c['id'] == category.id) c['isActive'] = isEnable;
            return c;
          }).toList();
          emit(
            MenuCategoryFullListLoadedState(
              data: {...current.data!, 'categories': updatedCategories},
              expansionTileKeys: expansionTileKeys,
              expandedTitleControllerList: expandedTitleControllerList,
            ),
          );
        }
      }

      onSuccess?.call();
    } catch (error) {
      onError?.call(error.toString());
    }
  }

  Future<void> handleIsEnableSubCategory(
    BuildContext context,
    MenuSubcategory subCategory,
    bool isEnable, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final updated = subCategory.copyWith(isActive: isEnable);
      await updateSubcategoryUseCase(updated);

      // Patch only this subcategory in the existing state — no full reload
      if (state is MenuCategoryFullListLoadedState) {
        final current = state as MenuCategoryFullListLoadedState;
        final categories = current.data?['categories'] as List?;
        if (categories != null) {
          final updatedCategories = categories.map((catItem) {
            final cat = Map<String, dynamic>.from(catItem as Map);
            final subs = cat['subCategories'] as List?;
            if (subs != null) {
              cat['subCategories'] = subs.map((subItem) {
                final s = Map<String, dynamic>.from(subItem as Map);
                if (s['id'] == subCategory.id) s['isActive'] = isEnable;
                return s;
              }).toList();
            }
            return cat;
          }).toList();
          emit(
            MenuCategoryFullListLoadedState(
              data: {...current.data!, 'categories': updatedCategories},
              expansionTileKeys: expansionTileKeys,
              expandedTitleControllerList: expandedTitleControllerList,
            ),
          );
        }
      }

      onSuccess?.call();
    } catch (error) {
      onError?.call(error.toString());
    }
  }

  Future<void> moveCategoryUp(
    int index, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    if (categoryList == null || index <= 0 || index >= categoryList!.length) {
      return;
    }
    try {
      final currentCategory = categoryList![index];
      final previousCategory = categoryList![index - 1];

      final currentPos = currentCategory.position ?? index;
      final previousPos = previousCategory.position ?? (index - 1);

      final updatedCurrent = currentCategory.copyWith(position: previousPos);
      final updatedPrevious = previousCategory.copyWith(position: currentPos);

      await updateCategoryUseCase(updatedCurrent);
      await updateCategoryUseCase(updatedPrevious);

      // Re-fetch sorted categories from DB without emitting LoadingState
      categoryList = await getCategoriesUseCase();
      subCategoryList = await getSubcategoriesUseCase();

      final updatedData = await _buildDataFromLists();

      emit(
        MenuCategoryFullListLoadedState(
          data: updatedData,
          expansionTileKeys: expansionTileKeys,
          expandedTitleControllerList: expandedTitleControllerList,
        ),
      );

      onSuccess?.call();
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<void> moveCategoryDown(
    int index, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    if (categoryList == null ||
        index < 0 ||
        index >= (categoryList!.length - 1)) {
      return;
    }
    try {
      final currentCategory = categoryList![index];
      final nextCategory = categoryList![index + 1];

      final currentPos = currentCategory.position ?? index;
      final nextPos = nextCategory.position ?? (index + 1);

      final updatedCurrent = currentCategory.copyWith(position: nextPos);
      final updatedNext = nextCategory.copyWith(position: currentPos);

      await updateCategoryUseCase(updatedCurrent);
      await updateCategoryUseCase(updatedNext);

      // Re-fetch sorted categories from DB without emitting LoadingState
      categoryList = await getCategoriesUseCase();
      subCategoryList = await getSubcategoriesUseCase();

      final updatedData = await _buildDataFromLists();

      emit(
        MenuCategoryFullListLoadedState(
          data: updatedData,
          expansionTileKeys: expansionTileKeys,
          expandedTitleControllerList: expandedTitleControllerList,
        ),
      );

      onSuccess?.call();
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  Future<Map<String, dynamic>?> _buildDataFromLists() async {
    final result = <String, List<Map<String, Object?>>>{
      'categories':
          categoryList?.map((category) {
            final subCategories =
                subCategoryList
                    ?.where((sub) => sub.categoryId == category.id)
                    .map(
                      (sub) => {
                        'id': sub.id,
                        'hashId': sub.hashId,
                        'categoryId': sub.categoryId,
                        'name': sub.name,
                        'isActive': sub.isActive ?? false,
                        'position': sub.position,
                        'createdDate': sub.createdDate,
                      },
                    )
                    .toList() ??
                [];
            return <String, Object?>{
              'id': category.id,
              'hashId': category.hashId,
              'name': category.name,
              'isActive': category.isActive ?? false,
              'createdDate': category.createdDate,
              'position': category.position,
              'subCategories': subCategories,
            };
          }).toList() ??
          [],
    };
    return result;
  }
}
