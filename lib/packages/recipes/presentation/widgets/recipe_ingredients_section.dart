import 'dart:io';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:coozy_the_cafe/packages/recipes/data/models/translator_language_model.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/recipes/presentation/pages/recipes_info_screen.dart'; // For RecipesInfoStateHolder

class RecipeIngredientsSection extends StatefulWidget {
  final RecipesInfoStateHolder stateHolder;
  final GoogleTranslator translator;

  const RecipeIngredientsSection({
    super.key,
    required this.stateHolder,
    required this.translator,
  });

  @override
  State<RecipeIngredientsSection> createState() =>
      _RecipeIngredientsSectionState();
}

class _RecipeIngredientsSectionState extends State<RecipeIngredientsSection> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.stateHolder,
      builder: (context, _) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.only(
            top: 10,
            right: 10,
            left: 10,
            bottom: 0,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          context.tr(
                                shared.LocaleKeys.recipesDetailIngredientsLabel,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'Ingredients:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Divider(height: 1),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return ToggleButtons(
                                    renderBorder: false,
                                    constraints: BoxConstraints.expand(
                                      width: constraints.maxWidth / 3,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    isSelected: widget
                                        .stateHolder
                                        .isIngredientsEnglishTranslationSelection,
                                    onPressed: (int index) async {
                                      if (index == 0) {
                                        widget.stateHolder
                                            .updateIngredientsSelection(
                                              index,
                                              widget
                                                      .stateHolder
                                                      .recipe
                                                      .recipeTranslatedIngredients ??
                                                  '',
                                            );
                                      } else if (index == 1) {
                                        widget.stateHolder
                                            .updateIngredientsSelection(
                                              index,
                                              widget
                                                      .stateHolder
                                                      .recipe
                                                      .recipeOriginalIngredients ??
                                                  '',
                                            );
                                      } else if (index == 2) {
                                        widget.stateHolder
                                            .updateIngredientsSelection(
                                              index,
                                              '',
                                            );
                                        _translateIngredients(
                                          'en',
                                          widget
                                              .stateHolder
                                              .ingredientSelectedLanguage
                                              .code2,
                                        );
                                      }
                                    },
                                    children: <Widget>[
                                      Text(
                                        context.tr(
                                              shared
                                                  .LocaleKeys
                                                  .recipesDetailOrginalBtn,
                                              track: shared
                                                  .TrackConstants
                                                  .recipesTrack,
                                            ) ??
                                            'Orginal',
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        context.tr(
                                              shared
                                                  .LocaleKeys
                                                  .recipesDetailOfflineBtn,
                                              track: shared
                                                  .TrackConstants
                                                  .recipesTrack,
                                            ) ??
                                            'Offline Translation',
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        context.tr(
                                              shared
                                                  .LocaleKeys
                                                  .recipesDetailOtherBtn,
                                              track: shared
                                                  .TrackConstants
                                                  .recipesTrack,
                                            ) ??
                                            'Other Language',
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(height: 1),
                      const SizedBox(height: 5),
                      ingredientsInfoWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget ingredientsInfoWidget() {
    bool isTranslateEnable = false;
    for (
      int i = 0;
      i < widget.stateHolder.isIngredientsEnglishTranslationSelection.length;
      i++
    ) {
      if (widget.stateHolder.isIngredientsEnglishTranslationSelection[i] &&
          i == 2) {
        isTranslateEnable = true;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(child: Text(widget.stateHolder.ingredientsInfoString)),
            ],
          ),
          const SizedBox(height: 10),
          Visibility(
            visible: isTranslateEnable,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      _showIngredientLanguageSelectionBottomSheet(context);
                    },
                    icon: const Icon(Icons.translate),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          context.tr(
                                shared.LocaleKeys.recipesDetailTranslateBtn,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'translate',
                        ),
                        const SizedBox(width: 5),
                        const Text('-'),
                        const SizedBox(width: 5),
                        Text(
                          widget.stateHolder.ingredientSelectedLanguage.name,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIngredientLanguageSelectionBottomSheet(BuildContext context) {
    List<TranslatorLanguageModel> filteredLanguages = List.from(
      TranslatorLanguageModel.languages,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setLocalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.tr(
                          shared.LocaleKeys.recipesDetailSelectLangTitle,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Select Language',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText:
                          context.tr(
                            shared.LocaleKeys.recipesDetailSearchLangHint,
                            track: shared.TrackConstants.recipesTrack,
                          ) ??
                          'Search',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setLocalState(() {
                        filteredLanguages = TranslatorLanguageModel.languages
                            .where(
                              (lang) => lang.name.toLowerCase().contains(
                                value.toLowerCase(),
                              ),
                            )
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredLanguages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(filteredLanguages[index].name),
                          onTap: () {
                            Navigator.pop(context, filteredLanguages[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((selectedLanguage) {
      if (selectedLanguage != null) {
        widget.stateHolder.updateIngredientLanguage(selectedLanguage);
        _translateIngredients(
          'en',
          widget.stateHolder.ingredientSelectedLanguage.code2,
        );
      }
    });
  }

  Future<void> _translateIngredients(
    String? fromLanguage,
    String? toLanguage,
  ) async {
    try {
      shared.DialogUtils.showLoadingDialog(context);
      await widget.translator
          .translate(
            widget.stateHolder.recipe.recipeTranslatedIngredients ?? '',
            from: fromLanguage ?? 'auto',
            to: toLanguage!,
          )
          .then((value) {
            if (!mounted) return;
            Navigator.pop(context);
            widget.stateHolder.updateIngredientsText(value.text);
          });
    } on SocketException {
      if (!mounted) return;
      Navigator.pop(context);
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonError,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Error',
        descriptions:
            context.tr(
              shared.LocaleKeys.recipesDetailNoInternetMsg,
              track: shared.TrackConstants.recipesTrack,
            ) ??
            'Internet not Connected',
        titleIcon: const Icon(Icons.wifi_off, color: Colors.red, size: 50),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      shared.DialogUtils.showAutoDismissDialog(
        context: context,
        title:
            context.tr(
              shared.LocaleKeys.commonError,
              track: shared.TrackConstants.commonTrack,
            ) ??
            'Error',
        descriptions:
            context.tr(
              shared.LocaleKeys.recipesDetailTranslateFailMsg,
              track: shared.TrackConstants.recipesTrack,
            ) ??
            'Failed to translate content. Please try again',
        titleIcon: const Icon(Icons.error, color: Colors.red, size: 50),
      );
    }
  }
}
