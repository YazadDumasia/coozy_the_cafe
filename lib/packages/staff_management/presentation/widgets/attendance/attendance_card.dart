import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/staff_entities.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AttendanceCard extends StatelessWidget {
  final AttendanceEntity attendance;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AttendanceCard({
    super.key,
    required this.attendance,
    required this.onEdit,
    required this.onDelete,
  });

  String _calculateWorkingDuration(String fromTime, String toTime) {
    if (fromTime.isEmpty ||
        toTime.isEmpty ||
        fromTime == 'N/A' ||
        toTime == 'N/A') {
      return 'N/A';
    }
    final cleanFrom = fromTime.trim();
    final cleanTo = toTime.trim();
    final formats = [
      DateFormat('hh:mm a'),
      DateFormat('h:mm a'),
      DateFormat.jm(),
      DateFormat.Hm(),
    ];
    DateTime? start;
    DateTime? end;
    for (final fmt in formats) {
      try {
        start ??= fmt.parse(cleanFrom);
      } catch (_) {}
      try {
        end ??= fmt.parse(cleanTo);
      } catch (_) {}
    }
    if (start == null || end == null) return 'N/A';
    Duration difference = end.difference(start);
    if (difference.isNegative ||
        (difference.inMinutes == 0 && cleanFrom != cleanTo)) {
      difference += const Duration(days: 1);
    }
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    if (minutes == 0) return '$hours hours';
    return '$hours hours $minutes mins';
  }

  @override
  Widget build(BuildContext context) {
    final String employeeName =
        attendance.employeeName ?? 'Employee #${attendance.employeeId}';
    final String checkIn =
        (attendance.checkIn == null || attendance.checkIn!.isEmpty)
        ? 'N/A'
        : attendance.checkIn!;
    final String checkOut =
        (attendance.checkOut == null || attendance.checkOut!.isEmpty)
        ? 'N/A'
        : attendance.checkOut!;
    final String? rawCreation = attendance.createdDate;
    final String? rawModification = attendance.modificationDate;

    final String? formattedCreation =
        (rawCreation != null && rawCreation.isNotEmpty && rawCreation != 'N/A')
        ? core.DateUtil.localFormat(rawCreation, core.DateUtil.dateFormat15) ??
              rawCreation
        : null;

    final String? formattedModification =
        (rawModification != null &&
            rawModification.isNotEmpty &&
            rawModification != 'N/A')
        ? core.DateUtil.localFormat(
                rawModification,
                core.DateUtil.dateFormat15,
              ) ??
              rawModification
        : null;
    final String workingDuration =
        (attendance.notes != null &&
            attendance.notes!.isNotEmpty &&
            attendance.notes != 'N/A')
        ? attendance.notes!
        : _calculateWorkingDuration(checkIn, checkOut);

    return Slidable(
      key: ValueKey(attendance.id),
      closeOnScroll: true,
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: <Widget>[
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            label:
                context.tr(
                  shared.LocaleKeys.commonEdit,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Edit',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            autoClose: true,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            icon: Icons.delete,
            label:
                context.tr(
                  shared.LocaleKeys.commonDelete,
                  track: shared.TrackConstants.commonTrack,
                ) ??
                'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  context.tr(
                        shared.LocaleKeys.employeeCardEmployeeLabel,
                        track: shared.TrackConstants.staffManagementPageTrack,
                        params: {'name': employeeName},
                      ) ??
                      'Employee: $employeeName',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Check-in Time: ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: checkIn,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Check-out Time: ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: checkOut,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'working Time Durations: ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: workingDuration,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (formattedCreation != null &&
                  formattedModification != null &&
                  formattedCreation == formattedModification) ...[
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Creation on: ',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: formattedCreation,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (formattedModification != null &&
                  formattedCreation != formattedModification) ...[
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Last modification on: ',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: formattedModification,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (formattedCreation != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Creation on: ',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: formattedCreation,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
