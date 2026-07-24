import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/staff_entities.dart';

import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class EmployeeCard extends StatelessWidget {
  final EmployeeEntity employee;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = employee.name ?? '';
    final String position = employee.position ?? '';
    final String phone = employee.phoneNumber ?? '';
    final String startWorkingTime = employee.startWorkingTime ?? '';
    final String endWorkingTime = employee.endWorkingTime ?? '';
    final int? totalLeaves = employee.totalLeaves;

    final String? rawCreation = employee.createdDate;
    final String? rawModification = employee.modificationDate;

    final String? formattedCreation =
        (rawCreation != null && rawCreation.isNotEmpty)
        ? core.DateUtil.localFormat(rawCreation, core.DateUtil.dateFormat15) ??
              rawCreation
        : null;

    final String? formattedModification =
        (rawModification != null && rawModification.isNotEmpty)
        ? core.DateUtil.localFormat(
                rawModification,
                core.DateUtil.dateFormat15,
              ) ??
              rawModification
        : null;

    return Slidable(
      key: ValueKey(employee.id),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Hero(
          tag: 'employee_${employee.id}',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.of(context).push(
                  HeroDialogRoute(
                    builder: (_) => EmployeeDetailsDialog(
                      employee: employee,
                      onMakePhoneCall: _makePhoneCall,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'E',
                      ),
                    ),
                    title: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (position.isNotEmpty)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.employeeCardPosition,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'position': position},
                                ) ??
                                'Position: $position',
                          ),
                        if (phone.isNotEmpty)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.employeeCardPhone,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'phone': phone},
                                ) ??
                                'Phone: $phone',
                          ),
                        if (employee.email != null &&
                            employee.email!.isNotEmpty)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.employeeCardEmail,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'email': employee.email!},
                                ) ??
                                'Email: ${employee.email}',
                          ),
                        if (startWorkingTime.isNotEmpty)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.employeeCardStartTime,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'time': startWorkingTime},
                                ) ??
                                'Start Working Time: $startWorkingTime',
                          ),
                        if (endWorkingTime.isNotEmpty)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.employeeCardEndTime,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'time': endWorkingTime},
                                ) ??
                                'End Working Time: $endWorkingTime',
                          ),
                        if (totalLeaves != null || totalLeaves != 0)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.employeeCardTotalLeaves,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'count': '${totalLeaves ?? 0}'},
                                ) ??
                                'Total Leaves: $totalLeaves',
                          ),
                        if (formattedCreation != null &&
                            formattedModification != null &&
                            formattedCreation == formattedModification)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.cardCreationDate,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'date': formattedCreation},
                                ) ??
                                'Creation Date: $formattedCreation',
                          )
                        else if (formattedModification != null &&
                            formattedCreation != formattedModification)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.cardModificationDate,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'date': formattedModification},
                                ) ??
                                'Modification Date: $formattedModification',
                          )
                        else if (formattedCreation != null)
                          Text(
                            context.tr(
                                  shared.LocaleKeys.cardCreationDate,
                                  track:
                                      shared.TrackConstants.staffManagementPageTrack,
                                  params: {'date': formattedCreation},
                                ) ??
                                'Creation Date: $formattedCreation',
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmployeeDetailsDialog extends StatelessWidget {
  final EmployeeEntity employee;
  final Function(String) onMakePhoneCall;

  const EmployeeDetailsDialog({
    super.key,
    required this.employee,
    required this.onMakePhoneCall,
  });

  @override
  Widget build(BuildContext context) {
    final String name = employee.name ?? '';
    final String position = employee.position ?? '';
    final String phone = employee.phoneNumber ?? '';

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap from dismissing dialog
            child: Hero(
              tag: 'employee_${employee.id}',
              child: Material(
                borderRadius: BorderRadius.circular(16),
                elevation: 8,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'E',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (position.isNotEmpty)
                                    Text(
                                      position,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (phone.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.green,
                                ),
                                onPressed: () => onMakePhoneCall(phone),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          children: [
                            if (phone.isNotEmpty)
                              _buildDetailRow(Icons.phone, 'Phone', phone),
                            if (employee.email != null &&
                                employee.email!.isNotEmpty)
                              _buildDetailRow(
                                Icons.email,
                                'Email',
                                employee.email!,
                              ),
                            if ((employee.addressLine1?.isNotEmpty ?? false) ||
                                (employee.addressLine2?.isNotEmpty ?? false))
                              _buildDetailRow(
                                Icons.location_on,
                                'Address',
                                [employee.addressLine1, employee.addressLine2]
                                    .where((e) => e != null && e.isNotEmpty)
                                    .join(', '),
                              ),
                            if (employee.idProof != null &&
                                employee.idProof!.isNotEmpty)
                              _buildDetailRow(
                                Icons.badge,
                                'ID Proof',
                                '${employee.idProof} - ${employee.idProofNumber ?? ''}',
                              ),
                            if (employee.totalLeaves != null)
                              _buildDetailRow(
                                Icons.event_busy,
                                'Total Leaves',
                                '${employee.totalLeaves}',
                              ),
                            if (employee.salary != null)
                              _buildDetailRow(
                                Icons.attach_money,
                                'Salary',
                                '${employee.salary}',
                              ),
                            if (employee.joiningDate != null &&
                                employee.joiningDate!.isNotEmpty)
                              _buildDetailRow(
                                Icons.calendar_today,
                                'Joining Date',
                                employee.joiningDate!,
                              ),
                            if (employee.leavingDate != null &&
                                employee.leavingDate!.isNotEmpty)
                              _buildDetailRow(
                                Icons.event_available,
                                'Leaving Date',
                                employee.leavingDate!,
                              ),
                            if (employee.startWorkingTime != null &&
                                employee.startWorkingTime!.isNotEmpty)
                              _buildDetailRow(
                                Icons.access_time,
                                'Shift Start',
                                employee.startWorkingTime!,
                              ),
                            if (employee.endWorkingTime != null &&
                                employee.endWorkingTime!.isNotEmpty)
                              _buildDetailRow(
                                Icons.access_time,
                                'Shift End',
                                employee.endWorkingTime!,
                              ),
                            if (employee.workingHours != null &&
                                employee.workingHours!.isNotEmpty)
                              _buildDetailRow(
                                Icons.timer,
                                'Total Working Hours',
                                employee.workingHours!,
                              ),
                            if (employee.createdDate != null &&
                                employee.createdDate!.isNotEmpty)
                              _buildDetailRow(
                                Icons.history,
                                'Record Created',
                                core.DateUtil.localFormat(
                                      employee.createdDate,
                                      core.DateUtil.dateFormat15,
                                    ) ??
                                    employee.createdDate!,
                              ),
                            if (employee.modificationDate != null &&
                                employee.modificationDate!.isNotEmpty &&
                                core.DateUtil.localFormat(
                                      employee.modificationDate,
                                      core.DateUtil.dateFormat15,
                                    ) !=
                                    core.DateUtil.localFormat(
                                      employee.createdDate,
                                      core.DateUtil.dateFormat15,
                                    ))
                              _buildDetailRow(
                                Icons.manage_history_outlined,
                                'Record Modified',
                                core.DateUtil.localFormat(
                                      employee.modificationDate,
                                      core.DateUtil.dateFormat15,
                                    ) ??
                                    employee.modificationDate!,
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.commonClose,
                                  track: shared.TrackConstants.commonTrack,
                                ) ??
                                'Close',
                            textAlign: TextAlign.center,
                          ),
                        ).inExpandedRow(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Hero Route
class HeroDialogRoute<T> extends PageRoute<T> {
  HeroDialogRoute({required this.builder});

  final WidgetBuilder builder;

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => "Dismiss";

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(opacity: animation, child: builder(context));
  }
}
