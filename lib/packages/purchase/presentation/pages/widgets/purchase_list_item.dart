import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_record.dart';
import '../purchase_list_screen_actions.dart';

class PurchaseListItem extends StatelessWidget {
  final PurchaseRecord record;

  const PurchaseListItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final qty = record.purchaseQty ?? 0;
    final DateTime? dt = record.purchaseDateTime != null
        ? DateTime.tryParse(record.purchaseDateTime!)
        : null;
    final dateStr = dt != null
        ? core.DateUtil.localFormatDateTime(dt, core.DateUtil.dateFormat7)
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          '${record.name} - ${qty > 0 ? (context.tr(shared.LocaleKeys.purchaseIncrement, track: shared.TrackConstants.purchasePageTrack) ?? "Increment") : (context.tr(shared.LocaleKeys.purchaseDecrement, track: shared.TrackConstants.purchasePageTrack) ?? "Decrement")}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.tr(shared.LocaleKeys.purchaseQuantityLabelText, track: shared.TrackConstants.purchasePageTrack) ?? "Quantity"}: ${qty.abs()} ${record.purchaseUnit ?? ""}',
            ),
            Text(
              '${context.tr(shared.LocaleKeys.purchaseTotalPrice, track: shared.TrackConstants.purchasePageTrack) ?? "Total Price"}: \$${record.purchasePrice?.toStringAsFixed(2) ?? "0.00"}',
            ),
            Text(
              '${context.tr(shared.LocaleKeys.purchaseDate, track: shared.TrackConstants.purchasePageTrack) ?? "Date"}: $dateStr',
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              final item = InventoryItem(
                id: record.inventoryId,
                name: record.name,
                purchaseUnit: record.purchaseUnit,
              );
              PurchaseListScreenActions.showPurchaseForm(
                context: context,
                item: item,
                existingRecord: record,
              );
            } else if (value == 'delete') {
              PurchaseListScreenActions.onDeletePurchaseTap(
                context: context,
                record: record,
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonEdit,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'Edit',
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
