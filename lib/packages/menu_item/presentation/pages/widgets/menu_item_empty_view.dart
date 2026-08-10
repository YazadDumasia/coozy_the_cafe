import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class MenuItemEmptyView extends StatelessWidget {
  const MenuItemEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            shared.MenuSearchIcons.fillOrderAddBtn,
            color: Theme.of(context).colorScheme.primary,
            size: 150,
          ),

          const SizedBox(height: 12),
          Text(
            context.tr(
                  shared.LocaleKeys.menuItemPageNoMenuDishesFound,
                  track: shared.TrackConstants.menuItemPageTrack,
                ) ??
                'No menu dishes found.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ).inExpandedRow(),
        ],
      ),
    );
  }
}
