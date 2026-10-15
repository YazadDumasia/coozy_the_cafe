
import '../../waiter_order_placement/domain/entities/order_cart_item.dart'
    as cart;
import '../../core/coozy_core.dart' as core;
import '../../shared/coozy_shared.dart' as shared;
import '../../settings/coozy_settings.dart' as settings;
import '../domain/entities/kitchen_order_entity.dart';
import '../domain/entities/kitchen_order_item_entity.dart';

class OrderPrintBackgroundService {
  OrderPrintBackgroundService._();

  static final OrderPrintBackgroundService instance =
      OrderPrintBackgroundService._();

  /// Asynchronously processes order placement in background: checks flag, handles KOT slip print job, and pushes notifications.
  Future<void> processNewOrderPlaced({
    required int orderId,
    required String tableName,
    required List<cart.OrderCartItem> cartItems,
  }) async {
    final bool isAutoPrintEnabled = shared.LocalManager.instance.getBoolValue(
      key: shared.PreferencesKeys.autoPrintKitchenOrderSlip,
    );

    if (isAutoPrintEnabled) {
      core.PlatformUtils.debugLog(
        OrderPrintBackgroundService,
        '[AUTO-PRINT KOT] Order #$orderId for $tableName with ${cartItems.length} items sent to thermal printer background queue.',
      );

      // Trigger local push notification for KOT auto print
      await core.NotificationApi.init();
      core.NotificationApi.showOrderPlacedNotification(
        orderId: orderId,
        tableName: tableName,
        itemCount: cartItems.length,
      );

      // Perform real ESC/POS thermal printing for Kitchen station
      try {
        final kitchenConfig = await settings.ThermalPrinterService.instance
            .getPrinterConfig(
              stationKey: shared.PreferencesKeys.kitchenStationPrinterConfig,
            );

        // Convert cart items to kitchen order items
        final kitchenItems = cartItems
            .map(
              (c) => KitchenOrderItemEntity(
                id: c.menuItemId,
                orderId: orderId,
                itemId: c.menuItemId,
                itemName: c.name,
                quantity: c.quantity,
                status: 'pending',
                remarks: c.remarks,
                variationQuantity: c.variationName,
              ),
            )
            .toList();

        final kitchenOrder = KitchenOrderEntity(
          id: orderId,
          tableNameText: tableName,
          creationDate: DateTime.now().toIso8601String(),
          status: 'pending',
          orderType: 'Dine-In',
          items: kitchenItems,
        );

        final bytes =
            await settings.EscPosTicketBuilder.buildKitchenTicketBytes(
              order: kitchenOrder,
              paperSize: kitchenConfig.paperSize,
            );

        final success = await settings.ThermalPrinterService.instance
            .printBytesWithConfig(
              config: kitchenConfig,
              bytes: bytes,
              jobName: 'Auto KOT #$orderId',
            );

        core.PlatformUtils.debugLog(
          OrderPrintBackgroundService,
          '[AUTO-PRINT KOT] Print job completed with success=$success',
        );
      } catch (e) {
        core.PlatformUtils.debugLog(
          OrderPrintBackgroundService,
          'Error during auto-print KOT ticket: $e',
        );
      }
    }
  }
}
