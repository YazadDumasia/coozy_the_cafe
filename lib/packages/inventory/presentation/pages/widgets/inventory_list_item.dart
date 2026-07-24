import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/inventory/presentation/pages/inventory_list_screen_actions.dart';

class InventoryListItem extends StatelessWidget {
  final InventoryItem item;

  const InventoryListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          item.name ??
              context.tr(
                shared.LocaleKeys.inventoryListPageUnknownItem,
                track: shared.TrackConstants.inventoryPageTrack,
              ) ??
              'Unknown Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text.rich(
          TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text:
                    context.tr(
                      shared.LocaleKeys.inventoryListPageCurrentStock,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Current Stock:',
              ),
              TextSpan(
                text: ' ${item.currentStock ?? ""} ${item.purchaseUnit ?? ""}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '\n'),
              TextSpan(
                text:
                    context.tr(
                      shared.LocaleKeys.inventoryListPageStatus,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Status:',
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: item.isEnabled == true
                    ? context.tr(
                            shared.LocaleKeys.inventoryListPageEnabled,
                            track: shared.TrackConstants.inventoryPageTrack,
                          ) ??
                          'Enabled'
                    : context.tr(
                            shared.LocaleKeys.inventoryListPageDisabled,
                            track: shared.TrackConstants.inventoryPageTrack,
                          ) ??
                          'Disabled',
                style: TextStyle(
                  color: item.isEnabled == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              InventoryListScreenActions.handleItemAction(context, item, value),
          itemBuilder: (context) => [
            if (item.isEnabled != true)
              PopupMenuItem(
                value: 'enable',
                child: Text(
                  context.tr(
                        shared.LocaleKeys.inventoryListPageEnable,
                        track: shared.TrackConstants.inventoryPageTrack,
                      ) ??
                      'Enable',
                ),
              ),
            if (item.isEnabled == true)
              PopupMenuItem(
                value: 'disable',
                child: Text(
                  context.tr(
                        shared.LocaleKeys.inventoryListPageDisable,
                        track: shared.TrackConstants.inventoryPageTrack,
                      ) ??
                      'Disable',
                ),
              ),
            PopupMenuItem(
              value: 'edit',
              child: Text(
                context.tr(
                      shared.LocaleKeys.inventoryListPageEditInfo,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Edit Info',
              ),
            ),
            PopupMenuItem(
              value: 'adjust',
              child: Text(
                context.tr(
                      shared.LocaleKeys.inventoryListPageAdjustStock,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Adjust Stock',
              ),
            ),
            PopupMenuItem(
              value: 'update',
              child: Text(
                context.tr(
                      shared.LocaleKeys.inventoryListPageRecordPurchase,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'Record Purchase',
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonDelete,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Delete',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
