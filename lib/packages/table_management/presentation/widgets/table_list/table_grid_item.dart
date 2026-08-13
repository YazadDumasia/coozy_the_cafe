import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_info.dart';
import '../../pages/table_screen/table_screen_actions.dart';

class TableGridItem extends StatelessWidget {
  final TableInfo model;
  final int index;

  const TableGridItem({super.key, required this.model, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      // key: ValueKey(model.id ?? index),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 3,
      child: Stack(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            type: MaterialType.card,
            child: InkWell(
              onTap: () async {
                TableScreenActions.onUpdateModel(context, model);
              },
              borderRadius: BorderRadius.circular(5.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 30,
                    bottom: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "${context.tr(shared.LocaleKeys.tableNameLabelText, track: shared.TrackConstants.tablePageTrack) ?? "Table Name"}: ${model.name}",
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "${context.tr(shared.LocaleKeys.tableNosOfChairsLabelText, track: shared.TrackConstants.tablePageTrack) ?? "Nos Of Chairs per Table"}: ${model.nosOfChairs}",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "${context.tr(shared.LocaleKeys.tableColorIndicatorLabelText, track: shared.TrackConstants.tablePageTrack) ?? "Color Indicator"} : ",
                            textAlign: TextAlign.start,
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                      model.colorValue ?? '000000',
                                      radix: 16,
                                    ) |
                                    0xFF000000,
                              ),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 5.0,
            end: 5.0,
            child: GestureDetector(
              onTap: () async {
                TableScreenActions.onDeleteTable(context, model);
              },
              child: const Icon(Icons.delete, color: Colors.red, size: 24.0),
            ),
          ),
        ],
      ),
    );
  }
}
