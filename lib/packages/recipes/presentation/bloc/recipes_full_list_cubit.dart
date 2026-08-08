import 'dart:isolate';
import 'package:collection/collection.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' hide mergeSort;
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

  List<String>? uniqueIngredients = <String>[];
  List<FilterItemModel>? ingredientFilterOptionsList = <FilterItemModel>[];

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
      uniqueIngredients = <String>[];
      ingredientFilterOptionsList = <FilterItemModel>[];

      // Step 1: Initialize/Seed Recipes if first time
      await initializeRecipesUseCase(
        onProgress: (current, total) {
          emit(
            RecipesLoadingState(
              progress: total > 0 ? (current / total) : 0,
              currentProgress: current,
              totalProgress: total,
            ),
          );
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
        final extractedOptions = kIsWeb
            ? await compute(_extractFilterOptionsTask, data)
            : await Isolate.run(() => _extractFilterOptionsTask(data));

        uniqueServings = extractedOptions.uniqueServings;
        servingsFilterOptionsList = extractedOptions.servingsFilterOptionsList;
        uniqueCuisine = extractedOptions.uniqueCuisine;
        cuisineFilterOptionsList = extractedOptions.cuisineFilterOptionsList;
        uniqueCourse = extractedOptions.uniqueCourse;
        courseFilterOptionsList = extractedOptions.courseFilterOptionsList;
        uniqueDiet = extractedOptions.uniqueDiet;
        dietFilterOptionsList = extractedOptions.dietFilterOptionsList;
        uniqueCookingTime = extractedOptions.uniqueCookingTime;
        cookingTimeFilterOptionsList =
            extractedOptions.cookingTimeFilterOptionsList;
        uniqueTotalCookingTime = extractedOptions.uniqueTotalCookingTime;
        totalCookingTimeFilterOptionsList =
            extractedOptions.totalCookingTimeFilterOptionsList;
        uniqueIngredients = extractedOptions.uniqueIngredients;
        ingredientFilterOptionsList =
            extractedOptions.ingredientFilterOptionsList;

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
    if (kIsWeb) {
      return await compute(
        _computeFilterTask,
        _FilterTaskParams(filters: filters, recipes: recipes),
      );
    }
    return await Isolate.run(() => _executeFilterLogic(filters, recipes));
  }

  static List<Recipe> _computeFilterTask(_FilterTaskParams params) {
    return _executeFilterLogic(params.filters, params.recipes);
  }

  static List<Recipe> _executeFilterLogic(
    List<AppliedFilterModel> filters,
    List<Recipe> recipes,
  ) {
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

        case 'ingredients':
          final selectedIngredients = filter.applied
              .map((f) => f.filterTitle.trim().toLowerCase())
              .toSet();

          filtered = filtered.where((r) {
            final raw = r.recipeTranslatedIngredientList;
            if (raw == null || raw.trim().isEmpty) return false;

            final recipeIngredients = raw
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .toSet();

            return recipeIngredients.any(selectedIngredients.contains);
          }).toList();
          break;
      }
    }

    return filtered.toSet().toList(); // Unique results
  }

  static _ExtractedFilterOptions _extractFilterOptionsTask(List<Recipe> data) {
    final List<int?> uniqueServings = <int?>[];
    final List<FilterItemModel> servingsFilterOptionsList = <FilterItemModel>[];
    final List<String> uniqueCuisine = <String>[];
    final List<FilterItemModel> cuisineFilterOptionsList = <FilterItemModel>[];
    final List<String> uniqueCourse = <String>[];
    final List<FilterItemModel> courseFilterOptionsList = <FilterItemModel>[];
    final List<String> uniqueIngredients = <String>[];
    final List<FilterItemModel> ingredientFilterOptionsList =
        <FilterItemModel>[];
    final List<String?> uniqueDiet = <String?>[];
    final List<FilterItemModel> dietFilterOptionsList = <FilterItemModel>[];
    final List<int?> uniqueCookingTime = <int?>[];
    final List<FilterItemModel> cookingTimeFilterOptionsList =
        <FilterItemModel>[];
    final List<int?> uniqueTotalCookingTime = <int?>[];
    final List<FilterItemModel> totalCookingTimeFilterOptionsList =
        <FilterItemModel>[];

    for (Recipe recipe in data) {
      if (!uniqueServings.contains(recipe.recipeServings)) {
        uniqueServings.add(recipe.recipeServings);
      }
      if (recipe.recipeCuisine != null &&
          recipe.recipeCuisine!.isNotEmpty &&
          !uniqueCuisine.contains(recipe.recipeCuisine)) {
        uniqueCuisine.add(recipe.recipeCuisine!);
      }
      if (recipe.recipeCourse != null &&
          recipe.recipeCourse!.isNotEmpty &&
          !uniqueCourse.contains(recipe.recipeCourse)) {
        uniqueCourse.add(recipe.recipeCourse!);
      }
      if (recipe.recipeTranslatedIngredientList != null &&
          recipe.recipeTranslatedIngredientList!.trim().isNotEmpty) {
        final List<String> ingredients = recipe.recipeTranslatedIngredientList!
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();

        for (final String ingredient in ingredients) {
          if (!uniqueIngredients.contains(ingredient)) {
            uniqueIngredients.add(ingredient);
          }
        }
      }
      if (recipe.recipeDiet != null &&
          recipe.recipeDiet!.isNotEmpty &&
          !uniqueDiet.contains(recipe.recipeDiet)) {
        uniqueDiet.add(recipe.recipeDiet!);
      }
      if (recipe.recipeCookingTimeInMins != null &&
          !uniqueCookingTime.contains(recipe.recipeCookingTimeInMins)) {
        uniqueCookingTime.add(recipe.recipeCookingTimeInMins);
      }
      if (recipe.recipeTotalTimeInMins != null &&
          !uniqueTotalCookingTime.contains(recipe.recipeTotalTimeInMins)) {
        uniqueTotalCookingTime.add(recipe.recipeTotalTimeInMins);
      }
    }

    mergeSort(uniqueServings, compare: (a, b) => (a ?? 0).compareTo(b ?? 0));
    uniqueCuisine.sort((a, b) => a.compareTo(b));
    uniqueCourse.sort((a, b) => a.compareTo(b));
    uniqueIngredients.sort((a, b) => a.compareTo(b));
    uniqueDiet.sort((a, b) => (a ?? '').compareTo(b ?? ''));
    uniqueCookingTime.sort((a, b) => (a ?? 0).compareTo(b ?? 0));
    uniqueTotalCookingTime.sort((a, b) => (a ?? 0).compareTo(b ?? 0));

    for (var serving in uniqueServings) {
      if (serving != null) {
        servingsFilterOptionsList.add(
          FilterItemModel(filterTitle: serving.toString(), filterKey: serving),
        );
      }
    }
    for (var cuisine in uniqueCuisine) {
      cuisineFilterOptionsList.add(
        FilterItemModel(filterTitle: cuisine, filterKey: cuisine),
      );
    }
    for (var course in uniqueCourse) {
      courseFilterOptionsList.add(
        FilterItemModel(filterTitle: course, filterKey: course),
      );
    }
    for (var ingredient in uniqueIngredients) {
      ingredientFilterOptionsList.add(
        FilterItemModel(filterTitle: ingredient, filterKey: ingredient),
      );
    }
    for (var diet in uniqueDiet) {
      if (diet != null) {
        dietFilterOptionsList.add(
          FilterItemModel(filterTitle: diet, filterKey: diet),
        );
      }
    }
    for (var time in uniqueCookingTime) {
      if (time != null) {
        cookingTimeFilterOptionsList.add(
          FilterItemModel(filterTitle: '$time mins', filterKey: time),
        );
      }
    }
    for (var time in uniqueTotalCookingTime) {
      if (time != null) {
        totalCookingTimeFilterOptionsList.add(
          FilterItemModel(filterTitle: '$time mins', filterKey: time),
        );
      }
    }

    return _ExtractedFilterOptions(
      uniqueServings: uniqueServings,
      servingsFilterOptionsList: servingsFilterOptionsList,
      uniqueCuisine: uniqueCuisine,
      cuisineFilterOptionsList: cuisineFilterOptionsList,
      uniqueCourse: uniqueCourse,
      courseFilterOptionsList: courseFilterOptionsList,
      uniqueIngredients: uniqueIngredients,
      ingredientFilterOptionsList: ingredientFilterOptionsList,
      uniqueDiet: uniqueDiet,
      dietFilterOptionsList: dietFilterOptionsList,
      uniqueCookingTime: uniqueCookingTime,
      cookingTimeFilterOptionsList: cookingTimeFilterOptionsList,
      uniqueTotalCookingTime: uniqueTotalCookingTime,
      totalCookingTimeFilterOptionsList: totalCookingTimeFilterOptionsList,
    );
  }

  @override
  Future<void> close() {
    _stateSubject.close();
    return super.close();
  }
}

