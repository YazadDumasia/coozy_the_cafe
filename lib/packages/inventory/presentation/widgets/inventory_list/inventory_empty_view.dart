import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class InventoryEmptyView extends StatelessWidget {
  const InventoryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            shared.InventoryIcon.borderInventory,
            size: 150,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(
                context.tr(
                      shared.LocaleKeys.inventoryListPageNoDataFound,
                      track: shared.TrackConstants.inventoryPageTrack,
                    ) ??
                    'No inventory items found.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              )
              .inExpandedRow(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              )
              .paddingSymmetric(vertical: 20),
        ],
      ),
    );
  }
}
