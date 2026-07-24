import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../domain/entities/staff_entities.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class LeaveCard extends StatelessWidget {
  final LeaveEntity leave;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LeaveCard({
    super.key,
    required this.leave,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String employeeName =
        leave.employeeName ?? 'Employee #${leave.employeeId}';

    final String? rawCreation = leave.createdDate;
    final String? rawModification = leave.modificationDate;

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

    return Slidable(
      key: ValueKey(leave.id),
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 5),
              if (leave.leaveType != null)
                Text(
                  context.tr(
                        shared.LocaleKeys.leaveCardLeaveType,
                        track: shared.TrackConstants.staffManagementPageTrack,
                        params: {'leaveType': leave.leaveType!},
                      ) ??
                      'Leave Type: ${leave.leaveType}',
                ),
              if (leave.status != null)
                Text(
                  context.tr(
                        shared.LocaleKeys.leaveCardStatus,
                        track: shared.TrackConstants.staffManagementPageTrack,
                        params: {'status': leave.status!},
                      ) ??
                      'Status: ${leave.status}',
                ),
              if (leave.reason != null && leave.reason!.isNotEmpty)
                Text(
                  context.tr(
                        shared.LocaleKeys.leaveCardReasonParam,
                        track: shared.TrackConstants.staffManagementPageTrack,
                        params: {'reason': leave.reason!},
                      ) ??
                      'Reason: ${leave.reason}',
                ),
              if (formattedCreation != null &&
                  formattedModification != null &&
                  formattedCreation == formattedModification) ...[
                const SizedBox(height: 5),
                Text(
                  context.tr(
                        shared.LocaleKeys.cardCreationDate,
                        track: shared.TrackConstants.staffManagementPageTrack,
                        params: {'date': formattedCreation},
                      ) ??
                      'Creation Date: $formattedCreation',
                ),
              ] else if (formattedModification != null &&
                  formattedCreation != formattedModification) ...[
                const SizedBox(height: 5),
                Text(
                  context.tr(
                        shared.LocaleKeys.cardModificationDate,
                        track: shared.TrackConstants.staffManagementPageTrack,
                        params: {'date': formattedModification},
                      ) ??
                      'Modification Date: $formattedModification',
                ),
              ] else if (formattedCreation != null) ...[
                const SizedBox(height: 5),
                Text(
                  context.tr(
                        shared.LocaleKeys.cardCreationDate,
                        track: shared.TrackConstants.staffManagementPageTrack,
                        params: {'date': formattedCreation},
                      ) ??
                      'Creation Date: $formattedCreation',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
