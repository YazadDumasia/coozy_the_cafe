import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';

class RecipeFormImagePickerSection extends StatelessWidget {
  final List<RecipeImageEntity> selectedImages;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;

  const RecipeFormImagePickerSection({
    super.key,
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Images', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...selectedImages.asMap().entries.map((entry) {
              int index = entry.key;
              RecipeImageEntity img = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: MemoryImage(base64Decode(img.base64Data)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: InkWell(
                      onTap: () => onRemoveImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              );
            }),
            InkWell(
              onTap: onPickImages,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 40, color: Colors.grey),
                    SizedBox(height: 5),
                    Text('Image', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
