import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui' as ui;

import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/data/models/translator_language_model.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/recipes_info/recipe_ingredients_section.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/recipes_info/recipe_instructions_section.dart';
import 'recipes_info_screen_actions.dart';

class RecipesInfoStateHolder extends ChangeNotifier {
  Recipe recipe;
  List<bool> isIngredientsEnglishTranslationSelection = <bool>[
    true,
    false,
    false,
  ];
  List<bool> isInstructionEnglishTranslationSelection = <bool>[
    true,
    false,
    false,
  ];
  String ingredientsInfoString = '';
  String instructionInfoString = '';
  TranslatorLanguageModel ingredientSelectedLanguage =
      const TranslatorLanguageModel(name: 'Hindi', code2: 'hi');
  TranslatorLanguageModel instructionSelectedLanguage =
      const TranslatorLanguageModel(name: 'Hindi', code2: 'hi');

  RecipesInfoStateHolder(this.recipe) {
    ingredientsInfoString = recipe.recipeTranslatedIngredients ?? '';
    instructionInfoString = recipe.recipeTranslatedInstructions ?? '';
  }

  void updateRecipe(Recipe newRecipe) {
    recipe = newRecipe;
    notifyListeners();
  }

  void updateIngredientsSelection(int index, String text) {
    for (int i = 0; i < isIngredientsEnglishTranslationSelection.length; i++) {
      isIngredientsEnglishTranslationSelection[i] = i == index;
    }
    ingredientsInfoString = text;
    notifyListeners();
  }

  void updateInstructionSelection(int index, String text) {
    for (int i = 0; i < isInstructionEnglishTranslationSelection.length; i++) {
      isInstructionEnglishTranslationSelection[i] = i == index;
    }
    instructionInfoString = text;
    notifyListeners();
  }

  void updateIngredientsText(String text) {
    ingredientsInfoString = text;
    notifyListeners();
  }

  void updateInstructionText(String text) {
    instructionInfoString = text;
    notifyListeners();
  }

  void updateIngredientLanguage(TranslatorLanguageModel lang) {
    ingredientSelectedLanguage = lang;
    notifyListeners();
  }

  void updateInstructionLanguage(TranslatorLanguageModel lang) {
    instructionSelectedLanguage = lang;
    notifyListeners();
  }
}

class RecipesInfoScreen extends StatefulWidget {
  final Recipe model;
  final int? currentIndex;

  const RecipesInfoScreen({required this.model, super.key, this.currentIndex});

  @override
  State<RecipesInfoScreen> createState() => _RecipesInfoScreenState();
}

