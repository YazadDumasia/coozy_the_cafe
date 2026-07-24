import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

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

  Future<void> loadData() async {
    try {
      emit(MenuCategoryFullListLoadingState());
      final data = await fetchDataFromApi();

      if (data == null || data.isEmpty) {
        expansionTileKeys = [];
        expandedTitleControllerList = [];
        emit(MenuCategoryFullListLoadedState(
          data: null,
          expansionTileKeys: null,
          expandedTitleControllerList: [],
        ));
      } else {
        expansionTileKeys = List.generate(
          data['categories'].length,
          (index) => GlobalKey(),
        );

        expandedTitleControllerList = List.generate(
          data['categories'].length,
          (index) => ExpansibleController(),
        );

        emit(MenuCategoryFullListLoadedState(
          data: data,
          expansionTileKeys: expansionTileKeys,
          expandedTitleControllerList: expandedTitleControllerList,
        ));
      }
    } catch (e) {
      emit(MenuCategoryFullListErrorState('An error occurred: $e'));
    }
  }

  Future<void> deletecategory({int? categoryId, MenuCategory? category, VoidCallback? onSuccess, void Function(String)? onError}) async {
    try {
      if (categoryId != null) {
         // Delete associated subcategories first since we don't know if backend cascades
         final subcategories = await getSubcategoriesUseCase();
         final associated = subcategories.where((sub) => sub.categoryId == categoryId).toList();
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
        'categories': categoryList?.map((category) {
              final subCategories = subCategoryList
                      ?.where((sub) => sub.categoryId == category.id)
                      .map((sub) => {
                        'id': sub.id,
                        'name': sub.name,
                        'isActive': (sub.isActive ?? false) ? 1 : 0,
                      })
                      .toList() ??
                  [];
              return <String, Object?>{
                'id': category.id,
                'name': category.name,
                'isActive': (category.isActive ?? false) ? 1 : 0,
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
    bool isEnable,
  ) async {
    try {
      final updated = category.copyWith(isActive: isEnable);
      await updateCategoryUseCase(updated);

      if (context.mounted) {
        shared.DialogUtils.showAutoDismissDialog(
          context: context,
          title: context.tr(
            shared.LocaleKeys.commonSuccess,
            track: shared.TrackConstants.commonTrack,
          ) ?? 'Success',
          descriptions: isEnable
              ? 'Your selected Category has been activated.'
              : 'Your selected Category has been deactivated.',
          titleIcon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 50,
          ),
        );
      }
      await loadData();
    } catch (error) {
      if (context.mounted) {
        shared.DialogUtils.showAutoDismissDialog(
          context: context,
          title: context.tr(
            shared.LocaleKeys.commonError,
            track: shared.TrackConstants.commonTrack,
          ) ?? 'Error',
          descriptions: context.tr(
            shared.LocaleKeys.commonErrorMsg,
            track: shared.TrackConstants.commonTrack,
          ) ?? 'Failed to update category status.',
          titleIcon: const Icon(
            Icons.error,
            color: Colors.red,
            size: 50,
          ),
        );
      }
    }
  }

  Future<void> handleIsEnableSubCategory(
    BuildContext context,
    MenuSubcategory subCategory,
    bool isEnable,
  ) async {
    try {
      final updated = subCategory.copyWith(isActive: isEnable);
      await updateSubcategoryUseCase(updated);

      if (context.mounted) {
        shared.DialogUtils.showAutoDismissDialog(
          context: context,
          title: context.tr(
            shared.LocaleKeys.commonSuccess,
            track: shared.TrackConstants.commonTrack,
          ) ?? 'Success',
          descriptions: isEnable
              ? 'Your selected sub-category has been activated.'
              : 'Your selected sub-category has been deactivated.',
          titleIcon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 50,
          ),
        );
      }
      await loadData();
    } catch (error) {
      if (context.mounted) {
        shared.DialogUtils.showAutoDismissDialog(
          context: context,
          title: context.tr(
            shared.LocaleKeys.commonError,
            track: shared.TrackConstants.commonTrack,
          ) ?? 'Error',
          descriptions: context.tr(
            shared.LocaleKeys.commonErrorMsg,
            track: shared.TrackConstants.commonTrack,
          ) ?? 'Failed to update sub-category status.',
          titleIcon: const Icon(
            Icons.error,
            color: Colors.red,
            size: 50,
          ),
        );
      }
    }
  }
  Future<void> moveCategoryUp(int index, BuildContext context) async {
    // Position reordering not yet implemented
  }

  Future<void> moveCategoryDown(int index, BuildContext context) async {
    // Position reordering not yet implemented
  }

}
