import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/inventory/domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_record.dart';
import '../../pages/purchase_list/purchase_list_screen_actions.dart';

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
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.2),
          child: Icon(
            qty > 0
                ? Icons.arrow_circle_up_outlined
                : Icons.arrow_circle_down_outlined,
            color: qty > 0 ? Colors.green : Colors.red,
            size: 30,
          ),
        ),
        title: Text(record.name ?? '').inExpandedRow(),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.tr(shared.LocaleKeys.purchaseQuantityLabelText, track: shared.TrackConstants.purchasePageTrack) ?? "Quantity"}: ${qty.abs()} ${record.purchaseUnit ?? ""}',
            ).inExpandedRow(),
            Text(
              '${context.tr(shared.LocaleKeys.purchaseTotalPrice, track: shared.TrackConstants.purchasePageTrack) ?? "Total Price"}: \$${record.purchasePrice?.toStringAsFixed(2) ?? "0.00"}',
            ).inExpandedRow(),
            Text(
              '${context.tr(shared.LocaleKeys.purchaseDate, track: shared.TrackConstants.purchasePageTrack) ?? "Date"}: $dateStr',
            ).inExpandedRow(),
            if (record.inventoryId != null)
              Text(
                'Current Stock: ${record.currentStock ?? 0.0} ${record.purchaseUnit ?? ""}',
              ).inExpandedRow(),
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
