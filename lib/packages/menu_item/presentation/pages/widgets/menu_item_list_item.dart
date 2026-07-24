import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/menu_item/domain/entities/menu_item.dart';
import '../menu_item_list_screen_actions.dart';

class MenuItemListItem extends StatelessWidget {
  final MenuItem item;
  final int index;
  final int totalLength;

  const MenuItemListItem({
    super.key,
    required this.item,
    required this.index,
    required this.totalLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: index == 0 ? 8 : 4,
        bottom: index == totalLength - 1 ? 16 : 4,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Slidable(
          key: ValueKey('item_${item.id}'),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) =>
                    MenuItemListScreenActions.handleEditMenuItem(context, item),
                backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label:
                    context.tr(
                      shared.LocaleKeys.commonEdit,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Edit',
              ),
              SlidableAction(
                onPressed: (context) =>
                    MenuItemListScreenActions.handleDeleteMenuItem(
                      context,
                      item,
                    ),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label:
                    context.tr(
                      shared.LocaleKeys.commonDelete,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Delete',
              ),
            ],
          ),
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ExpansionTile(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              collapsedShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                context.tr(
                      shared.LocaleKeys.menuItemPageTypes,
                      track: shared.TrackConstants.menuItemPageTrack,
                      params: {
                        "foodType":
                            item.foodType ??
                            context.tr(
                              shared.LocaleKeys.commonUnknown,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Unknown',
                      },
                    ) ??
                    'Type: ${item.foodType ?? context.tr(shared.LocaleKeys.commonUnknown, track: shared.TrackConstants.commonTrack) ?? 'Unknown'}',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.tr(
                            shared.LocaleKeys.menuItemPageVariations,
                            track: shared.TrackConstants.menuItemPageTrack,
                            params: {
                              "lenght": item.variations.isEmpty
                                  ? ''
                                  : item.variations.length.toString(),
                            },
                          ) ??
                          'Variations: ${item.variations.isEmpty ? '' : item.variations.length.toString()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
