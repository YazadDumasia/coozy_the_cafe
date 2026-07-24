import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_event.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/bloc/menu_subcategory_state.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/models/suspension_menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/presentation/pages/widgets/menu_subcategory_list_item.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu_subcategory_full_list_screen_actions.dart';

class MenuSubcategoryFullListScreen extends StatefulWidget {
  const MenuSubcategoryFullListScreen({super.key});

  @override
  State<MenuSubcategoryFullListScreen> createState() =>
      _MenuSubcategoryFullListScreenState();
}

class _MenuSubcategoryFullListScreenState
    extends State<MenuSubcategoryFullListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<SuspensionMenuSubcategory> _suspensionList = [];
  List<MenuCategory> categories = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuSubcategoryBloc>().add(LoadMenuSubcategories());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubcategories(List<MenuSubcategory> subcategories) {
    var filtered = subcategories;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (element) =>
                element.name?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ??
                false,
          )
          .toList();
    }
    _suspensionList = filtered
        .map((e) => SuspensionMenuSubcategory(e))
        .toList();
    SuspensionUtil.sortListBySuspensionTag(_suspensionList);
    SuspensionUtil.setShowSuspensionStatus(_suspensionList);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
                  shared.LocaleKeys.menuSubCategoryAppbarTitle,
                  track: shared.TrackConstants.menuSubCategoryPageTrack,
                ) ??
                'All Subcategories',
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  MenuSubcategoryFullListScreenActions.handleAddSubcategory(
                    context,
                    mounted,
                  ),
              icon: const Icon(Icons.add),
              tooltip: 'Add new subcategory',
            ),
          ],
        ),
        body: BlocConsumer<MenuSubcategoryBloc, MenuSubcategoryState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is MenuSubcategoryLoading ||
                state is MenuSubcategoryInitial) {
              return const shared.LoadingPage();
            } else if (state is MenuSubcategoryLoaded) {
              _filterSubcategories(state.subcategories);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildSearchField(context),
                  Expanded(child: _buildSubCategoryList(state)),
                ],
              );
            } else if (state is MenuSubcategoryError) {
              core.PlatformUtils.debugLog(
                MenuSubcategoryFullListScreen,
                'MenuSubCategoryErrorState:error:${state.message}',
              );
              return shared.ErrorPage(
                onPressedRetryButton: () async {
                  context.read<MenuSubcategoryBloc>().add(
                    LoadMenuSubcategories(),
                  );
                },
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Row _buildSearchField(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search Subcategories',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryList(MenuSubcategoryLoaded state) {
    return Visibility(
      visible: _suspensionList.isNotEmpty,
      replacement: Visibility(
        visible: _searchQuery.isNotEmpty,
        replacement: _buildEmptyState(),
        child: _buildNoSearchData(),
      ),
      child: AzListView(
        data: _suspensionList,
        itemCount: _suspensionList.length,
        padding: const EdgeInsets.only(right: 40),
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        indexBarOptions: IndexBarOptions(
          needRebuild: true,
          color: Colors.grey.shade300,
          downColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          indexHintWidth: 50.0,
        ),
        indexHintBuilder: (BuildContext context, String hint) {
          return Container(
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Text(
              hint.toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.displaySmall!.copyWith(color: Colors.white),
            ),
          );
        },
        itemBuilder: (context, index) {
          final suspensionItem = _suspensionList[index];
          final MenuSubcategory subCategory = suspensionItem.subcategory;

          return _itemView(index, state, subCategory, context);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.dashboard_customize_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 110,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'No data has been inserted.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Please insert sub-category from menu category screen or you can add it from below button.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () =>
                        MenuSubcategoryFullListScreenActions.handleAddSubcategory(
                          context,
                          mounted,
                        ),
                    style: ElevatedButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        right: 25,
                        left: 25,
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.addMenuSubCategoryBtnText,
                            track:
                                shared.TrackConstants.menuSubCategoryPageTrack,
                          ) ??
                          'Add new subcategory',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoSearchData() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.search_off,
                color: Theme.of(context).primaryColor,
                size: 100,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.commonNoSearchResultFoundMsg,
                            track:
                                shared.TrackConstants.menuSubCategoryPageTrack,
                          ) ??
                          'No data Found.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _itemView(
    int index,
    MenuSubcategoryLoaded state,
    MenuSubcategory subCategory,
    BuildContext context,
  ) {
    return MenuSubcategoryListItem(
      subCategory: subCategory,
      isLastItem: index == (_suspensionList.length - 1),
    );
  }
}
