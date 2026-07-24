import 'package:collection/collection.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/usecases/recipes_usecases.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';

part 'recipes_full_list_state.dart';

class RecipesFullListCubit extends Cubit<RecipesFullListState> {
  final InitializeRecipesUseCase initializeRecipesUseCase;
  final GetRecipesUseCase getRecipesUseCase;
  final UpdateRecipeUseCase updateRecipeUseCase;
  final DeleteRecipeUseCase deleteRecipeUseCase;

  RecipesFullListCubit({
    required this.initializeRecipesUseCase,
    required this.getRecipesUseCase,
    required this.updateRecipeUseCase,
    required this.deleteRecipeUseCase,
  }) : super(RecipesInitialState());

  final BehaviorSubject<RecipesFullListState> _stateSubject = BehaviorSubject();
  Stream<RecipesFullListState> get stateStream => _stateSubject.stream;

  List<int> itemsPerPageList = <int>[10, 20, 30, 40, 50, 100];
  List<Recipe>? recipeList = <Recipe>[];
  List<Recipe>? currentFilteredList = <Recipe>[];
  String currentSearchQuery = '';

  List<int?>? uniqueServings = <int?>[];
  List<FilterItemModel>? servingsFilterOptionsList = <FilterItemModel>[];

  // List<String>? uniqueIngredients = <String>[];
  // List<FilterItemModel>? ingredientFilterOptionsList = <FilterItemModel>[];

  List<String>? uniqueCuisine = <String>[];
  List<FilterItemModel>? cuisineFilterOptionsList = <FilterItemModel>[];

  List<String>? uniqueCourse = <String>[];
  List<FilterItemModel>? courseFilterOptionsList = <FilterItemModel>[];

  List<String?>? uniqueDiet = <String?>[];
  List<FilterItemModel>? dietFilterOptionsList = <FilterItemModel>[];

  List<int?>? uniqueCookingTime = <int?>[];
  List<FilterItemModel>? cookingTimeFilterOptionsList = <FilterItemModel>[];

  List<int?>? uniqueTotalCookingTime = <int?>[];
  List<FilterItemModel>? totalCookingTimeFilterOptionsList =
      <FilterItemModel>[];

  List<AppliedFilterModel>? appliedFilterList = <AppliedFilterModel>[];

  int? currentPage = 1;
  int? currentItemsPerPage = 10;

