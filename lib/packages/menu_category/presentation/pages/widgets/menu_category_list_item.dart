import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart' as slided;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_category/domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/menu_subcategory/domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/pages/menu_sub_category_expansion_child_listview_widget.dart';
import '../menu_category_full_list_screen_actions.dart';

class MenuCategoryListItem extends StatelessWidget {
  final MenuCategoryFullListLoadedState state;
  final int index;
  final int totalItemLength;
  final dynamic model;

  const MenuCategoryListItem({
    super.key,
    required this.state,
    required this.index,
    required this.totalItemLength,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic rawActive = model['isActive'];
    bool? isActiveBool;
    if (rawActive is bool) {
      isActiveBool = rawActive;
    } else if (rawActive is num) {
      isActiveBool = rawActive == 1;
    }

    final MenuCategory category = MenuCategory(
      id: model['id'] as int?,
      hashId: model['hashId'] as String?,
      createdDate: model['createdDate'] as String?,
      isActive: isActiveBool,
      position: model['position'] as int?,
      name: model['name'] as String?,
    );

    final List<dynamic>? dynamicSubCategories =
        model['subCategories'] as List<dynamic>?;

    final List<MenuSubcategory> subCategoryList = (dynamicSubCategories as List)
        .map(
          (e) => MenuSubcategory.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    final ThemeData theme = Theme.of(context);
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

    return Theme(
      key: ValueKey('$index'),
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: Padding(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          top: 10,
          bottom: (index < totalItemLength - 1) ? 0 : 10,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: slided.Slidable(
            closeOnScroll: true,
            endActionPane: slided.ActionPane(
              motion: const slided.DrawerMotion(),
              children: <Widget>[
                slided.SlidableAction(
                  onPressed: (BuildContext editContext) =>
                      MenuCategoryFullListScreenActions.handleEditCategory(
                        context,
                        category,
                      ),
                  backgroundColor: Colors.lightBlueAccent,
                  foregroundColor: Colors.white,
                  autoClose: true,
                  icon: Icons.edit_outlined,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  label:
                      context.tr(
                        shared.LocaleKeys.commonEdit,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Edit',
                ),
                slided.SlidableAction(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  autoClose: true,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                  ),
                  icon: Icons.delete,
                  label:
                      context.tr(
                        shared.LocaleKeys.commonDelete,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Delete',
                  onPressed: (BuildContext ctx) =>
                      MenuCategoryFullListScreenActions.handleDeleteCategory(
                        context,
                        category,
                      ),
                ),
              ],
            ),
            child: ListTileTheme(
              contentPadding: const EdgeInsets.all(0),
              dense: true,
              horizontalTitleGap: 0.0,
              minLeadingWidth: 0,
              minVerticalPadding: 0,
              child: ExpansionTile(
                controller: state.expandedTitleControllerList?[index],
                tilePadding: EdgeInsets.zero,
                minTileHeight: 0,
                shape: const Border(),
                collapsedShape: const Border(),
                key: state.expansionTileKeys![index] ?? GlobalKey(),
                maintainState: true,
                visualDensity: VisualDensity.compact,
                collapsedBackgroundColor: theme.colorScheme.primaryContainer,
                backgroundColor: theme.colorScheme.primaryContainer,
                title: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(child: Text(category.name ?? '')),
                    ],
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 0,
                    bottom: 0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                              text:
                                  context.tr(
                                    shared
                                        .LocaleKeys
                                        .menuCategoryFullListEnableStatusText,
                                    track: shared
                                        .TrackConstants
                                        .menuCategoryPageTrack,
                                  ) ??
                                  'Enable Status:',
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: <InlineSpan>[
                                const TextSpan(text: ' '),
                                TextSpan(
                                  text: (category.isActive ?? false)
                                      ? context.tr(
                                              shared.LocaleKeys.commonActive,
                                              track: shared
                                                  .TrackConstants
                                                  .commonTrack,
                                            ) ??
                                            'Active'
                                      : context.tr(
                                              shared.LocaleKeys.commonInactive,
                                              track: shared
                                                  .TrackConstants
                                                  .commonTrack,
                                            ) ??
                                            'Inactive',
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        color: (category.isActive ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[Expanded(child: Text(''))],
                      ),
                    ],
                  ),
                ),
                trailing: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Visibility(
                          visible: index == 0 ? false : true,
                          child: IconButton(
                            onPressed: () async {
                              BlocProvider.of<MenuCategoryFullListCubit>(
                                context,
                              ).moveCategoryUp(
                                index,
                                onError: (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .commonErrorMsg,
                                                track: shared
                                                    .TrackConstants
                                                    .commonTrack,
                                              ) ??
                                              'Failed to reorder categories.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                            icon: const Icon(Icons.keyboard_arrow_up),
                          ),
                        ),
                        Visibility(
                          visible: index < (totalItemLength - 1),
                          child: Padding(
                            padding: index == 0
                                ? const EdgeInsets.all(0.0)
                                : const EdgeInsets.only(top: 5.0),
                            child: IconButton(
                              onPressed: () async {
                                BlocProvider.of<MenuCategoryFullListCubit>(
                                  context,
                                ).moveCategoryDown(
                                  index,
                                  onError: (error) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            context.tr(
                                                  shared
                                                      .LocaleKeys
                                                      .commonErrorMsg,
                                                  track: shared
                                                      .TrackConstants
                                                      .commonTrack,
                                                ) ??
                                                'Failed to reorder categories.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                              icon: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 30,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch.adaptive(
                            value: category.isActive == true,
                            onChanged: (bool isEnable) =>
                                MenuCategoryFullListScreenActions.handleToggleCategory(
                                  context,
                                  category,
                                  isEnable,
                                ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            thumbIcon: thumbIcon,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                children: <Widget>[
                  Visibility(
                    visible: subCategoryList.isNotEmpty,
                    child: shared.ResponsiveLayout(
                      mobile: MenuSubCategoryExpansionChildListViewWidget(
                        key: UniqueKey(),
                        subCategoryList: subCategoryList,
                        itemsToShow: 4,
                      ),
                      tablet: MenuSubCategoryExpansionChildListViewWidget(
                        key: UniqueKey(),
                        subCategoryList: subCategoryList,
                        itemsToShow: 6,
                      ),
                      desktop: MenuSubCategoryExpansionChildListViewWidget(
                        key: UniqueKey(),
                        subCategoryList: subCategoryList,
                        itemsToShow: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
