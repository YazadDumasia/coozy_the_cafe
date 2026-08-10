import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class RecipeEmptyView extends StatelessWidget {
  const RecipeEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            shared.MenuIcons.recipe,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.recipesListScreenNoDataTitleMsg,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'No data founded',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.recipesListScreenNoDataSubTitleMsg,
                          track: shared.TrackConstants.recipesTrack,
                        ) ??
                        'Please try again with different filter choices to pick from.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
