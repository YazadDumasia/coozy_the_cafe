import 'package:flutter/material.dart';

import '../coozy_shared.dart';

class EmptyCategoryFullListBody extends StatelessWidget {
  const EmptyCategoryFullListBody({this.onAddNewCategory, super.key});

  final VoidCallback? onAddNewCategory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              MenuIcons.menuPlaceholder,
              color: Theme.of(context).primaryColor,
              size: 110,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    'No Category been inserted',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
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
      ),
    );
  }
}
