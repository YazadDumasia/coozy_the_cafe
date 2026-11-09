import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/domain/entities/stock_alert.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/cubit/stock_alerts_cubit.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/pages/stock_alerts_page/widget/threshold_config_dialog.dart';
import 'package:coozy_the_cafe/packages/inventory_intelligence/presentation/pages/stock_alerts_page/widget/reorder_summary_dialog.dart';

class StockAlertsPageActions {
  static void scanDeficits(BuildContext context, StockAlertsCubit cubit) {
    cubit.scanDeficits();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanning inventory for low-stock deficits...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void dismissAlert(
    BuildContext context,
    StockAlertsCubit cubit,
    StockAlert alert,
  ) {
    if (alert.id != null) {
      cubit.dismissAlert(alert.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dismissed alert for ${alert.inventoryName}'),
          action: SnackBarAction(
            label: 'Scan Again',
            onPressed: () => cubit.scanDeficits(),
          ),
        ),
      );
    }
  }

  static void openConfigureThresholdDialog({
    required BuildContext context,
    required StockAlertsCubit cubit,
    required int inventoryId,
    required String itemName,
    required double currentMinThreshold,
    required double currentReorderQuantity,
    bool currentAutoReorder = true,
  }) {
    showDialog(
      context: context,
      builder: (_) => ThresholdConfigDialog(
        inventoryId: inventoryId,
        itemName: itemName,
        currentMinThreshold: currentMinThreshold,
        currentReorderQuantity: currentReorderQuantity,
        currentAutoReorder: currentAutoReorder,
        onSave: (minThreshold, reorderQuantity, autoReorder) {
          cubit.updateThreshold(
            inventoryId: inventoryId,
            minThreshold: minThreshold,
            suggestedReorderQuantity: reorderQuantity,
            autoReorderEnabled: autoReorder,
          );
        },
      ),
    );
  }

  static Future<void> openReorderSummaryDialog({
    required BuildContext context,
    required StockAlertsCubit cubit,
  }) async {
    final suggestions = await cubit.fetchSuggestions();
    if (!context.mounted) return;

    if (suggestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reorder suggestions available at this time.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => ReorderSummaryDialog(
        suggestions: suggestions,
        onConfirmReorder: () {
          cubit.reorderBatch(suggestions);
        },
      ),
    );
  }
}
