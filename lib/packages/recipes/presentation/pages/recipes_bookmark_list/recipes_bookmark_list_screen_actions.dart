import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_bookmark_list_cubit.dart';

class RecipesBookmarkListScreenActions {
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
      BlocProvider.of<RecipesBookmarkListCubit>(context).loadData();
    }
  }

  static Future<void> onRemoveBookmarkPressed(
    BuildContext context,
    Recipe model,
  ) async {
    final toggled = model.copyWith(isBookmark: !(model.isBookmark ?? false));
    await BlocProvider.of<RecipesBookmarkListCubit>(
      context,
    ).updateRecipe(toggled);
  }
}
