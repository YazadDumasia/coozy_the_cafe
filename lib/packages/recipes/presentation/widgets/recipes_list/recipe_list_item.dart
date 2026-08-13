import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_full_list_cubit.dart';
import '../../pages/recipes_list/recipes_list_screen_actions.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class RecipeListItem extends StatelessWidget {
  final RecipesLoadedState state;
  final Recipe model;
  final int index;

  const RecipeListItem({
    super.key,
    required this.state,
    required this.model,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () async {
              await RecipesListScreenActions.onRecipeItemTapped(
                context,
                model,
                index,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Visibility(
                          visible:
                              model.translatedRecipeName != null &&
                              model.translatedRecipeName!.isNotEmpty,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  model.translatedRecipeName ?? '',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible:
                              model.recipeOriginalName != null &&
                              model.recipeOriginalName!.isNotEmpty &&
                              model.recipeOriginalName !=
                                  model.translatedRecipeName,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    model.recipeOriginalName ?? '',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailServingsLabel,
                                          params: {
                                            'servings':
                                                '${model.recipeServings ?? 0}',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Servings: ${model.recipeServings ?? 0}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  runAlignment: WrapAlignment.start,
                                  runSpacing: 10,
                                  spacing: 10,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          shared.MenuIcons.totalCookingTime,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${model.recipeTotalTimeInMins ?? '0'} mins',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          shared.MenuIcons.coookingTime,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${model.recipeCookingTimeInMins ?? '0'} mins',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          shared.MenuIcons.servingTime,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${model.recipePreparationTimeInMins ?? '0'} mins',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailCuisineLabel,
                                          params: {
                                            'cuisine':
                                                model.recipeCuisine ?? '',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Cuisine: ${model.recipeCuisine ?? ''}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailCourseLabel,
                                          params: {
                                            'course': model.recipeCourse ?? '',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Course: ${model.recipeCourse ?? ''}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (model.id == null)
                        IconButton(
                          onPressed: () async {
                            await RecipesListScreenActions.onEditRecipePressed(
                              context,
                              model,
                            );
                          },
                          icon: const Icon(Icons.edit),
                          tooltip:
                              context.tr(
                                shared.LocaleKeys.recipesEditTooltip,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'Edit recipe',
                        ),
                      IconButton(
                        onPressed: () {
                          RecipesListScreenActions.onBookmarkTogglePressed(
                            context,
                            model,
                            index,
                          );
                        },
                        icon: Icon(
                          model.isBookmark == true
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
