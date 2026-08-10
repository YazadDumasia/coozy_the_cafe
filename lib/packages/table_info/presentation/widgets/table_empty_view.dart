import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class TableEmptyView extends StatelessWidget {
  final VoidCallback onAddNewTable;

  const TableEmptyView({super.key, required this.onAddNewTable});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              shared.MenuIcons.roundTable,
              color: Theme.of(context).colorScheme.primary,
              size: 110,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                context.tr(
                      shared.LocaleKeys.commonNoDataFoundMsg,
                      track: shared.TrackConstants.commonTrack,
                    ) ??
                    'No data Found.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: onAddNewTable,
              style: ElevatedButton.styleFrom(
                textStyle: Theme.of(context).textTheme.bodyLarge,
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  right: 25,
                  left: 25,
                ),
                elevation: 5,
              ),
              child: Text(
                context.tr(
                      shared.LocaleKeys.tableBtnAddNewTableText,
                      track: shared.TrackConstants.tablePageTrack,
                    ) ??
                    'Add new table info',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
