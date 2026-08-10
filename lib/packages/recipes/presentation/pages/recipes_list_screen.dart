import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/recipes/presentation/pages/recipes_list_screen_actions.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/recipe_empty_view.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/recipe_list_item.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/recipe_search_filter_header.dart';

class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({super.key});

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: '');
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<RecipesFullListCubit>(context).loadData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              context.tr(
                    shared.LocaleKeys.recipesTitle,
                    track: shared.TrackConstants.recipesTrack,
                  ) ??
                  'Recipes',
            ),
            actions: <Widget>[
              IconButton(
                tooltip:
                    context.tr(
                      shared.LocaleKeys.recipesAddCustomTooltip,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Add Custom Recipe',
                onPressed: () =>
                    RecipesListScreenActions.onAddRecipePressed(context),
                icon: const Icon(Icons.add),
              ),
              IconButton(
                tooltip:
                    context.tr(
                      shared.LocaleKeys.recipesBookmarksTitle,
                      track: shared.TrackConstants.recipesTrack,
                    ) ??
                    'Bookmarks',
                onPressed: () =>
                    RecipesListScreenActions.onBookmarksPressed(context),
                icon: const Icon(Icons.bookmarks),
              ),
            ],
          ),
          body: BlocConsumer<RecipesFullListCubit, RecipesFullListState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is RecipesInitialState ||
                  state is RecipesLoadingState) {
                double? progress = (state is RecipesLoadingState)
                    ? state.progress
                    : null;
                int? currentProgress = (state is RecipesLoadingState)
                    ? state.currentProgress
                    : null;
                int? totalProgress = (state is RecipesLoadingState)
                    ? state.totalProgress
                    : null;
                String? message = (state is RecipesLoadingState)
                    ? state.message
                    : null;

                String? displayMessage;
                if (currentProgress != null && totalProgress != null) {
                  displayMessage = context.tr(
                    shared.LocaleKeys.recipesLoadingProgressMsg,
                    params: {'progress': '$currentProgress/$totalProgress'},
                    track: shared.TrackConstants.recipesTrack,
                  );
                } else {
                  displayMessage = message;
                }

                if (progress != null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 280,
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                if (displayMessage != null &&
                                    displayMessage.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    displayMessage,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[Expanded(child: shared.LoadingPage())],
                );
              } else if (state is RecipesLoadedState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    RecipeSearchFilterHeader(
                      searchController: _searchController,
                    ),
                    Expanded(
                      child: Visibility(
                        visible:
                            state.isInternalLoading == null ||
                            state.isInternalLoading == false,
                        replacement: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(child: shared.LoadingPage()),
                          ],
                        ),
                        child: Visibility(
                          visible:
                              (state.totalPages == null ||
                                  state.totalPages == 0)
                              ? false
                              : true,
                          replacement: const RecipeEmptyView(),
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            interactive: true,
                            radius: const Radius.circular(10.0),
                            child: CustomScrollView(
                              controller: _scrollController,
                              physics: const ClampingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              shrinkWrap: true,
                              slivers: <Widget>[
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final Recipe model =
                                          state.paginatedData![index];
                                      return RecipeListItem(
                                        state: state,
                                        model: model,
                                        index: index,
                                      );
                                    },
                                    addSemanticIndexes: true,
                                    addAutomaticKeepAlives: true,
                                    addRepaintBoundaries: false,
                                    childCount:
                                        state.paginatedData?.length ?? 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if ((state.totalPages == null || state.totalPages == 0)
                        ? false
                        : true)
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Column(
                          children: <Widget>[
                            shared.Pager(
                              currentItemsPerPage: state.itemsPerPage ?? 10,
                              currentPage: state.currentPage ?? 1,
                              totalPages: state.totalPages ?? 1,
                              pagesView:
                                  shared.ResponsiveLayout.isDesktop(context)
                                  ? 10
                                  : shared.ResponsiveLayout.isTablet(context)
                                  ? 5
                                  : 3,
                              numberButtonSelectedColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              numberTextSelectedColor: Colors.white,
                              numberTextUnselectedColor: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color!,
                              onPageChanged: (nextPage) =>
                                  RecipesListScreenActions.onPageChanged(
                                    context,
                                    nextPage,
                                  ),
                              showItemsPerPage: true,
                              onItemsPerPageChanged: (itemsPerPage) =>
                                  RecipesListScreenActions.onItemsPerPageChanged(
                                    context,
                                    itemsPerPage,
                                  ),
                              itemsPerPageList:
                                  state.itemsPerPageList ??
                                  const <int>[10, 20, 30, 40, 50, 100],
                              itemsPerPageAlignment: Alignment.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              } else if (state is RecipesErrorState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: shared.ErrorPage(
                        onPressedRetryButton: () =>
                            RecipesListScreenActions.onRetryPressed(context),
                      ),
                    ),
                  ],
                );
              } else if (state is NoInternetRecipesState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: shared.NoInternetPage(
                        onPressedRetryButton: () =>
                            RecipesListScreenActions.onRetryPressed(context),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