class _RecipesInfoScreenState extends State<RecipesInfoScreen> {
  late final RecipesInfoStateHolder _stateHolder;
  Size? size;
  Orientation? orientation;
  final GoogleTranslator translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _stateHolder = RecipesInfoStateHolder(widget.model);
    core.PlatformUtils.debugLog(
      RecipesInfoScreen,
      'Ingredients:${_stateHolder.ingredientsInfoString}',
    );
    core.PlatformUtils.debugLog(
      RecipesInfoScreen,
      'Instructions:${_stateHolder.instructionInfoString}',
    );
  }

  @override
  void dispose() {
    _stateHolder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    orientation = MediaQuery.of(context).orientation;
    return ListenableBuilder(
      listenable: _stateHolder,
      builder: (context, _) {
        final recipe = _stateHolder.recipe;
        return SafeArea(
          child: PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && context.mounted) {
                Navigator.pop(context, result);
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: Text(
                  context.tr(
                        shared.LocaleKeys.recipesTitle,
                        track: shared.TrackConstants.recipesTrack,
                      ) ??
                      ' Recipes Details',
                ),
                centerTitle: false,
                actions: <Widget>[
                  IconButton(
                    onPressed: () => RecipesInfoScreenActions.bookmark(
                      context,
                      _stateHolder,
                      widget.currentIndex,
                    ),
                    icon: recipe.isBookmark == true
                        ? const Icon(Icons.bookmark, color: Colors.white)
                        : const Icon(
                            Icons.bookmark_outline,
                            color: Colors.white,
                          ),
                    tooltip:
                        context.tr(
                          shared.LocaleKeys.recipesBookmarksTitle,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Bookmark',
                  ),
                  IconButton(
                    onPressed: () =>
                        RecipesInfoScreenActions.shareRecipe(_stateHolder),
                    icon: const Icon(Icons.share, color: Colors.white),
                    tooltip:
                        context.tr(
                          shared.LocaleKeys.recipesShareTooltip,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Share this recipe',
                  ),
                ],
              ),
              body: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: SelectableText.rich(
                              scrollPhysics:
                                  const NeverScrollableScrollPhysics(),
                              selectionHeightStyle: ui.BoxHeightStyle.tight,
                              TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailTitleLabel,
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Title: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(
                                    text: recipe.recipeOriginalName ?? '',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: SelectableText.rich(
                              scrollPhysics:
                                  const NeverScrollableScrollPhysics(),
                              selectionHeightStyle: ui.BoxHeightStyle.tight,
                              TextSpan(
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailTranslatedTitleLabel,
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Translated title: ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(
                                    text: recipe.translatedRecipeName ?? '',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(shared.MenuIcons.servingTime, size: 30),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailServingsLabel,
                                          params: {
                                            'servings':
                                                '${recipe.recipeServings ?? 0}',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Servings: ${recipe.recipeServings ?? 0}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(shared.MenuIcons.totalCookingTime, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailTotalTimeLabel,
                                          params: {
                                            'time':
                                                '${recipe.recipeTotalTimeInMins ?? 0}',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Total cooking time: ${recipe.recipeTotalTimeInMins ?? 0} mins',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(shared.MenuIcons.coookingTime, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailCookingTimeLabel,
                                          params: {
                                            'time':
                                                '${recipe.recipeCookingTimeInMins ?? 0}',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Cooking time: ${recipe.recipeCookingTimeInMins ?? 0} mins',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(shared.MenuIcons.servingTime, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailPrepTimeLabel,
                                          params: {
                                            'time':
                                                '${recipe.recipePreparationTimeInMins ?? 0}',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Preparation time: ${recipe.recipePreparationTimeInMins ?? 0} mins',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.restaurant, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailCuisineLabel,
                                          params: {
                                            'cuisine':
                                                recipe.recipeCuisine ?? '',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Cuisine: ${recipe.recipeCuisine ?? ''}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.dinner_dining, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailCourseLabel,
                                          params: {
                                            'course': recipe.recipeCourse ?? '',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Course: ${recipe.recipeCourse ?? ''}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.eco, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                                children: <InlineSpan>[
                                  TextSpan(
                                    text:
                                        context.tr(
                                          shared
                                              .LocaleKeys
                                              .recipesDetailDietLabel,
                                          params: {
                                            'diet': recipe.recipeDiet ?? '',
                                          },
                                          track: shared
                                              .TrackConstants
                                              .recipesTrack,
                                        ) ??
                                        'Diet: ${recipe.recipeDiet ?? ''}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 5,
                      margin: const EdgeInsets.only(
                        top: 10,
                        right: 10,
                        left: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Icon(Icons.link),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .recipesDetailRefLinkLabel,
                                                track: shared
                                                    .TrackConstants
                                                    .recipesTrack,
                                              ) ??
                                              'Reference link:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () async {
                                            final String? url =
                                                recipe.recipeReferenceUrl;
                                            if (url != null && url.isNotEmpty) {
                                              if (!await launchUrl(
                                                Uri.parse(url),
                                              )) {
                                                throw Exception(
                                                  'Could not launch $url',
                                                );
                                              }
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,

                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            alignment: Alignment.centerLeft,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            recipe.recipeReferenceUrl ?? '',
                                            textAlign: TextAlign.left,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RecipeIngredientsSection(
                      stateHolder: _stateHolder,
                      translator: translator,
                    ),
                    RecipeInstructionsSection(
                      stateHolder: _stateHolder,
                      translator: translator,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
