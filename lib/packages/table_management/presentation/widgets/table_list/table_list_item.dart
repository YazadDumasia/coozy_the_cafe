import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_info.dart';
import '../../pages/table_screen/table_screen_actions.dart';

class TableListItem extends StatelessWidget {
  final TableInfo model;
  final int index;
  final bool isReorderAllowedListView;

  const TableListItem({
    super.key,
    required this.model,
    required this.index,
    required this.isReorderAllowedListView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // key: ValueKey(model.id ?? index),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            color: Colors.transparent,
            type: MaterialType.card,
            child: InkWell(
              borderRadius: BorderRadius.circular(5.0),
              onTap: () {
                TableScreenActions.onUpdateModel(context, model);
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(model.colorValue ?? '000000', radix: 16) |
                              0xFF000000,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
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
                                        "${context.tr(shared.LocaleKeys.tableNameLabelText, track: shared.TrackConstants.tablePageTrack) ?? "Table Label"}: ${model.tableLabel ?? model.tableNo ?? ''}",
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (model.tableNo != null &&
                                    model.tableNo!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "Table No: ${model.tableNo}",
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 5),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !isReorderAllowedListView,
                      replacement: Theme(
                        data: Theme.of(context),
                        child: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(context),
                        child: PopupMenuButton(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              TableScreenActions.onUpdateModel(context, model);
                            }
                            if (value == 'delete') {
                              TableScreenActions.onDeleteTable(context, model);
                            }
                          },
                          itemBuilder: (BuildContext bc) {
                            return <PopupMenuItem<String>>[
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  context.tr(
                                        shared.LocaleKeys.commonEdit,
                                        track:
                                            shared.TrackConstants.commonTrack,
                                      ) ??
                                      'Edit',
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  context.tr(
                                        shared.LocaleKeys.commonDelete,
                                        track:
                                            shared.TrackConstants.commonTrack,
                                      ) ??
                                      'Delete',
                                ),
                              ),
                            ];
                          },
                          icon: const Icon(Icons.more_vert_rounded, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
