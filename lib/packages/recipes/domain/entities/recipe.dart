class Recipe {
  final int? recipeId;
  final int? id;
  final String? recipeOriginalName;
  final String? translatedRecipeName;
  final String? recipeOriginalIngredients;
  final String? recipeTranslatedIngredientList;
  final String? recipeTranslatedIngredients;
  final int? recipePreparationTimeInMins;
  final int? recipeCookingTimeInMins;
  final int? recipeTotalTimeInMins;
  final int? recipeServings;
  final String? recipeCuisine;
  final String? recipeCourse;
  final String? recipeDiet;
  final String? recipeOriginalInstructions;
  final String? recipeTranslatedInstructions;
  final String? recipeReferenceUrl;
  final bool? isBookmark;
  final List<RecipeImageEntity>? images;

  const Recipe({
    this.recipeId,
    this.id,
    this.recipeOriginalName,
    this.translatedRecipeName,
    this.recipeOriginalIngredients,
    this.recipeTranslatedIngredientList,
    this.recipeTranslatedIngredients,
    this.recipePreparationTimeInMins,
    this.recipeCookingTimeInMins,
    this.recipeTotalTimeInMins,
    this.recipeServings,
    this.recipeCuisine,
    this.recipeCourse,
    this.recipeDiet,
    this.recipeOriginalInstructions,
    this.recipeTranslatedInstructions,
    this.recipeReferenceUrl,
    this.isBookmark,
    this.images,
  });

  Recipe copyWith({
    int? recipeId,
    int? id,
    String? recipeOriginalName,
    String? translatedRecipeName,
    String? recipeOriginalIngredients,
    String? recipeTranslatedIngredientList,
    String? recipeTranslatedIngredients,
    int? recipePreparationTimeInMins,
    int? recipeCookingTimeInMins,
    int? recipeTotalTimeInMins,
    int? recipeServings,
    String? recipeCuisine,
    String? recipeCourse,
    String? recipeDiet,
    String? recipeOriginalInstructions,
    String? recipeTranslatedInstructions,
    String? recipeReferenceUrl,
    bool? isBookmark,
    List<RecipeImageEntity>? images,
  }) {
    return Recipe(
      recipeId: recipeId ?? this.recipeId,
      id: id ?? this.id,
      recipeOriginalName: recipeOriginalName ?? this.recipeOriginalName,
      translatedRecipeName: translatedRecipeName ?? this.translatedRecipeName,
      recipeOriginalIngredients: recipeOriginalIngredients ?? this.recipeOriginalIngredients,
      recipeTranslatedIngredientList: recipeTranslatedIngredientList ?? this.recipeTranslatedIngredientList,
      recipeTranslatedIngredients: recipeTranslatedIngredients ?? this.recipeTranslatedIngredients,
      recipePreparationTimeInMins: recipePreparationTimeInMins ?? this.recipePreparationTimeInMins,
      recipeCookingTimeInMins: recipeCookingTimeInMins ?? this.recipeCookingTimeInMins,
      recipeTotalTimeInMins: recipeTotalTimeInMins ?? this.recipeTotalTimeInMins,
      recipeServings: recipeServings ?? this.recipeServings,
      recipeCuisine: recipeCuisine ?? this.recipeCuisine,
      recipeCourse: recipeCourse ?? this.recipeCourse,
      recipeDiet: recipeDiet ?? this.recipeDiet,
      recipeOriginalInstructions: recipeOriginalInstructions ?? this.recipeOriginalInstructions,
      recipeTranslatedInstructions: recipeTranslatedInstructions ?? this.recipeTranslatedInstructions,
      recipeReferenceUrl: recipeReferenceUrl ?? this.recipeReferenceUrl,
      isBookmark: isBookmark ?? this.isBookmark,
      images: images ?? this.images,
    );
  }
}

class RecipeImageEntity {
  final int? id;
  final int? recipeId;
  final String fileName;
  final String base64Data;

  const RecipeImageEntity({
    this.id,
    this.recipeId,
    required this.fileName,
    required this.base64Data,
  });

  RecipeImageEntity copyWith({
    int? id,
    int? recipeId,
    String? fileName,
    String? base64Data,
  }) {
    return RecipeImageEntity(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      fileName: fileName ?? this.fileName,
      base64Data: base64Data ?? this.base64Data,
    );
  }
}