class _FilterTaskParams {
  final List<AppliedFilterModel> filters;
  final List<Recipe> recipes;

  const _FilterTaskParams({required this.filters, required this.recipes});
}

class _ExtractedFilterOptions {
  final List<int?> uniqueServings;
  final List<FilterItemModel> servingsFilterOptionsList;
  final List<String> uniqueCuisine;
  final List<FilterItemModel> cuisineFilterOptionsList;
  final List<String> uniqueCourse;
  final List<FilterItemModel> courseFilterOptionsList;
  final List<String> uniqueIngredients;
  final List<FilterItemModel> ingredientFilterOptionsList;
  final List<String?> uniqueDiet;
  final List<FilterItemModel> dietFilterOptionsList;
  final List<int?> uniqueCookingTime;
  final List<FilterItemModel> cookingTimeFilterOptionsList;
  final List<int?> uniqueTotalCookingTime;
  final List<FilterItemModel> totalCookingTimeFilterOptionsList;

  const _ExtractedFilterOptions({
    required this.uniqueServings,
    required this.servingsFilterOptionsList,
    required this.uniqueCuisine,
    required this.cuisineFilterOptionsList,
    required this.uniqueCourse,
    required this.courseFilterOptionsList,
    required this.uniqueIngredients,
    required this.ingredientFilterOptionsList,
    required this.uniqueDiet,
    required this.dietFilterOptionsList,
    required this.uniqueCookingTime,
    required this.cookingTimeFilterOptionsList,
    required this.uniqueTotalCookingTime,
    required this.totalCookingTimeFilterOptionsList,
  });
}
