import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:collection/collection.dart';

class RecipesListScreenActions {
  static Future<void> onBookmarksPressed(BuildContext context) async {
    await context
        .push(
          '${AppRoutePath.recipesListScreenRoute}/${AppRoutePath.recipesBookmarkListScreenRoute}',
        )
        .then((_) {
          if (context.mounted) {
            BlocProvider.of<RecipesFullListCubit>(
              context,
            ).reloadWithCurrentState(context);
          }
        });
  }

  static Future<void> onAddRecipePressed(BuildContext context) async {
    final result = await context.push(
      '${AppRoutePath.recipesListScreenRoute}/edit',
    );
    if (result == true && context.mounted) {
      BlocProvider.of<RecipesFullListCubit>(
        context,
      ).reloadWithCurrentState(context);
    }
  }

  static void onSearchCleared(
    BuildContext context,
    TextEditingController controller,
  ) {
    controller.clear();
    BlocProvider.of<RecipesFullListCubit>(context).searchRecipes('');
  }

  static void onSearchSubmitted(BuildContext context, String value) {
    BlocProvider.of<RecipesFullListCubit>(context).searchRecipes(value);
  }

  static Future<void> onRecipeItemTapped(
    BuildContext context,
    Recipe model,
    int index,
  ) async {
    await context.push(
      '${AppRoutePath.recipesListScreenRoute}/${AppRoutePath.recipesInfoScreenRoute}',
      extra: {'model': model, 'index': index},
    );
    if (context.mounted) {
      BlocProvider.of<RecipesFullListCubit>(
        context,
      ).reloadWithCurrentState(context);
    }
  }

  static Future<void> onEditRecipePressed(
    BuildContext context,
    Recipe model,
  ) async {
    final result = await context.push(
      '${AppRoutePath.recipesListScreenRoute}/edit',
      extra: model,
    );
    if (result == true && context.mounted) {
      BlocProvider.of<RecipesFullListCubit>(
        context,
      ).reloadWithCurrentState(context);
    }
  }

  static void onBookmarkTogglePressed(
    BuildContext context,
    Recipe model,
    int index,
  ) {
    BlocProvider.of<RecipesFullListCubit>(
      context,
    ).updateBookmark(model: model, context: context, currentIndex: index);
  }

  static void onPageChanged(BuildContext context, int nextPage) {
    BlocProvider.of<RecipesFullListCubit>(context).updatePageNumber(nextPage);
  }

  static void onItemsPerPageChanged(BuildContext context, int? itemsPerPage) {
    BlocProvider.of<RecipesFullListCubit>(
      context,
    ).updatePageItems(itemsPerPage: itemsPerPage ?? 10);
  }

  static void onRetryPressed(BuildContext context) {
    BlocProvider.of<RecipesFullListCubit>(context).loadData();
  }

