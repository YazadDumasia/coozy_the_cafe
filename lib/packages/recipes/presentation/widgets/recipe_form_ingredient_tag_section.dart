import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class RecipeFormIngredientTagSection extends StatelessWidget {
  final List<String> ingredientTags;
  final TextEditingController tagInputController;
  final FocusNode tagFocusNode;
  final VoidCallback onAddTag;
  final Function(int) onRemoveTag;

  const RecipeFormIngredientTagSection({
    super.key,
    required this.ingredientTags,
    required this.tagInputController,
    required this.tagFocusNode,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredient Tags (for filter)',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Clean ingredient names used to power the ingredient filter.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        // Existing tags as chips
        if (ingredientTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: List.generate(ingredientTags.length, (index) {
              return InputChip(
                label: Text(ingredientTags[index]),
                onDeleted: () => onRemoveTag(index),
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: colorScheme.secondaryContainer,
                labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        const SizedBox(height: 8),
        // Input row to add new tag
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: tagInputController,
                focusNode: tagFocusNode,
                decoration: InputDecoration(
                  hintText:
                      context.tr(
                        shared.LocaleKeys.egOnionHint,
                        track: shared.TrackConstants.recipesTrack,
                      ) ??
                      'e.g. Onion',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => onAddTag(),
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onAddTag,
              icon: const Icon(Icons.add),
              tooltip:
                  context.tr(
                    shared.LocaleKeys.addIngredientTagTooltip,
                    track: shared.TrackConstants.staffManagementPageTrack,
                  ) ??
                  'Add ingredient tag',
            ),
          ],
        ),
      ],
    );
  }
}
