import 'package:flutter/material.dart';

import '../coozy_shared.dart';

class EmptyCategoryFullListBody extends StatelessWidget {
  const EmptyCategoryFullListBody({this.onAddNewCategory, super.key});

  final VoidCallback? onAddNewCategory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            MenuIcons.menuPlaceholder,
            color: Theme.of(context).colorScheme.primary,
            size: 150,
          ),

          Text(
            context.tr(
                  LocaleKeys.menuCategoryEmptyTitleText,
                  track: TrackConstants.menuCategoryPageTrack,
                ) ??
                'No Categories found.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ).inExpandedRow().paddingSymmetric(vertical: 10.0),

          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: onAddNewCategory,
                style: ElevatedButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    right: 25,
                    left: 25,
                  ),
                  elevation: 5,
                ),

                child: Text(
                  context.tr(
                        LocaleKeys.menuCategoryAddNewCategory,
                        track: TrackConstants.menuCategoryPageTrack,
                      ) ??
                      'Add new category',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
