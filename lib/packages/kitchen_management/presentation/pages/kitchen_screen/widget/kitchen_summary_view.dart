import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../domain/entities/kitchen_aggregated_item_entity.dart';

class KitchenSummaryView extends StatelessWidget {
  final List<KitchenAggregatedItemEntity> items;

  const KitchenSummaryView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'No items currently pending preparation',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Combine all items by name for top grand-total overview
    final Map<String, int> grandTotals = {};
    for (final item in items) {
      grandTotals[item.itemName] = (grandTotals[item.itemName] ?? 0) + item.totalQuantity;
    }

    // Group items by order status
    final preparingItems = items.where((i) => i.status.toLowerCase() == 'preparing' || i.status.toLowerCase() == 'in_progress').toList();
    final pendingItems = items.where((i) => i.status.toLowerCase() == 'pending' || i.status.toLowerCase() == 'placed').toList();
    final readyItems = items.where((i) => i.status.toLowerCase() == 'ready').toList();
    final otherItems = items.where((i) =>
      !['preparing', 'in_progress', 'pending', 'placed', 'ready'].contains(i.status.toLowerCase())
    ).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 550) {
          crossAxisCount = 2;
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. TOP EXPANDED OVERVIEW - All Order Items
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  leading: Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
                  title: Text(
                    'All',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  subtitle: Text(
                    'Grand Total: ${grandTotals.values.fold(0, (a, b) => a + b)} items across ${grandTotals.length} unique dishes',
                    style: theme.textTheme.bodySmall,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: MasonryGridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        itemCount: grandTotals.length,
                        itemBuilder: (context, index) {
                          final entry = grandTotals.entries.elementAt(index);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  child: Text(
                                    '${entry.value}x',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. PREPARING SECTION
            if (preparingItems.isNotEmpty)
              _buildStatusSection(
                context,
                title: 'Preparing',
                icon: Icons.soup_kitchen_outlined,
                color: Colors.blue,
                items: preparingItems,
                crossAxisCount: crossAxisCount,
              ),

            // 3. PENDING SECTION
            if (pendingItems.isNotEmpty)
              _buildStatusSection(
                context,
                title: 'Pending',
                icon: Icons.hourglass_top_outlined,
                color: Colors.orange,
                items: pendingItems,
                crossAxisCount: crossAxisCount,
              ),

            // 4. READY TO SERVE SECTION
            if (readyItems.isNotEmpty)
              _buildStatusSection(
                context,
                title: 'Ready to Serve',
                icon: Icons.check_circle_outline,
                color: Colors.green,
                items: readyItems,
                crossAxisCount: crossAxisCount,
              ),

            // 5. OTHER ITEMS (IF ANY)
            if (otherItems.isNotEmpty)
              _buildStatusSection(
                context,
                title: 'Other',
                icon: Icons.list_alt,
                color: Colors.grey,
                items: otherItems,
                crossAxisCount: crossAxisCount,
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<KitchenAggregatedItemEntity> items,
    required int crossAxisCount,
  }) {
    final theme = Theme.of(context);
    final totalQty = items.fold(0, (sum, item) => sum + item.totalQuantity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: Icon(icon, color: color),
            title: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalQty items',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: MasonryGridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          child: Text(
                            '${item.totalQuantity}x',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          item.itemName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.categoryName != null && item.categoryName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.categoryName!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            if (item.orderType != null)
                              Text('Type: ${item.orderType}'),
                            if (item.remarks != null && item.remarks!.isNotEmpty)
                              Text(
                                'Notes: ${item.remarks}',
                                style: TextStyle(color: theme.colorScheme.error),
                              ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(
                            item.status.toUpperCase(),
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          backgroundColor: color,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
