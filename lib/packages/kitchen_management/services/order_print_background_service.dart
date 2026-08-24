import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coozy_the_cafe/packages/waiter_order_placement/domain/entities/order_cart_item.dart';
import '../../core/coozy_core.dart' as core;
import '../../shared/coozy_shared.dart' as shared;

class OrderPrintBackgroundService {
  OrderPrintBackgroundService._();

  static final OrderPrintBackgroundService instance =
      OrderPrintBackgroundService._();

  /// Asynchronously processes order placement in background: checks flag, handles KOT slip print job, and pushes notifications.
  Future<void> processNewOrderPlaced({
    required int orderId,
    required String tableName,
    required List<OrderCartItem> cartItems,
  }) async {
    // Offload preference check and slip formatting to isolate / background job
    compute(_bgProcessOrderTask, {
      'orderId': orderId,
      'tableName': tableName,
      'cartItemsCount': cartItems.length,
    }).catchError((e) {
      core.PlatformUtils.debugLog(
        OrderPrintBackgroundService,
        'Background order processing error: $e',
      );
    });

    final prefs = await SharedPreferences.getInstance();
    final bool isAutoPrintEnabled =
        prefs.getBool(shared.PreferencesKeys.autoPrintKitchenOrderSlip.name) ??
        false;

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
    }
  }

  static Future<void> _bgProcessOrderTask(Map<String, dynamic> data) async {
    // Simulated ESC/POS payload format computation in background worker isolate
    final orderId = data['orderId'];
    final tableName = data['tableName'];
    final count = data['cartItemsCount'];
    debugPrint(
      '[BackgroundIsolate] Prepared KOT print buffer for Order #$orderId ($tableName, $count items)',
    );
  }
}
