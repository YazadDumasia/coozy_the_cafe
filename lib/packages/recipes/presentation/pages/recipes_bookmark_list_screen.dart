import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_bookmark_list_cubit.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/recipe_bookmark_empty_view.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/widgets/recipe_bookmark_list_item.dart';

class RecipesBookmarkListScreen extends StatefulWidget {
  const RecipesBookmarkListScreen({super.key});

  @override
  State<RecipesBookmarkListScreen> createState() =>
      _RecipesBookmarkListScreenState();
}

class _RecipesBookmarkListScreenState extends State<RecipesBookmarkListScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<RecipesBookmarkListCubit>(context).loadData();
      }
    });
  }

  @override
  void dispose() {
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
                    shared.LocaleKeys.recipesBookmarksTitle,
                    track: shared.TrackConstants.recipesTrack,
                  ) ??
                  'Recipe Bookmarks',
            ),
          ),
          body:
              BlocConsumer<RecipesBookmarkListCubit, RecipesBookmarkListState>(
                listener: (context, state) {},
                builder: (context, state) {
                  if (state is RecipesBookmarkListInitialState ||
                      state is RecipesBookmarkListLoadingState) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[Expanded(child: shared.LoadingPage())],
                    );
                  } else if (state is RecipesBookmarkListLoadedState) {
                    return Visibility(
                      visible: (state.data == null || state.data!.isEmpty)
                          ? false
                          : true,
                      replacement: const RecipeBookmarkEmptyView(),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
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
                                  final Recipe model = state.data![index];
                                  return RepaintBoundary(
                                    child: RecipeBookmarkListItem(
                                      model: model,
                                      index: index,
                                    ),
                                  );
                                },
                                addSemanticIndexes: true,
                                addAutomaticKeepAlives: true,
                                addRepaintBoundaries: false,
                                childCount: state.data?.length ?? 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is RecipesBookmarkListErrorState) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: shared.ErrorPage(
                            onPressedRetryButton: () async {
                              if (mounted) {
                                BlocProvider.of<RecipesBookmarkListCubit>(
                                  context,
                                ).loadData();
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is RecipesBookmarkListNoInternetState) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: shared.NoInternetPage(
                            onPressedRetryButton: () async {
                              if (mounted) {
                                BlocProvider.of<RecipesBookmarkListCubit>(
                                  context,
                                ).loadData();
                              }
                            },
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
