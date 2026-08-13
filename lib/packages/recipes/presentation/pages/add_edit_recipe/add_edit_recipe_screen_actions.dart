import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/usecases/recipes_usecases.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AddEditRecipeScreenActions {
  static Future<List<RecipeImageEntity>?> pickImages(
    BuildContext context,
    ImagePicker picker,
  ) async {
    bool isDialogShowing = false;
    try {
      final List<XFile> pickedFiles = await picker.pickMultiImage(
        imageQuality: 100,
        limit: 6,
      );
      if (pickedFiles.isNotEmpty) {
        if (context.mounted) {
          shared.DialogUtils.showSimpleLoadingDialog(
            context,
            "Processing images...",
          );
          isDialogShowing = true;
        }

        List<RecipeImageEntity> processedImages = [];
        for (var file in pickedFiles) {
          final bytes = await file.readAsBytes();

          // Compress the image
          var compressedBytes = await FlutterImageCompress.compressWithList(
            bytes,
            minHeight: 1080,
            minWidth: 1080,
            quality: 80,
          );

          final base64Image = base64Encode(compressedBytes);
          processedImages.add(
            RecipeImageEntity(fileName: file.name, base64Data: base64Image),
          );
        }

        if (context.mounted) {
          if (isDialogShowing) {
            Navigator.pop(context); // Dismiss loading dialog
          }
          return processedImages;
        }
      }
    } catch (e) {
      if (context.mounted && isDialogShowing) {
        Navigator.pop(context); // Dismiss loading dialog on error
      }
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  static Future<void> saveRecipe({
    required BuildContext context,
    required bool isEdit,
    required Recipe recipeData,
  }) async {
    try {
      if (isEdit) {
        await GetIt.instance<UpdateRecipeUseCase>().call(recipeData);
        if (context.mounted) {
          shared.DialogUtils.showAutoDismissDialog(
            context: context,
            title:
                context.tr(
                  shared.LocaleKeys.recipesFormSuccessTitle,
                  track: shared.TrackConstants.recipesTrack,
                ) ??
                'Success',
            descriptions:
                context.tr(
                  shared.LocaleKeys.recipesFormUpdateSuccessMsg,
                  track: shared.TrackConstants.recipesTrack,
                ) ??
                'Recipe updated successfully.',
            titleIcon: Lottie.asset(
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Assets.lottie.doneLightBrownColor
                  : Assets.lottie.doneBrownColor,
              repeat: false,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await GetIt.instance<AddRecipeUseCase>().call(recipeData);
        if (context.mounted) {
          shared.DialogUtils.showAutoDismissDialog(
            context: context,
            title:
                context.tr(
                  shared.LocaleKeys.recipesFormSuccessTitle,
                  track: shared.TrackConstants.recipesTrack,
                ) ??
                'Success',
            descriptions:
                context.tr(
                  shared.LocaleKeys.recipesFormAddSuccessMsg,
                  track: shared.TrackConstants.recipesTrack,
                ) ??
                'Recipe added successfully.',
            titleIcon: Lottie.asset(
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Assets.lottie.doneLightBrownColor
                  : Assets.lottie.doneBrownColor,
              repeat: false,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      core.PlatformUtils.debugLog(
        AddEditRecipeScreenActions,
        'saveRecipe:onError: $e',
      );
      if (context.mounted) {
        shared.DialogUtils.showAutoDismissDialog(
          context: context,
          title:
              context.tr(
                shared.LocaleKeys.recipesFormErrorTitle,
                track: shared.TrackConstants.recipesTrack,
              ) ??
              'Error',
          descriptions:
              context.tr(
                shared.LocaleKeys.recipesFormSaveFailMsg,
                params: {'error': e.toString()},
                track: shared.TrackConstants.recipesTrack,
              ) ??
              'Failed to save recipe: $e',
          titleIcon: Lottie.asset(
            MediaQuery.of(context).platformBrightness == Brightness.light
                ? Assets.lottie.errorLightLoaderIcon
                : Assets.lottie.errorDarkLoaderIcon,
            repeat: false,
          ),
        );
      }
    }
  }
}
