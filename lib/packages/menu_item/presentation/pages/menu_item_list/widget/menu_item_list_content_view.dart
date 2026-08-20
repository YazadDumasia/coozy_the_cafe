import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../../domain/entities/menu_item.dart';
import '../../../widgets/menu_item_list/menu_item_list_item.dart';

class MenuItemListContentView extends StatelessWidget {
  final List<MenuItem> filteredItems;

  const MenuItemListContentView({super.key, required this.filteredItems});

  @override
  Widget build(BuildContext context) {
    return shared.ResponsiveLayout(
      mobile: SlidableAutoCloseBehavior(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemCount: filteredItems.length,
          addRepaintBoundaries: true,
          addAutomaticKeepAlives: false,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return MenuItemListItem(
              key: ValueKey('mobile_item_${item.id ?? index}'),
              item: item,
              index: index,
              totalLength: filteredItems.length,
            );
          },
        ),
      ),
      tablet: SlidableAutoCloseBehavior(
        child: MasonryGridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: filteredItems.length,
          addRepaintBoundaries: true,
          addAutomaticKeepAlives: false,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return MenuItemListItem(
              key: ValueKey('tablet_item_${item.id ?? index}'),
              item: item,
              index: index,
              totalLength: filteredItems.length,
            );
          },
        ),
      ),
      desktop: SlidableAutoCloseBehavior(
        child: MasonryGridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 450,
          ),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          itemCount: filteredItems.length,
          addRepaintBoundaries: true,
          addAutomaticKeepAlives: false,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return MenuItemListItem(
              key: ValueKey('desktop_item_${item.id ?? index}'),
              item: item,
              index: index,
              totalLength: filteredItems.length,
            );
          },
        ),
      ),
    );
  }
}
