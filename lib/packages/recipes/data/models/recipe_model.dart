import 'package:drift/drift.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart' as db;

class RecipeModel extends Recipe {
  const RecipeModel({
    super.recipeId,
    super.id,
    super.recipeOriginalName,
    super.translatedRecipeName,
    super.recipeOriginalIngredients,
    super.recipeTranslatedIngredientList,
    super.recipeTranslatedIngredients,
    super.recipePreparationTimeInMins,
    super.recipeCookingTimeInMins,
    super.recipeTotalTimeInMins,
    super.recipeServings,
    super.recipeCuisine,
    super.recipeCourse,
    super.recipeDiet,
    super.recipeOriginalInstructions,
    super.recipeTranslatedInstructions,
    super.recipeReferenceUrl,
    super.isBookmark,
    super.images,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    String? ingredientListStr;
    if (json['recipe_translated_ingredient_list'] != null) {
      if (json['recipe_translated_ingredient_list'] is List) {
        ingredientListStr = (json['recipe_translated_ingredient_list'] as List).join(',');
      } else {
        ingredientListStr = json['recipe_translated_ingredient_list'].toString();
      }
    }

    return RecipeModel(
      id: json['id'],
      recipeOriginalName: json['recipe_original_name'] ?? json['recipe_name'],
      translatedRecipeName: json['translated_recipe_name'],
      recipeOriginalIngredients: json['recipe_original_ingredients'] ?? json['recipe_ingredients'],
      recipeTranslatedIngredients: json['recipe_translated_ingredients'],
      recipeTranslatedIngredientList: ingredientListStr,
      recipePreparationTimeInMins: json['recipe_preparation_time_in_mins'],
      recipeCookingTimeInMins: json['recipe_cooking_time_in_mins'],
      recipeTotalTimeInMins: json['recipe_total_time_in_mins'],
      recipeServings: json['recipe_servings'],
      recipeCuisine: json['recipe_cuisine'],
      recipeCourse: json['recipe_course'],
      recipeDiet: json['recipe_diet'],
      recipeOriginalInstructions: json['recipe_original_instructions'] ?? json['recipe_instructions'],
      recipeTranslatedInstructions: json['recipe_translated_instructions'],
      recipeReferenceUrl: json['recipe_reference_url'],
      isBookmark: json['isBookmark'] == null
          ? false
          : (json['isBookmark'] == 1 || json['isBookmark'] == true),
      images: (json['images'] as List?)?.map((e) => RecipeImageEntity(
            id: e['id'],
            recipeId: e['recipe_id'],
            fileName: e['file_name'],
            base64Data: e['base64_data'],
          )).toList(),
    );
  }

  factory RecipeModel.fromData(db.Recipe data) {
    return RecipeModel(
      recipeId: data.recipeId,
      id: data.id,
      recipeOriginalName: data.recipeOriginalName,
      translatedRecipeName: data.translatedRecipeName,
      recipeOriginalIngredients: data.recipeOriginalIngredients,
      recipeTranslatedIngredientList: data.recipeTranslatedIngredientList,
      recipeTranslatedIngredients: data.recipeTranslatedIngredients,
      recipePreparationTimeInMins: data.recipePreparationTimeInMins,
      recipeCookingTimeInMins: data.recipeCookingTimeInMins,
      recipeTotalTimeInMins: data.recipeTotalTimeInMins,
      recipeServings: data.recipeServings,
      recipeCuisine: data.recipeCuisine,
      recipeCourse: data.recipeCourse,
      recipeDiet: data.recipeDiet,
      recipeOriginalInstructions: data.recipeOriginalInstructions,
      recipeTranslatedInstructions: data.recipeTranslatedInstructions,
      recipeReferenceUrl: data.recipeReferenceUrl,
      isBookmark: data.isBookmark,
      // Images will be loaded separately as they come from another table
    );
  }

  factory RecipeModel.fromEntity(Recipe entity) {
    return RecipeModel(
      recipeId: entity.recipeId,
      id: entity.id,
      recipeOriginalName: entity.recipeOriginalName,
      translatedRecipeName: entity.translatedRecipeName,
      recipeOriginalIngredients: entity.recipeOriginalIngredients,
      recipeTranslatedIngredientList: entity.recipeTranslatedIngredientList,
      recipeTranslatedIngredients: entity.recipeTranslatedIngredients,
      recipePreparationTimeInMins: entity.recipePreparationTimeInMins,
      recipeCookingTimeInMins: entity.recipeCookingTimeInMins,
      recipeTotalTimeInMins: entity.recipeTotalTimeInMins,
      recipeServings: entity.recipeServings,
      recipeCuisine: entity.recipeCuisine,
      recipeCourse: entity.recipeCourse,
      recipeDiet: entity.recipeDiet,
      recipeOriginalInstructions: entity.recipeOriginalInstructions,
      recipeTranslatedInstructions: entity.recipeTranslatedInstructions,
      recipeReferenceUrl: entity.recipeReferenceUrl,
      isBookmark: entity.isBookmark,
      images: entity.images,
    );
  }

  db.RecipesTableCompanion toCompanion() {
    return db.RecipesTableCompanion(
      recipeId: recipeId == null ? const Value.absent() : Value(recipeId!),
      id: id == null ? const Value.absent() : Value(id),
      recipeOriginalName: recipeOriginalName == null ? const Value.absent() : Value(recipeOriginalName),
      translatedRecipeName: translatedRecipeName == null ? const Value.absent() : Value(translatedRecipeName),
      recipeOriginalIngredients: recipeOriginalIngredients == null ? const Value.absent() : Value(recipeOriginalIngredients),
      recipeTranslatedIngredientList: recipeTranslatedIngredientList == null ? const Value.absent() : Value(recipeTranslatedIngredientList),
      recipeTranslatedIngredients: recipeTranslatedIngredients == null ? const Value.absent() : Value(recipeTranslatedIngredients),
      recipePreparationTimeInMins: recipePreparationTimeInMins == null ? const Value.absent() : Value(recipePreparationTimeInMins),
      recipeCookingTimeInMins: recipeCookingTimeInMins == null ? const Value.absent() : Value(recipeCookingTimeInMins),
      recipeTotalTimeInMins: recipeTotalTimeInMins == null ? const Value.absent() : Value(recipeTotalTimeInMins),
      recipeServings: recipeServings == null ? const Value.absent() : Value(recipeServings),
      recipeCuisine: recipeCuisine == null ? const Value.absent() : Value(recipeCuisine),
      recipeCourse: recipeCourse == null ? const Value.absent() : Value(recipeCourse),
      recipeDiet: recipeDiet == null ? const Value.absent() : Value(recipeDiet),
      recipeOriginalInstructions: recipeOriginalInstructions == null ? const Value.absent() : Value(recipeOriginalInstructions),
      recipeTranslatedInstructions: recipeTranslatedInstructions == null ? const Value.absent() : Value(recipeTranslatedInstructions),
      recipeReferenceUrl: recipeReferenceUrl == null ? const Value.absent() : Value(recipeReferenceUrl),
      isBookmark: isBookmark == null ? const Value.absent() : Value(isBookmark),
    );
  }

  Map<String, dynamic> toJson() => {
    'recipe_id': recipeId,
    'id': id,
    'recipe_original_name': recipeOriginalName,
    'translated_recipe_name': translatedRecipeName,
    'recipe_original_ingredients': recipeOriginalIngredients,
    'recipe_translated_ingredients': recipeTranslatedIngredients,
    'recipe_translated_ingredient_list': recipeTranslatedIngredientList?.split(','),
    'recipe_preparation_time_in_mins': recipePreparationTimeInMins,
    'recipe_cooking_time_in_mins': recipeCookingTimeInMins,
    'recipe_total_time_in_mins': recipeTotalTimeInMins,
    'recipe_servings': recipeServings,
    'recipe_cuisine': recipeCuisine,
    'recipe_course': recipeCourse,
    'recipe_diet': recipeDiet,
    'recipe_original_instructions': recipeOriginalInstructions,
    'recipe_translated_instructions': recipeTranslatedInstructions,
    'recipe_reference_url': recipeReferenceUrl,
    'isBookmark': isBookmark == true ? 1 : 0,
    'images': images?.map((e) => {
      'id': e.id,
      'recipe_id': e.recipeId,
      'file_name': e.fileName,
      'base64_data': e.base64Data,
    }).toList(),
  }..removeWhere((key, value) => value == null);
}
