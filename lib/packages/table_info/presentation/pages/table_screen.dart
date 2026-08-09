import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'table_screen_actions.dart';
import 'widgets/table_grid_item.dart';
import 'widgets/table_list_item.dart';

import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import 'package:coozy_the_cafe/packages/table_info/domain/entities/table_info.dart';
import 'package:coozy_the_cafe/packages/table_info/presentation/cubit/table_cubit.dart';
import 'package:coozy_the_cafe/packages/table_info/presentation/cubit/table_state.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TableCubit>().loadTables();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        canPop: true,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(
              context.tr(
                    shared.LocaleKeys.tableInfoAppBarTitle,
                    track: shared.TrackConstants.tablePageTrack,
                  ) ??
                  'Table Info',
            ),
            actions: <Widget>[
              BlocBuilder<TableCubit, TableState>(
                builder: (context, state) {
                  if (state is TableLoaded) {
                    return IconButton(
                      onPressed: () async =>
                          TableScreenActions.onToggleView(context, state),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: state.isGridView
                            ? Icon(Icons.list, key: ValueKey('list'))
                            : Icon(Icons.grid_view, key: ValueKey('grid')),
                      ),
                      tooltip: state.isGridView
                          ? (context.tr(
                                  shared.LocaleKeys.commonListViewTooltip,
                                  track: shared.TrackConstants.commonTrack,
                                ) ??
                                'Switch to List View')
                          : (context.tr(
                                  shared.LocaleKeys.commonGridViewTooltip,
                                  track: shared.TrackConstants.commonTrack,
                                ) ??
                                'Switch to Grid View'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<TableCubit, TableState>(
                builder: (context, state) {
                  if (state is TableLoaded && !state.isGridView) {
                    if (state.isReorderAllowed == false) {
                      return IconButton(
                        onPressed: () async =>
                            TableScreenActions.onToggleReorder(context),
                        icon: Icon(Icons.sort),
                        tooltip:
                            context.tr(
                              shared
                                  .LocaleKeys
                                  .enableReorderIconTableIconTooltipText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Switch to reorder list view',
                      );
                    } else {
                      return IconButton(
                        onPressed: () async =>
                            TableScreenActions.onToggleReorder(context),
                        icon: Icon(Icons.close),
                        tooltip:
                            context.tr(
                              shared
                                  .LocaleKeys
                                  .disableReorderIconTableIconTooltipText,
                              track: shared.TrackConstants.tablePageTrack,
                            ) ??
                            'Cancel to reorder list view',
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<TableCubit, TableState>(
                builder: (context, state) {
                  if (state is TableLoaded) {
                    return IconButton(
                      onPressed: () async {
                        TableScreenActions.addNewTableInfo(context);
                      },
                      icon: Icon(Icons.add),
                      tooltip:
                          context.tr(
                            shared.LocaleKeys.addTableIconTooltipText,
                            track: shared.TrackConstants.tablePageTrack,
                          ) ??
                          'Add a new Table',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocConsumer<TableCubit, TableState>(
            listener: (context, state) {
              if (state is TableError) {
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
              if (state is TableInitial || state is TableLoading) {
                return const shared.LoadingPage();
              } else if (state is TableLoaded) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: state.isGridView
                      ? buildGridView(state.tables, context)
                      : buildListView(state.tables, state.isReorderAllowed),
                );
              } else if (state is TableError) {
                return shared.ErrorPage(
                  onPressedRetryButton: () async =>
                      TableScreenActions.onRetry(context),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildGridView(List<TableInfo>? list, BuildContext context) {
    if (list == null || list.isEmpty) {
      return emptyDataWidget();
    }
    return shared.ResponsiveLayout(
      mobile: _buildGridViewWidget(list, 2),
      tablet: _buildGridViewWidget(list, 4),
      desktop: _buildGridViewWidget(list, 6),
    );
  }

  Widget _buildGridViewWidget(List<TableInfo> list, int crossAxisCount) {
    return ReorderableGridView.builder(
      key: UniqueKey(),
      itemCount: list.length,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      itemBuilder: (context, index) => buildGridItem(list[index], index, list),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,

      onReorder: (oldIndex, newIndex) async =>
          TableScreenActions.onReorder(context, oldIndex, newIndex),
      placeholderBuilder: (dragIndex, dropIndex, dragWidget) {
        return Container(
          key: UniqueKey(),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: const shared.FrostedGlassWidget(child: SizedBox()),
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 200,
      ),
    );
  }

  Widget buildGridItem(TableInfo model, int index, List<TableInfo>? list) {
    return TableGridItem(
      key: ValueKey(model.id), // Assign a unique key here
      model: model,
      index: index,
    );
  }

  Widget buildListView(List<TableInfo>? list, bool isReorderAllowedListView) {
    if (list == null || list.isEmpty) {
      return emptyDataWidget();
    }
    return shared.ResponsiveLayout(
      mobile: _buildListViewWidget(list, isReorderAllowedListView),
      tablet: _buildListViewWidget(list, isReorderAllowedListView),
      desktop: _buildListViewWidget(list, isReorderAllowedListView),
    );
  }

  Widget _buildListViewWidget(
    List<TableInfo> list,
    bool isReorderAllowedListView,
  ) {
    final listWidget = ReorderableListView.builder(
      key: UniqueKey(),
      itemCount: list.length,
      buildDefaultDragHandles: isReorderAllowedListView,
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      shrinkWrap: true,
      itemBuilder: (context, index) =>
          buildListItem(list[index], index, list, isReorderAllowedListView),
      onReorderItem: (oldIndex, newIndex) async =>
          TableScreenActions.onReorder(context, oldIndex, newIndex),
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          key: UniqueKey(),
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeInOut.transform(
              animation.value,
            );
            final double scale = lerpDouble(1, 1.02, animValue)!;
            return Transform.scale(
              scale: scale,
              child: buildListItem(
                list[index],
                index,
                list,
                isReorderAllowedListView,
              ),
            );
          },
          child: child,
        );
      },
    );
    return listWidget;
  }

  Widget buildListItem(
    TableInfo model,
    int index,
    List<TableInfo>? list,
    bool isReorderAllowedListView,
  ) {
    return TableListItem(
      key: ValueKey(model.id),
      model: model,
      index: index,
      isReorderAllowedListView: isReorderAllowedListView,
    );
  }

  Widget emptyDataWidget() {
    return Column(
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
              shared.MenuIcons.roundTable,
              color: Theme.of(context).primaryColor,
              size: 110,
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonNoDataFoundMsg,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'No data Found.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
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
              onPressed: () async {
                TableScreenActions.addNewTableInfo(context);
              },
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
                      shared.LocaleKeys.tableBtnAddNewTableText,
                      track: shared.TrackConstants.tablePageTrack,
                    ) ??
                    'Add new table info',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
