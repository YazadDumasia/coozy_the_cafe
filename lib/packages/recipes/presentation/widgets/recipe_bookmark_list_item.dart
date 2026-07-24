import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/pages/recipes_bookmark_list_screen_actions.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class RecipeBookmarkListItem extends StatelessWidget {
  final Recipe model;
  final int index;

  const RecipeBookmarkListItem({
    super.key,
    required this.model,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      margin: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () => RecipesBookmarkListScreenActions.onRecipeItemTapped(
            context,
            model,
            index,
          ),
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
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible:
                            model.recipeOriginalName != null &&
                            model.recipeOriginalName!.isNotEmpty,
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
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                        track:
                                            shared.TrackConstants.recipesTrack,
                                      ) ??
                                      'Servings: ${model.recipeServings ?? 0}',
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                        "${model.recipeTotalTimeInMins ?? "0"} mins",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                        "${model.recipeCookingTimeInMins ?? "0"} mins",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                        "${model.recipePreparationTimeInMins ?? "0"} mins",
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
                                          'cuisine': model.recipeCuisine ?? '',
                                        },
                                        track:
                                            shared.TrackConstants.recipesTrack,
                                      ) ??
                                      'Cuisine: ${model.recipeCuisine ?? ''}',
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                        track:
                                            shared.TrackConstants.recipesTrack,
                                      ) ??
                                      'Course: ${model.recipeCourse ?? ''}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      RecipesBookmarkListScreenActions.onRemoveBookmarkPressed(
                        context,
                        model,
                      ),
                  icon: Icon(
                    model.isBookmark == true
                        ? Icons.delete
                        : Icons.delete_outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
