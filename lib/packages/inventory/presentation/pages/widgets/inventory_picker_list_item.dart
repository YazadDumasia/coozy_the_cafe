import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';

class InventoryPickerListItem extends StatelessWidget {
  final InventoryItem item;

  const InventoryPickerListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        context.tr(
              shared.LocaleKeys.inventoryPickerPageItemName,
              track: shared.TrackConstants.inventoryPageTrack,
              params: {"name": item.name ?? ''},
            ) ??
            'Item: ${item.name}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        context.tr(
              shared.LocaleKeys.inventoryPickerPageCurrentStock,
              track: shared.TrackConstants.inventoryPageTrack,
              params: {
                "currentStock": item.currentStock?.toString() ?? '0',
                "purchaseUnit": item.purchaseUnit ?? '',
              },
            ) ??
            'Current Stock: ${item.currentStock ?? 0} ${item.purchaseUnit ?? ''}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.pop(item);
      },
    );
  }
}
