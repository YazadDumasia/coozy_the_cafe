import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../pages/recipes_list/recipes_list_screen_actions.dart';

class RecipeSearchFilterHeader extends StatelessWidget {
  final TextEditingController searchController;

  const RecipeSearchFilterHeader({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 5.0,
                    right: 10,
                    top: 5,
                    bottom: 5,
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText:
                          context.tr(
                            shared.LocaleKeys.recipesSearchHint,
                            track: shared.TrackConstants.recipesTrack,
                          ) ??
                          'Recipe name',
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: searchController,
                        builder: (context, value, child) {
                          return value.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      RecipesListScreenActions.onSearchCleared(
                                        context,
                                        searchController,
                                      ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                    onChanged: (value) {},
                    onSubmitted: (value) =>
                        RecipesListScreenActions.onSearchSubmitted(
                          context,
                          value,
                        ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async =>
                    RecipesListScreenActions.showFilterView(context),
                icon: const Icon(Icons.filter_list, size: 24),
                label: Text(
                  context.tr(
                        shared.LocaleKeys.commonFilter,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Filter',
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
