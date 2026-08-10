import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class PurchaseEmptyView extends StatelessWidget {
  const PurchaseEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(
          shared.InventoryIcon.borderPurchaseList,
          color: Theme.of(context).colorScheme.primary,
          size: 150,
        ),
        Text(
              context.tr(
                    shared.LocaleKeys.purchaseNoPurchaseRecordsFound,
                    track: shared.TrackConstants.purchasePageTrack,
                  ) ??
                  'No purchase records found.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            )
            .inExpandedRow(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            )
            .paddingSymmetric(vertical: 20),
      ],
    );
  }
}
