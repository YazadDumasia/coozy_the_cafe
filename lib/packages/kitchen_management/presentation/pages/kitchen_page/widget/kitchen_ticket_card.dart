import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/settings/coozy_settings.dart'
    as settings;

import '../../../../domain/entities/kitchen_order_entity.dart';
import 'kitchen_item_tile.dart';
import 'kitchen_timer_badge.dart';

class KitchenTicketCard extends StatelessWidget {
  final KitchenOrderEntity order;
  final Function(int orderItemId, String newStatus) onItemStatusChanged;
  final Function(int orderId, String newStatus) onBumpOrder;

  const KitchenTicketCard({
    super.key,
    required this.order,
    required this.onItemStatusChanged,
    required this.onBumpOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tableTitle =
        order.tableNameText != null && order.tableNameText!.isNotEmpty
        ? context.tr(
                shared.LocaleKeys.kitchenTableLabel,
                params: {'name': order.tableNameText!},
                track: shared.TrackConstants.orderPageTrack,
              ) ??
              'Table: ${order.tableNameText}'
        : context.tr(
                shared.LocaleKeys.kitchenTakeawayParcel,
                track: shared.TrackConstants.orderPageTrack,
              ) ??
              'Takeaway / Parcel';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tableTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        context.tr(
                              shared.LocaleKeys.kitchenTicketNumber,
                              params: {'id': '${order.id}'},
                              track: shared.TrackConstants.orderPageTrack,
                            ) ??
                            'Ticket #${order.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                KitchenTimerBadge(creationDate: order.creationDate),
              ],
            ),
            const Divider(height: 16),
            // Items List
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in order.items)
                  KitchenItemTile(
                    item: item,
                    onStatusChanged: (newStatus) {
                      onItemStatusChanged(item.id, newStatus);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            // Footer Actions: Print KOT slip & Bump Ticket
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Print Kitchen Slip',
                  icon: const Icon(Icons.print_rounded, size: 20),
                  onPressed: () async {
                    try {
                      final kitchenConfig = await settings
                          .ThermalPrinterService
                          .instance
                          .getPrinterConfig(
                            stationKey: shared
                                .PreferencesKeys
                                .kitchenStationPrinterConfig,
                          );
                      final bytes =
                          await settings
                              .EscPosTicketBuilder.buildKitchenTicketBytes(
                            order: order,
                            paperSize: kitchenConfig.paperSize,
                          );
                      final success = await settings
                          .ThermalPrinterService
                          .instance
                          .printBytesWithConfig(
                            config: kitchenConfig,
                            bytes: bytes,
                            jobName: 'Kitchen Ticket #${order.id}',
                          );
                      if (context.mounted) {
                        if (success) {
                          shared.SnackBarUtils.showSuccess(
                            context,
                            message:
                                'Ticket #${order.id} sent to Kitchen printer',
                          );
                        } else {
                          shared.SnackBarUtils.showError(
                            context,
                            message:
                                'Failed to print ticket #${order.id}. Check printer settings.',
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        shared.SnackBarUtils.showError(
                          context,
                          message: 'Print error: $e',
                        );
                      }
                    }
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onBumpOrder(order.id, 'ready'),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      context.tr(
                            shared.LocaleKeys.kitchenBumpAllReadyBtn,
                            track: shared.TrackConstants.orderPageTrack,
                          ) ??
                          'BUMP (ALL READY)',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
