import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class ThermalKitchenSlipWidget extends StatelessWidget {
  final int orderId;
  final String tableName;
  final String orderType;
  final String serverName;
  final List<Map<String, dynamic>> items;
  final String? globalRemarks;
  final bool is58mm;

  const ThermalKitchenSlipWidget({
    super.key,
    this.orderId = 1048,
    this.tableName = 'Table 04',
    this.orderType = 'DINE-IN',
    this.serverName = 'Waiter Alex',
    this.items = const [
      {
        'quantity': 2,
        'name': 'Cappuccino',
        'variation': 'Large (350 ml)',
        'remarks': 'Extra Shot Espresso',
      },
      {
        'quantity': 1,
        'name': 'Avocado Toast',
        'variation': 'Regular (1 pc)',
        'remarks': 'No Onions, Extra Cheese',
      },
      {
        'quantity': 3,
        'name': 'Cold Brew Coffee',
        'variation': '500 ml Bottle',
        'remarks': 'Less Ice',
      },
      {
        'quantity': 1,
        'name': 'Gourmet Pizza',
        'variation': 'Medium (10 inch)',
        'remarks': null,
      },
    ],
    this.globalRemarks = 'Fast track order - Table 04 VIP Customer.',
    this.is58mm = false,
  });

  static void showPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        bool isWidth58mm = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.print_rounded, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr(shared.LocaleKeys.thermalKotDialogTitle, track: shared.TrackConstants.tablePageTrack) ??
                          'Thermal Printer KOT Slip Preview',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: Text(
                            context.tr(shared.LocaleKeys.thermalKot80mmWidth) ??
                                '80mm Width',
                          ),
                          selected: !isWidth58mm,
                          onSelected: (val) {
                            if (val) setState(() => isWidth58mm = false);
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: Text(
                            context.tr(shared.LocaleKeys.thermalKot58mmWidth) ??
                                '58mm Width',
                          ),
                          selected: isWidth58mm,
                          onSelected: (val) {
                            if (val) setState(() => isWidth58mm = true);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ThermalKitchenSlipWidget(is58mm: isWidth58mm),
                  ],
                ),
              ),
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.print_rounded),
                  label: Text(
                    context.tr(shared.LocaleKeys.thermalKotSimulatePrintBtn, track: shared.TrackConstants.tablePageTrack) ??
                        'Simulate Print Job',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr(
                                shared.LocaleKeys.thermalKotPrintSuccessMsg,
                              ) ??
                              'KOT Slip sent to Thermal Printer successfully!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = is58mm ? 260.0 : 340.0;
    final totalCount = items.fold<int>(
      0,
      (sum, item) => sum + ((item['quantity'] as int?) ?? 1),
    );

    return Center(
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '==============================',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Text(
              'COOZY THE CAFE KOT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
            const Text(
              '==============================',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: #ORD-$orderId',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              'Table: $tableName ($orderType)',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              'Server: $serverName',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 6),
            const Text(
              '------------------------------',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            Row(
              children: const [
                SizedBox(
                  width: 32,
                  child: Text(
                    'QTY',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'ITEM & VARIATION',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              '------------------------------',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            ...items.map((item) {
              final qty = item['quantity'] ?? 1;
              final name = item['name'] ?? '';
              final variation = item['variation'] ?? '';
              final remarks = item['remarks'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$qty x',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (variation.toString().isNotEmpty)
                                Text(
                                  '[$variation]',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (remarks != null &&
                                  remarks.toString().isNotEmpty)
                                Text(
                                  '- $remarks',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const Text(
              '------------------------------',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            Text(
              'TOTAL ITEMS: $totalCount',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            if (globalRemarks != null && globalRemarks!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'REMARKS: $globalRemarks',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Text(
              '==============================',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Text(
              '*** KITCHEN COPY ***',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const Text(
              '==============================',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
