import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_bookmark_list_cubit.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/pages/recipes_info_screen.dart';

class RecipesInfoScreenActions {
  static Future<void> shareRecipe(RecipesInfoStateHolder stateHolder) async {
    final StringBuffer stringBuffer = StringBuffer('');
    if (stateHolder.recipe.recipeOriginalName != null &&
        stateHolder.recipe.recipeOriginalName!.isNotEmpty) {
      stringBuffer.write(
        "Recipe: ${stateHolder.recipe.recipeOriginalName ?? ""}",
      );
    }
    if (stateHolder.recipe.recipeReferenceUrl != null &&
        stateHolder.recipe.recipeReferenceUrl!.isNotEmpty) {
      stringBuffer.write(
        "\nReference: ${stateHolder.recipe.recipeReferenceUrl ?? ""}",
      );
    }

    // ignore: deprecated_member_use
    final ShareResult result = await Share.share(stringBuffer.toString());
    if (result.status == ShareResultStatus.success) {
      core.PlatformUtils.debugLog(
        RecipesInfoScreenActions,
        'Shared successfully.',
      );
    }
  }

  static void bookmark(
    BuildContext context,
    RecipesInfoStateHolder stateHolder,
    int? currentIndex,
  ) {
    final updated = stateHolder.recipe.copyWith(
      isBookmark: !(stateHolder.recipe.isBookmark ?? false),
    );

    // Update Full List Cubit
    try {
      context.read<RecipesFullListCubit>().updateBookmark(
        model: stateHolder.recipe,
        context: context,
        currentIndex: currentIndex ?? 0,
      );
    } catch (_) {}

    // Update Bookmark List Cubit
    try {
      context.read<RecipesBookmarkListCubit>().updateRecipe(updated);
    } catch (_) {}

    stateHolder.updateRecipe(updated);
  }
}