  Future<void> loadData() async {
    try {
      emit(RecipesLoadingState());

      uniqueServings = <int?>[];
      servingsFilterOptionsList = <FilterItemModel>[];
      uniqueCuisine = <String>[];
      cuisineFilterOptionsList = <FilterItemModel>[];
      uniqueCourse = <String>[];
      courseFilterOptionsList = <FilterItemModel>[];
      uniqueDiet = <String?>[];
      dietFilterOptionsList = <FilterItemModel>[];
      uniqueCookingTime = <int?>[];
      cookingTimeFilterOptionsList = <FilterItemModel>[];
      uniqueTotalCookingTime = <int?>[];
      totalCookingTimeFilterOptionsList = <FilterItemModel>[];
      // uniqueIngredients = <String>[];
      // ingredientFilterOptionsList = <FilterItemModel>[];

      // Step 1: Initialize/Seed Recipes if first time
      await initializeRecipesUseCase(
        onProgress: (current, total) {
          emit(RecipesLoadingState(
            progress: total > 0 ? (current / total) : 0,
            message: 'Loading recipes $current/$total...',
          ));
        },
      );

      // Step 2: Fetch raw Recipes
      final data = await getRecipesUseCase();
      recipeList = data;
      currentFilteredList = data;

      if (data.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        emit(
          RecipesLoadedState(
            list: const <Recipe>[],
            paginatedData: const <Recipe>[],
            currentPage: 1,
            itemsPerPage: itemsPerPageList.first,
            totalElements: 0,
            totalPages: 0,
            startIndex: 0,
            endIndex: 0,
            appliedFilterList: appliedFilterList,
            isInternalLoading: false,
            itemsPerPageList: itemsPerPageList,
          ),
        );
      } else {
        // Build filters options
        for (Recipe recipe in data) {
          if (!uniqueServings!.contains(recipe.recipeServings)) {
            uniqueServings!.add(recipe.recipeServings);
          }
          if (recipe.recipeCuisine != null &&
              recipe.recipeCuisine!.isNotEmpty &&
              !uniqueCuisine!.contains(recipe.recipeCuisine)) {
            uniqueCuisine!.add(recipe.recipeCuisine!);
          }
          if (recipe.recipeCourse != null &&
              recipe.recipeCourse!.isNotEmpty &&
              !uniqueCourse!.contains(recipe.recipeCourse)) {
            uniqueCourse!.add(recipe.recipeCourse!);
          }
          if (recipe.recipeDiet != null &&
              recipe.recipeDiet!.isNotEmpty &&
              !uniqueDiet!.contains(recipe.recipeDiet)) {
            uniqueDiet!.add(recipe.recipeDiet!);
          }
          if (recipe.recipeCookingTimeInMins != null &&
              !uniqueCookingTime!.contains(recipe.recipeCookingTimeInMins)) {
            uniqueCookingTime!.add(recipe.recipeCookingTimeInMins);
          }
          if (recipe.recipeTotalTimeInMins != null &&
              !uniqueTotalCookingTime!.contains(recipe.recipeTotalTimeInMins)) {
            uniqueTotalCookingTime!.add(recipe.recipeTotalTimeInMins);
          }
        }

        // // Build ingredient filter options directly from recipeTranslatedIngredientList
        // // (no DB index needed — uses the pre-cleaned list stored on each recipe)
        // for (final recipe in data) {
        //   final raw = recipe.recipeTranslatedIngredientList;
        //   if (raw == null || raw.isEmpty) continue;
        //   for (final ing
        //       in raw
        //           .split(',')
        //           .map((e) => e.trim())
        //           .where((e) => e.isNotEmpty)) {
        //     if (!uniqueIngredients!.contains(ing)) {
        //       uniqueIngredients!.add(ing);
        //     }
        //   }
        // }
        // uniqueIngredients!.sort((a, b) => a.compareTo(b));
        // for (final ing in uniqueIngredients!) {
        //   ingredientFilterOptionsList!.add(
        //     FilterItemModel(filterTitle: ing, filterKey: ing),
        //   );
        // }

        // Sort unique values
        mergeSort(
          uniqueServings!,
          compare: (a, b) => (a ?? 0).compareTo(b ?? 0),
        );
        uniqueCuisine!.sort((a, b) => a.compareTo(b));
        uniqueCourse!.sort((a, b) => a.compareTo(b));
        uniqueDiet!.sort((a, b) => (a ?? '').compareTo(b ?? ''));
        uniqueCookingTime!.sort((a, b) => (a ?? 0).compareTo(b ?? 0));
        uniqueTotalCookingTime!.sort((a, b) => (a ?? 0).compareTo(b ?? 0));

        // Create filter options lists
        for (var serving in uniqueServings!) {
          if (serving != null) {
            servingsFilterOptionsList!.add(
              FilterItemModel(
                filterTitle: serving.toString(),
                filterKey: serving,
              ),
            );
          }
        }
        for (var cuisine in uniqueCuisine!) {
          cuisineFilterOptionsList!.add(
            FilterItemModel(filterTitle: cuisine, filterKey: cuisine),
          );
        }
        for (var course in uniqueCourse!) {
          courseFilterOptionsList!.add(
            FilterItemModel(filterTitle: course, filterKey: course),
          );
        }
        for (var diet in uniqueDiet!) {
          if (diet != null) {
            dietFilterOptionsList!.add(
              FilterItemModel(filterTitle: diet, filterKey: diet),
            );
          }
        }
        for (var time in uniqueCookingTime!) {
          if (time != null) {
            cookingTimeFilterOptionsList!.add(
              FilterItemModel(filterTitle: '$time mins', filterKey: time),
            );
          }
        }
        for (var time in uniqueTotalCookingTime!) {
          if (time != null) {
            totalCookingTimeFilterOptionsList!.add(
              FilterItemModel(filterTitle: '$time mins', filterKey: time),
            );
          }
        }

        currentPage = 1;
        currentItemsPerPage = itemsPerPageList.first;
        _updatePaginatedState(data);
      }
    } catch (e) {
      PlatformUtils.debugLog(RecipesFullListCubit, 'loadData:error:$e');
      emit(RecipesErrorState('An error occurred: $e'));
    }
  }

