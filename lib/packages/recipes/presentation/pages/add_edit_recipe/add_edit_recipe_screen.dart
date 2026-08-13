import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'add_edit_recipe_screen_actions.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/add_edit_recipe/recipe_form_image_picker_section.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/add_edit_recipe/recipe_form_ingredient_tag_section.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;
  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _translatedNameController;
  late TextEditingController _servingsController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookingTimeController;
  late TextEditingController _cuisineController;
  late TextEditingController _courseController;
  late TextEditingController _dietController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;
  late TextEditingController _referenceUrlController;

  // Dynamic ingredient tag list
  final ValueNotifier<List<String>> _ingredientTagsNotifier =
      ValueNotifier<List<String>>([]);
  final TextEditingController _tagInputController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();

  final ValueNotifier<List<RecipeImageEntity>> _selectedImagesNotifier =
      ValueNotifier<List<RecipeImageEntity>>([]);
  final ImagePicker _imagePicker = ImagePicker();

  bool get isEdit => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.recipe?.recipeOriginalName ?? '',
    );
    _translatedNameController = TextEditingController(
      text: widget.recipe?.translatedRecipeName ?? '',
    );
    _servingsController = TextEditingController(
      text: widget.recipe?.recipeServings != null
          ? widget.recipe!.recipeServings.toString()
          : '',
    );
    _prepTimeController = TextEditingController(
      text: widget.recipe?.recipePreparationTimeInMins != null
          ? widget.recipe!.recipePreparationTimeInMins.toString()
          : '',
    );
    _cookingTimeController = TextEditingController(
      text: widget.recipe?.recipeCookingTimeInMins != null
          ? widget.recipe!.recipeCookingTimeInMins.toString()
          : '',
    );
    _cuisineController = TextEditingController(
      text: widget.recipe?.recipeCuisine ?? '',
    );
    _courseController = TextEditingController(
      text: widget.recipe?.recipeCourse ?? '',
    );
    _dietController = TextEditingController(
      text: widget.recipe?.recipeDiet ?? '',
    );
    _ingredientsController = TextEditingController(
      text: widget.recipe?.recipeOriginalIngredients ?? '',
    );
    _instructionsController = TextEditingController(
      text: widget.recipe?.recipeOriginalInstructions ?? '',
    );
    _referenceUrlController = TextEditingController(
      text: widget.recipe?.recipeReferenceUrl ?? '',
    );

    // Pre-populate ingredient tags from existing recipe
    final existingList = widget.recipe?.recipeTranslatedIngredientList;
    if (existingList != null && existingList.isNotEmpty) {
      _ingredientTagsNotifier.value = List.from(_ingredientTagsNotifier.value)
        ..addAll(
          existingList
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
    }
    if (widget.recipe?.images != null) {
      _selectedImagesNotifier.value = List.from(_selectedImagesNotifier.value)
        ..addAll(widget.recipe!.images!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _translatedNameController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _cookingTimeController.dispose();
    _cuisineController.dispose();
    _courseController.dispose();
    _dietController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _referenceUrlController.dispose();
    _tagInputController.dispose();
    _tagFocusNode.dispose();
    _ingredientTagsNotifier.dispose();
    _selectedImagesNotifier.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isEmpty) return;
    // Prevent duplicates (case-insensitive)
    final alreadyExists = _ingredientTagsNotifier.value.any(
      (t) => t.toLowerCase() == tag.toLowerCase(),
    );
    if (!alreadyExists) {
      final list = List<String>.from(_ingredientTagsNotifier.value);
      list.add(tag);
      _ingredientTagsNotifier.value = list;
    }
    _tagInputController.clear();
    _tagFocusNode.requestFocus();
  }

  void _removeTag(int index) {
    final list = List<String>.from(_ingredientTagsNotifier.value);
    list.removeAt(index);
    _ingredientTagsNotifier.value = list;
  }

  Future<void> _pickImages() async {
    final processedImages = await AddEditRecipeScreenActions.pickImages(
      context,
      _imagePicker,
    );
    if (processedImages != null) {
      final list = List<RecipeImageEntity>.from(_selectedImagesNotifier.value);
      list.addAll(processedImages);
      _selectedImagesNotifier.value = list;
    }
  }

  void _removeImage(int index) {
    final list = List<RecipeImageEntity>.from(_selectedImagesNotifier.value);
    list.removeAt(index);
    _selectedImagesNotifier.value = list;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final recipeName = _nameController.text.trim();
    final translatedName = _translatedNameController.text.trim();
    final servings = int.tryParse(_servingsController.text.trim()) ?? 0;
    final prepTime = int.tryParse(_prepTimeController.text.trim()) ?? 0;
    final cookTime = int.tryParse(_cookingTimeController.text.trim()) ?? 0;
    final cuisine = _cuisineController.text.trim();
    final course = _courseController.text.trim();
    final diet = _dietController.text.trim();
    final ingredients = _ingredientsController.text.trim();
    final instructions = _instructionsController.text.trim();
    final referenceUrl = _referenceUrlController.text.trim();
    final ingredientListStr = _ingredientTagsNotifier.value.isNotEmpty
        ? _ingredientTagsNotifier.value.join(',')
        : null;
    final recipeData = Recipe(
      id: widget.recipe?.id,
      recipeOriginalName: recipeName,
      translatedRecipeName: translatedName.isNotEmpty
          ? translatedName
          : recipeName,
      recipeOriginalIngredients: ingredients,
      recipeTranslatedIngredients: ingredients,
      recipeTranslatedIngredientList: ingredientListStr,
      recipeOriginalInstructions: instructions,
      recipeTranslatedInstructions: instructions,
      recipePreparationTimeInMins: prepTime,
      recipeCookingTimeInMins: cookTime,
      recipeTotalTimeInMins: prepTime + cookTime,
      recipeServings: servings,
      recipeCuisine: cuisine,
      recipeCourse: course,
      recipeDiet: diet,
      recipeReferenceUrl: referenceUrl,
      isBookmark: widget.recipe?.isBookmark ?? false,
      images: _selectedImagesNotifier.value,
    );
    await AddEditRecipeScreenActions.saveRecipe(
      context: context,
      isEdit: isEdit,
      recipeData: recipeData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            isEdit
                ? (context.tr(
                        shared.LocaleKeys.recipesFormEditTitle,
                        track: shared.TrackConstants.recipesTrack,
                      ) ??
                      'Edit Recipe')
                : (context.tr(
                        shared.LocaleKeys.recipesFormAddTitle,
                        track: shared.TrackConstants.recipesTrack,
                      ) ??
                      'Add Recipe'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
              tooltip:
                  context.tr(
                    shared.LocaleKeys.commonSave,
                    track: shared.TrackConstants.commonTrack,
                  ) ??
                  'Save Recipe',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText:
                        '${context.tr(shared.LocaleKeys.recipesFormNameLabel, track: shared.TrackConstants.recipesTrack) ?? 'Recipe Name'} *',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.recipesFormNameHint,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Enter recipe name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr(
                            shared.LocaleKeys.recipesFormNameRequired,
                            track: shared.TrackConstants.recipesTrack,
                          ) ??
                          'Please enter the recipe name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                ValueListenableBuilder<List<RecipeImageEntity>>(
                  valueListenable: _selectedImagesNotifier,
                  builder: (context, images, _) {
                    return RecipeFormImagePickerSection(
                      selectedImages: images,
                      onPickImages: _pickImages,
                      onRemoveImage: _removeImage,
                    );
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _translatedNameController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.recipesFormTranslatedNameLabel,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Recipe Translated Name',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.recipesFormTranslatedNameHint,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Enter translation (optional)',
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              '${context.tr(shared.LocaleKeys.recipesFormServingsLabel, track: shared.TrackConstants.recipesTrack) ?? 'Servings'} *',
                          hintText:
                              context.tr(
                                shared.LocaleKeys.recipesFormServingsHint,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'e.g. 4',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr(
                                  shared.LocaleKeys.recipesFormRequired,
                                  track: shared.TrackConstants.recipesTrack,
                                ) ??
                                'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return context.tr(
                                  shared.LocaleKeys.recipesFormInvalidNumber,
                                  track: shared.TrackConstants.recipesTrack,
                                ) ??
                                'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              '${context.tr(shared.LocaleKeys.recipesFormPrepTimeLabel, track: shared.TrackConstants.recipesTrack) ?? 'Preparation Time (mins)'} *',
                          hintText:
                              context.tr(
                                shared.LocaleKeys.recipesFormPrepTimeHint,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'e.g. 15',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr(
                                  shared.LocaleKeys.recipesFormRequired,
                                  track: shared.TrackConstants.recipesTrack,
                                ) ??
                                'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return context.tr(
                                  shared.LocaleKeys.recipesFormInvalidNumber,
                                  track: shared.TrackConstants.recipesTrack,
                                ) ??
                                'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: _cookingTimeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              '${context.tr(shared.LocaleKeys.recipesFormCookingTimeLabel, track: shared.TrackConstants.recipesTrack) ?? 'Cooking Time (mins)'} *',
                          hintText:
                              context.tr(
                                shared.LocaleKeys.recipesFormCookingTimeHint,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'e.g. 20',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr(
                                  shared.LocaleKeys.recipesFormRequired,
                                  track: shared.TrackConstants.recipesTrack,
                                ) ??
                                'Required';
                          }
                          if (int.tryParse(value) == null) {
                            return context.tr(
                                  shared.LocaleKeys.recipesFormInvalidNumber,
                                  track: shared.TrackConstants.recipesTrack,
                                ) ??
                                'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cuisineController,
                        decoration: InputDecoration(
                          labelText:
                              context.tr(
                                shared.LocaleKeys.recipesFormCuisineLabel,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'Cuisine',
                          hintText:
                              context.tr(
                                shared.LocaleKeys.recipesFormCuisineHint,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'e.g. Indian',
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextFormField(
                        controller: _courseController,
                        decoration: InputDecoration(
                          labelText:
                              context.tr(
                                shared.LocaleKeys.recipesFormCourseLabel,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'Course',
                          hintText:
                              context.tr(
                                shared.LocaleKeys.recipesFormCourseHint,
                                track: shared.TrackConstants.recipesTrack,
                              ) ??
                              'e.g. Dessert',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _dietController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.recipesFormDietLabel,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Diet',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.recipesFormDietHint,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'e.g. Vegetarian',
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _ingredientsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText:
                        '${context.tr(shared.LocaleKeys.recipesFormIngredientsLabel, track: shared.TrackConstants.recipesTrack) ?? 'Ingredients'} *',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.recipesFormIngredientsHint,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'e.g. 2 cups Milk, 1 tbsp Sugar, Rice, Cardamom',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr(
                            shared.LocaleKeys.recipesFormIngredientsRequired,
                            track: shared.TrackConstants.recipesTrack,
                          ) ??
                          'Please enter ingredients';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // ── Ingredient tag list (for filter indexing) ─────────────
                ValueListenableBuilder<List<String>>(
                  valueListenable: _ingredientTagsNotifier,
                  builder: (context, tags, _) {
                    return RecipeFormIngredientTagSection(
                      ingredientTags: tags,
                      tagInputController: _tagInputController,
                      tagFocusNode: _tagFocusNode,
                      onAddTag: _addTag,
                      onRemoveTag: _removeTag,
                    );
                  },
                ),

                // ─────────────────────────────────────────────────────────
                const SizedBox(height: 15),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText:
                        '${context.tr(shared.LocaleKeys.recipesFormInstructionsLabel, track: shared.TrackConstants.recipesTrack) ?? 'Instructions'} *',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.recipesFormInstructionsHint,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Step-by-step preparation steps...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr(
                            shared.LocaleKeys.recipesFormInstructionsRequired,
                            track: shared.TrackConstants.recipesTrack,
                          ) ??
                          'Please enter instructions';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _referenceUrlController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.recipesFormRefUrlLabel,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Reference Link',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.recipesFormRefUrlHint,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'e.g. https://example.com/recipe',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(
                      isEdit
                          ? (context.tr(
                                  shared.LocaleKeys.recipesFormUpdateSuccessMsg,
                                  track: shared.TrackConstants.recipesTrack,
                                ) ??
                                'Update Recipe')
                          : (context.tr(
                                  shared.LocaleKeys.recipesFormAddTitle,
                                  track: shared.TrackConstants.recipesTrack,
                                ) ??
                                'Add Recipe'),
                    ),
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