  static Future<void> showFilterView(BuildContext context) async {
    final cubit = context.read<RecipesFullListCubit>();
    return showModalBottomSheet(
      isDismissible: false,
      context: context,
      enableDrag: false,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: MediaQuery.of(context).size.width,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      isScrollControlled: true,
      builder: (_) {
        return shared.FilterWidget(
          filterProps: shared.FilterProps(
            onFilterChange: (value) async {
              shared.DialogUtils.showSimpleLoadingDialog(
                context,
                'Applying filters...',
              );
              await cubit.applyFilter(fliter: value);
              if (context.mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            filters: <shared.FilterListModel>[
              shared.FilterListModel(
                type: shared.FilterType.radioGroup,
                filterOptions:
                    cubit.servingsFilterOptionsList ??
                    <shared.FilterItemModel>[],
                previousApplied:
                    _getPreviousAppliedFilters(
                      cubit.appliedFilterList,
                      'servings',
                    ) ??
                    <shared.FilterItemModel>[],
                title:
                    context.tr(
                      shared.LocaleKeys.recipesFilterServings,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Servings',
                filterKey: 'servings',
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              shared.FilterListModel(
                type: shared.FilterType.checkboxList,
                filterOptions:
                    cubit.cuisineFilterOptionsList ??
                    <shared.FilterItemModel>[],
                previousApplied:
                    _getPreviousAppliedFilters(
                      cubit.appliedFilterList,
                      'cuisine',
                    ) ??
                    <shared.FilterItemModel>[],
                title:
                    context.tr(
                      shared.LocaleKeys.recipesFilterCuisine,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Cuisine',
                filterKey: 'cuisine',
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              shared.FilterListModel(
                type: shared.FilterType.checkboxList,
                filterOptions:
                    cubit.courseFilterOptionsList ?? <shared.FilterItemModel>[],
                previousApplied:
                    _getPreviousAppliedFilters(
                      cubit.appliedFilterList,
                      'course',
                    ) ??
                    <shared.FilterItemModel>[],
                title:
                    context.tr(
                      shared.LocaleKeys.recipesFilterCourse,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Course',
                filterKey: 'course',
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              shared.FilterListModel(
                type: shared.FilterType.checkboxList,
                filterOptions:
                    cubit.ingredientFilterOptionsList ??
                    <shared.FilterItemModel>[],
                previousApplied:
                    _getPreviousAppliedFilters(
                      cubit.appliedFilterList,
                      'ingredients',
                    ) ??
                    <shared.FilterItemModel>[],
                title:
                    context.tr(
                      shared.LocaleKeys.recipesFilterIngredients,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Ingredients',
                filterKey: 'ingredients',
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              shared.FilterListModel(
                type: shared.FilterType.radioGroup,
                filterOptions:
                    cubit.dietFilterOptionsList ?? <shared.FilterItemModel>[],
                previousApplied:
                    _getPreviousAppliedFilters(
                      cubit.appliedFilterList,
                      'diet',
                    ) ??
                    <shared.FilterItemModel>[],
                title:
                    context.tr(
                      shared.LocaleKeys.recipesFilterDiet,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Diet',
                filterKey: 'diet',
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              shared.FilterListModel(
                type: shared.FilterType.rangeSlider,
                filterOptions:
                    cubit.totalCookingTimeFilterOptionsList ??
                    <shared.FilterItemModel>[],
                previousApplied:
                    _getPreviousAppliedFilters(
                      cubit.appliedFilterList,
                      'total_cooking_time',
                    ) ??
                    <shared.FilterItemModel>[],
                title:
                    context.tr(
                      shared.LocaleKeys.recipesFilterTotalCookingTime,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Total cooking time',
                filterKey: 'total_cooking_time',
                backgroundColor: Theme.of(context).colorScheme.surface,
                sliderTileThemeProps: shared.SliderTileThemeProps(
                  labelSuffixStr: 'mins',
                  tooltipSuffixStr: 'mins',
                  stepSize: 1,
                  fractionDigits: 0,
                ),
              ),
              shared.FilterListModel(
                type: shared.FilterType.slider,
                filterOptions:
                    cubit.cookingTimeFilterOptionsList ??
                    <shared.FilterItemModel>[],
                previousApplied:
                    _getPreviousAppliedFilters(
                      cubit.appliedFilterList,
                      'cooking_time',
                    ) ??
                    <shared.FilterItemModel>[],
                title:
                    context.tr(
                      shared.LocaleKeys.recipesFilterCookingTime,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Cooking Time',
                filterKey: 'cooking_time',
                backgroundColor: Theme.of(context).colorScheme.surface,
                sliderTileThemeProps: shared.SliderTileThemeProps(
                  labelSuffixStr: 'mins',
                  tooltipSuffixStr: 'mins',
                  sliderThemeData: const SfRangeSliderThemeData(),
                  stepSize: 1,
                  fractionDigits: 0,
                ),
              ),
            ],
            themeProps: shared.ThemeProps(
              activeFilterTextColor: Theme.of(
                context,
              ).textTheme.bodyLarge!.color,
              dividerColor: Theme.of(context).dividerColor,
              inActiveFilterItemBackgroundColor: Theme.of(
                context,
              ).colorScheme.secondaryContainer,
              inActiveFilterTextColor: Theme.of(
                context,
              ).textTheme.bodyLarge!.color,
              submitButtonThemeStyle: Theme.of(context)
                  .elevatedButtonTheme
                  .style
                  ?.copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    shape: WidgetStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.zero),
                      ),
                    ),
                  ),
              resetButtonColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        );
      },
    );
  }

  static List<shared.FilterItemModel>? _getPreviousAppliedFilters(
    List<shared.AppliedFilterModel>? appliedFilterList,
    String filterKey,
  ) {
    if (appliedFilterList == null || appliedFilterList.isEmpty) {
      return <shared.FilterItemModel>[];
    } else {
      final shared.AppliedFilterModel? previousFilter = appliedFilterList
          .firstWhereOrNull((element) => element.filterKey == filterKey);
      return previousFilter?.applied;
    }
  }
}