  void _updatePaginatedState(List<Recipe> filteredData) {
    final int totalElements = filteredData.length;
    final int itemsPerPage = currentItemsPerPage ?? itemsPerPageList.first;
    final int totalPages = (totalElements / itemsPerPage).ceil();

    int startIdx = ((currentPage ?? 1) - 1) * itemsPerPage;
    if (startIdx >= totalElements) {
      currentPage = 1;
      startIdx = 0;
    }

    int endIdx = startIdx + itemsPerPage;
    if (endIdx > totalElements) {
      endIdx = totalElements;
    }

    final List<Recipe> paginated = (totalElements == 0)
        ? <Recipe>[]
        : filteredData.sublist(startIdx, endIdx);

    emit(
      RecipesLoadedState(
        list: recipeList,
        paginatedData: paginated,
        startIndex: startIdx,
        endIndex: endIdx,
        currentPage: currentPage,
        isInternalLoading: false,
        itemsPerPage: itemsPerPage,
        totalElements: totalElements,
        totalPages: totalPages,
        appliedFilterList: appliedFilterList,
        itemsPerPageList: itemsPerPageList,
      ),
    );
  }

  Future<void> reloadWithCurrentState(BuildContext context) async {
    if (state is! RecipesLoadedState) {
      await loadData();
      return;
    }

    DialogUtils.showLoadingDialog(context);

    try {
      final data = await getRecipesUseCase();
      recipeList = data;

      // Reapply search & filter
      List<Recipe> filtered = data;
      if (currentSearchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (r) =>
                  (r.recipeOriginalName ?? '').toLowerCase().contains(
                    currentSearchQuery.toLowerCase(),
                  ) ||
                  (r.translatedRecipeName ?? '').toLowerCase().contains(
                    currentSearchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }

      if (appliedFilterList != null && appliedFilterList!.isNotEmpty) {
        filtered = await _applyFilters(appliedFilterList!, filtered);
      }
      currentFilteredList = filtered;

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }
      _updatePaginatedState(filtered);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }
      emit(RecipesErrorState(e.toString()));
    }
  }

  Future<void> updateBookmark({
    required Recipe model,
    required BuildContext context,
    required int currentIndex,
  }) async {
    final updated = model.copyWith(isBookmark: !(model.isBookmark ?? false));
    try {
      await updateRecipeUseCase(updated);

      // Update local cache
      recipeList = recipeList
          ?.map((r) => r.recipeId == model.recipeId ? updated : r)
          .toList();
      currentFilteredList = currentFilteredList
          ?.map((r) => r.recipeId == model.recipeId ? updated : r)
          .toList();

      if (currentFilteredList != null) {
        _updatePaginatedState(currentFilteredList!);
      }
    } catch (e) {
      PlatformUtils.debugLog(RecipesFullListCubit, 'updateBookmark:error:$e');
    }
  }

  Future<void> updatePageNumber(int page) async {
    currentPage = page;
    if (currentFilteredList != null) {
      _updatePaginatedState(currentFilteredList!);
    }
  }

  Future<void> updatePageItems({required int itemsPerPage}) async {
    currentItemsPerPage = itemsPerPage;
    currentPage = 1;
    if (currentFilteredList != null) {
      _updatePaginatedState(currentFilteredList!);
    }
  }

  Future<void> searchRecipes(String query) async {
    currentSearchQuery = query.trim();
    currentPage = 1;

    List<Recipe> filtered = recipeList ?? [];
    if (currentSearchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (r) =>
                (r.recipeOriginalName ?? '').toLowerCase().contains(
                  currentSearchQuery.toLowerCase(),
                ) ||
                (r.translatedRecipeName ?? '').toLowerCase().contains(
                  currentSearchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    if (appliedFilterList != null && appliedFilterList!.isNotEmpty) {
      filtered = await _applyFilters(appliedFilterList!, filtered);
    }

    currentFilteredList = filtered;
    _updatePaginatedState(filtered);
  }

  Future<void> applyFilter({required List<AppliedFilterModel>? fliter}) async {
    appliedFilterList = fliter ?? <AppliedFilterModel>[];
    currentPage = 1;
    emit(RecipesLoadingState());

    try {
      List<Recipe> filtered = recipeList ?? [];
      if (currentSearchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (r) =>
                  (r.recipeOriginalName ?? '').toLowerCase().contains(
                    currentSearchQuery.toLowerCase(),
                  ) ||
                  (r.translatedRecipeName ?? '').toLowerCase().contains(
                    currentSearchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }

      if (appliedFilterList != null && appliedFilterList!.isNotEmpty) {
        filtered = await _applyFilters(appliedFilterList!, filtered);
      }

      currentFilteredList = filtered;
      _updatePaginatedState(filtered);
    } catch (e) {
      PlatformUtils.debugLog(RecipesFullListCubit, 'applyFilter:error:$e');
      emit(RecipesErrorState('An error occurred applying filters: $e'));
    }
  }

  Future<List<Recipe>> _applyFilters(
    List<AppliedFilterModel> filters,
    List<Recipe> recipes,
  ) async {
    List<Recipe> filtered = recipes;

    for (AppliedFilterModel filter in filters) {
      if (filter.applied.isEmpty) continue;

      switch (filter.filterKey) {
        case 'servings':
          filtered = filtered
              .where(
                (r) => filter.applied.any(
                  (f) => r.recipeServings.toString() == f.filterTitle,
                ),
              )
              .toList();
          break;

        case 'cuisine':
          filtered = filtered
              .where(
                (r) =>
                    filter.applied.any((f) => r.recipeCuisine == f.filterTitle),
              )
              .toList();
          break;

        case 'course':
          filtered = filtered
              .where(
                (r) =>
                    filter.applied.any((f) => r.recipeCourse == f.filterTitle),
              )
              .toList();
          break;

        case 'diet':
          filtered = filtered
              .where(
                (r) => filter.applied.any((f) => r.recipeDiet == f.filterTitle),
              )
              .toList();
          break;

        case 'cooking_time':
          filtered = filtered
              .where(
                (r) => filter.applied.any(
                  (f) =>
                      (r.recipeCookingTimeInMins ?? 0) <=
                      (int.tryParse(f.filterTitle) ?? 0),
                ),
              )
              .toList();
          break;

        case 'total_cooking_time':
          filtered = filtered
              .where(
                (r) => filter.applied.any(
                  (f) =>
                      (r.recipeTotalTimeInMins ?? 0) <=
                      (int.tryParse(f.filterTitle) ?? 0),
                ),
              )
              .toList();
          break;

        // case 'ingredient':
        //   filtered = _filterRecipesByIngredient(filtered, filter.applied);
        //   break;
      }
    }

    return filtered.toSet().toList(); // Unique results
  }

  // /// Filters recipes in-memory by matching [appliedFilters] against the
  // /// [recipeTranslatedIngredientList] field on each recipe (OR logic —
  // /// a recipe is included if it contains ANY of the selected ingredients).
  // List<Recipe> _filterRecipesByIngredient(
  //   List<Recipe> recipes,
  //   List<FilterItemModel> appliedFilters,
  // ) {
  //   if (appliedFilters.isEmpty) return recipes;

  //   // Build a lowercase set of all selected ingredient keys for fast lookup
  //   final selectedIngredients = appliedFilters
  //       .map((f) => f.filterKey.toString().trim().toLowerCase())
  //       .toSet();

  //   return recipes.where((r) {
  //     final raw = r.recipeTranslatedIngredientList;
  //     if (raw == null || raw.isEmpty) return false;

  //     final recipeIngredients = raw
  //         .split(',')
  //         .map((e) => e.trim().toLowerCase())
  //         .toSet();

  //     // OR logic: recipe matches if it has ANY of the selected ingredients
  //     return recipeIngredients.any(selectedIngredients.contains);
  //   }).toList();
  // }

  @override
  Future<void> close() {
    _stateSubject.close();
    return super.close();
  }
}
