import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class SubcategoryEmptyView extends StatelessWidget {
  final VoidCallback onAddSubcategory;

  const SubcategoryEmptyView({super.key, required this.onAddSubcategory});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            shared.MenuIcons.menuEmptyPlaceholder,
            color: Theme.of(context).colorScheme.primary,
            size: 110,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr(
                  shared.LocaleKeys.noSubcategoriesFound,
                  track: shared.TrackConstants.menuSubCategoryPageTrack,
                ) ??
                'No subcategories found.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ).inExpandedRow(),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onAddSubcategory,
            icon: const Icon(Icons.add),
            label: Text(
              context.tr(
                    shared.LocaleKeys.addMenuSubCategoryBtnText,
                    track: shared.TrackConstants.menuCategoryPageTrack,
                  ) ??
                  'Add Subcategory',
            ),
          ),
        ],
      ),
    );
  }
}
