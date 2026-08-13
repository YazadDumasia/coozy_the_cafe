import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/purchase/domain/entities/purchase_record.dart';

class PurchaseHistoryListItem extends StatelessWidget {
  final PurchaseRecord record;

  const PurchaseHistoryListItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(
        context.tr(
              shared.LocaleKeys.purchaseAddQtyAndUnit,
              track: shared.TrackConstants.purchasePageTrack,
              params: {
                "purchaseQty": "${record.purchaseQty?.toStringAsFixed(2)}",
                "purchaseUnit": "${record.purchaseUnit}",
              },
            ) ??
            'Purchase: ${record.purchaseQty} ${record.purchaseUnit}',
      ),
      subtitle: Text(
        context.tr(
              shared.LocaleKeys.purchaseDateTime,
              track: shared.TrackConstants.purchasePageTrack,
              params: {"purchaseDate": " ${record.purchaseDateTime}"},
            ) ??
            'Date: ${record.purchaseDateTime}',
      ),
      trailing: Text(
        context.tr(
              shared.LocaleKeys.purchaseQtyPrice,
              track: shared.TrackConstants.purchasePageTrack,
              params: {"purchasePrice": " ${record.purchasePrice}"},
            ) ??
            'Price: \$${record.purchasePrice}',
      ),
    );
  }
}
