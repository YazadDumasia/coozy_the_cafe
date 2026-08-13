import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';

import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart' as slided;
import 'menu_category_full_list_screen_actions.dart';
import 'widgets/menu_category_list_item.dart';

class MenuCategoryFullListScreen extends StatefulWidget {
  const MenuCategoryFullListScreen({super.key});

  @override
  State<MenuCategoryFullListScreen> createState() =>
      _MenuCategoryFullListScreenState();
}

class _MenuCategoryFullListScreenState
    extends State<MenuCategoryFullListScreen> {
  ScrollController? _controller = ScrollController();
  FocusNode? searchAnchorFocusNode = FocusNode();
  String? searchQuery = '';
  SearchController? searchController = SearchController();

  bool positive = false;
  final WidgetStateProperty<Icon?> thumbIcon =
      WidgetStateProperty.resolveWith<Icon>((Set<WidgetState> states) {
        if (states.containsAll(<Object?>[
          WidgetState.disabled,
          WidgetState.selected,
        ])) {
          return const Icon(Icons.check, color: Colors.red);
        }

        if (states.contains(WidgetState.disabled)) {
          return const Icon(Icons.close);
        }

        if (states.contains(WidgetState.selected)) {
          return const Icon(Icons.check, color: Colors.green);
        }

        return const Icon(Icons.close);
      });

  // TextEditingController? searchController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    searchController = SearchController();
    searchAnchorFocusNode = FocusNode();
    searchQuery = '';
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<MenuCategoryFullListCubit>(context).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && context.mounted) {
            Navigator.pop(context, result);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              context.tr(
                    shared.LocaleKeys.menuCategoryAppbarTitle,
                    track: shared.TrackConstants.menuCategoryPageTrack,
                  ) ??
                  'Menu Category',
            ),
            centerTitle: false,
            actions: <Widget>[
              IconButton(
                onPressed: () =>
                    MenuCategoryFullListScreenActions.handleNewCategory(
                      context,
                    ),
                icon: const Icon(Icons.add),
                tooltip:
                    context.tr(
                      shared.LocaleKeys.addMenuCategoryIconTooltipText,
                      track: shared.TrackConstants.menuCategoryPageTrack,
                    ) ??
                    'Add a new menu category',
              ),
            ],
          ),
          body:
              BlocConsumer<
                MenuCategoryFullListCubit,
                MenuCategoryFullListState
              >(
                listener: (context, state) {
                  if (state is MenuCategoryFullListErrorState) {
                    shared.DialogUtils.showAutoDismissDialog(
                      context: context,
                      title:
                          context.tr(
                            shared.LocaleKeys.commonError,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Error',
                      descriptions: state.message,
                      titleIcon: const Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 50,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is MenuCategoryFullListInitialState) {
                    return const shared.LoadingPage();
                  } else if (state is MenuCategoryFullListLoadingState) {
                    return const shared.LoadingPage();
                  } else if (state is MenuCategoryFullListLoadedState) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        searchBarWithSuggestionWidget(context, state),
                        Expanded(child: menuItemWidget(state)),
                      ],
                    );
                  } else {
                    return shared.ErrorPage(
                      key: UniqueKey(),
                      onPressedRetryButton: () async =>
                          BlocProvider.of<MenuCategoryFullListCubit>(
                            context,
                          ).loadData(),
                    );
                  }
                },
              ),
        ),
      ),
    );
  }

  Widget searchBarWithSuggestionWidget(
    BuildContext context,
    MenuCategoryFullListLoadedState state,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: SearchAnchor(
              searchController: searchController,
              builder: (BuildContext context, SearchController controller) {
                return Theme(
                  data: Theme.of(context),
                  child: SearchBar(
                    controller: controller,
                    focusNode: searchAnchorFocusNode,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (value) {
                      core.PlatformUtils.debugLog(
                        MenuCategoryFullListScreen,
                        'SearchAnchor:onChanged:$value',
                      );
                      if (!controller.isOpen) {
                        controller.openView();
                      }
                    },
                    onSubmitted: (value) {
                      core.PlatformUtils.debugLog(
                        MenuCategoryFullListScreen,
                        'SearchAnchor:onSubmitted:$value',
                      );
                      scrollToItemAndExpand(value);
                    },
                    leading: const Icon(Icons.search),
                  ),
                );
              },
              isFullScreen: false,
              viewConstraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .35 < 220
                    ? 220
                    : MediaQuery.of(context).size.height * .35 > 220
                    ? 250
                    : MediaQuery.of(context).size.height * .35,
              ),
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                    List<String> suggestions = <String>[];
                    if (state.data != null &&
                        state.data!.isNotEmpty &&
                        state.data!.containsKey('categories') &&
                        state.data!['categories'] != null) {
                      state.data!['categories'].forEach((category) {
                        suggestions.add(category['name'].toString());

                        if (category['subCategories'] != null) {
                          suggestions.addAll(
                            (category['subCategories'] as List<dynamic>).map(
                              (subCategory) => subCategory['name'].toString(),
                            ),
                          );
                        }
                      });
                    } else {
                      suggestions = <String>[];
                    }
                    final List<Widget> suggestionWidgets = suggestions
                        .where(
                          (suggestion) => suggestion.toLowerCase().contains(
                            controller.value.text.toLowerCase(),
                          ),
                        )
                        .map(
                          (suggestion) => ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              controller.closeView(suggestion);
                              scrollToItemAndExpand(suggestion);
                            },
                          ),
                        )
                        .toList();
                    return suggestionWidgets.isEmpty
                        ? <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      context.tr(
                                            shared
                                                .LocaleKeys
                                                .menuCategorySearchNoSuggestions,
                                            track: shared
                                                .TrackConstants
                                                .menuCategoryPageTrack,
                                          ) ??
                                          'No suggestions',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]
                        : suggestionWidgets;
                  },
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBarWidget(
    BuildContext context,
    MenuCategoryFullListLoadedState state,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: SearchBar(
              focusNode: searchAnchorFocusNode,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 10.0),
              ),
              onChanged: (value) {
                core.PlatformUtils.debugLog(
                  MenuCategoryFullListScreen,
                  'SearchBar:onChanged:$value',
                );
                scrollToItemAndExpand(value);
              },
              onSubmitted: (value) {
                core.PlatformUtils.debugLog(
                  MenuCategoryFullListScreen,
                  'SearchBar:onSubmitted:$value',
                );
                scrollToItemAndExpand(value);
              },
              leading: const Icon(Icons.search),
            ),
          ),
        ],
      ),
    );
  }

  // menuItemWidget(result!["categories"]) ,
  Widget menuItemWidget(MenuCategoryFullListLoadedState state) {
    final map = state.data?['categories'];
    if (map != null && map.isNotEmpty) {
      return CustomScrollView(
        key: ValueKey('category_scroll_view_${map.hashCode}_${map.length}'),
        shrinkWrap: true,
        controller: _controller,
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: <Widget>[
          slided.SlidableAutoCloseBehavior(
            child: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = map![index];
                  return menuCategoryExpansionTileItem(
                    state: state,
                    model: category,
                    index: index,
                    totalItemLength: map?.length ?? 0,
                  );
                },
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                childCount: map?.length ?? 0,
              ),
            ),
          ),
        ],
      );
    } else {
      return shared.EmptyCategoryFullListBody(
        onAddNewCategory: handleNewCategory,
      );
    }
  }

  Widget menuCategoryExpansionTileItem({
    required MenuCategoryFullListLoadedState state,
    required int index,
    required int totalItemLength,
    dynamic model,
  }) {
    final catId = (model is Map) ? model['id'] : null;
    return MenuCategoryListItem(
      key: ValueKey(catId ?? index),
      state: state,
      index: index,
      totalItemLength: totalItemLength,
      model: model,
    );
  }

  void scrollToItemAndExpand(String keyword) {
    MenuCategoryFullListScreenActions.scrollToItemAndExpand(
      context: context,
      keyword: keyword,
      scrollController: _controller!,
      searchController: searchController!,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> handleNewCategory() async {
    await MenuCategoryFullListScreenActions.handleNewCategory(context);
  }
}
