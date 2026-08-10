import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class RecipeBookmarkEmptyView extends StatelessWidget {
  const RecipeBookmarkEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Icon(
          shared.MenuIcons.recipeBookmark,
          size: 120,
          color: Theme.of(context).colorScheme.primary,
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 0,
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Text(
                  context.tr(
                        shared.LocaleKeys.recipesBookmarkNoRecordTitle,
                        track: shared.TrackConstants.recipesTrack,
                      ) ??
                      'No data founded',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Text(
                  context.tr(
                        shared.LocaleKeys.recipesBookmarkNoRecordSubTitle,
                        track: shared.TrackConstants.recipesTrack,
                      ) ??
                      'Please try to add some new bookmarks from recipes list.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
