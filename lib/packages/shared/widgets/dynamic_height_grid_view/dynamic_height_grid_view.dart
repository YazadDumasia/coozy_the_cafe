import 'package:flutter/material.dart';

/// GridView with dynamic height
class DynamicHeightGridView extends StatelessWidget {
  const DynamicHeightGridView({
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    super.key,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  });

  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final CrossAxisAlignment rowCrossAxisAlignment;

  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;

  int get columnLength => (itemCount + crossAxisCount - 1) ~/ crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: false,
      addSemanticIndexes: true,
      itemBuilder: (ctx, columnIndex) {
        return _GridRow(
          columnIndex: columnIndex,
          builder: builder,
          itemCount: itemCount,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisAlignment: rowCrossAxisAlignment,
        );
      },
      itemCount: columnLength,
    );
  }
}

/// Use this for [CustomScrollView] with better optimization using SliverGrid
class SliverDynamicHeightGridView extends StatelessWidget {
  const SliverDynamicHeightGridView({
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    super.key,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.controller,
  });

  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(builder, childCount: itemCount),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    required this.columnIndex,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.crossAxisAlignment,
  });

  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final int columnIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: columnIndex == 0 ? 0 : mainAxisSpacing),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: List.generate(crossAxisCount, (rowIndex) {
          final int itemIndex = columnIndex * crossAxisCount + rowIndex;
          if (itemIndex >= itemCount) {
            return const Expanded(child: SizedBox());
          }
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: rowIndex == crossAxisCount - 1 ? 0 : crossAxisSpacing,
              ),
              child: builder(context, itemIndex),
            ),
          );
        }),
      ),
    );
  }
}
