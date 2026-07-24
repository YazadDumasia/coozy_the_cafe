import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../bloc/employee/employee_bloc.dart';
import '../bloc/employee/employee_event_state.dart';
import '../../domain/entities/staff_entities.dart';

class LeaveFormDialog extends StatefulWidget {
  final LeaveEntity? leave;
  final Function(LeaveEntity entity) onSubmit;

  const LeaveFormDialog({super.key, this.leave, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    LeaveEntity? leave,
    required Function(LeaveEntity entity) onSubmit,
  }) async {
    final employeeBloc = context.read<EmployeeBloc>();
    await showModalBottomSheet<void>(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
          bottom: Radius.circular(0.0),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.10,
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      builder: (dialogContext) {
        return BlocProvider.value(
          value: employeeBloc,
          child: LeaveFormDialog(leave: leave, onSubmit: onSubmit),
        );
      },
    );
  }

  @override
  State<LeaveFormDialog> createState() => _LeaveFormDialogState();
}

class _LeaveFormDialogState extends State<LeaveFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedEmployeeId;
  String? _selectedEmployeeName;
  late String _leaveType;
  late String _status;
  late TextEditingController _reasonController;
  // New controllers for start/end datetime
  late TextEditingController _startDateTimeController;
  late TextEditingController _endDateTimeController;

  @override
  void initState() {
    super.initState();
    _selectedEmployeeId = widget.leave?.employeeId;
    _selectedEmployeeName = widget.leave?.employeeName;
    _leaveType = widget.leave?.leaveType ?? 'Sick Leave';
    _status = widget.leave?.status ?? 'Pending';
    _reasonController = TextEditingController(text: widget.leave?.reason ?? '');
    _startDateTimeController = TextEditingController(
      text: widget.leave?.startDateTime ?? '',
    );
    _endDateTimeController = TextEditingController(
      text: widget.leave?.endDateTime ?? '',
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _startDateTimeController.dispose();
    _endDateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.leave != null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  isEditing
                      ? context.tr(
                              shared.LocaleKeys.editLeaveTitle,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Edit Leave'
                      : context.tr(
                              shared.LocaleKeys.applyLeaveTitle,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Apply Leave',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    BlocBuilder<EmployeeBloc, EmployeeState>(
                      builder: (context, employeeState) {
                        List<EmployeeEntity> employees = [];
                        if (employeeState is EmployeeLoadedState) {
                          employees = employeeState.employees;
                        }

                        return DropdownButtonFormField<int>(
                          initialValue: _selectedEmployeeId,
                          hint: Text(
                            context.tr(
                                  shared.LocaleKeys.selectEmployeeHint,
                                  track: shared
                                      .TrackConstants
                                      .staffManagementPageTrack,
                                ) ??
                                'Select Employee',
                          ),
                          validator: (val) => val == null
                              ? context.tr(
                                      shared.LocaleKeys.selectEmployeeError,
                                      track: shared
                                          .TrackConstants
                                          .staffManagementPageTrack,
                                    ) ??
                                    'Please select an employee'
                              : null,
                          items: employees.map((e) {
                            return DropdownMenuItem<int>(
                              value: e.id,
                              child: Text(e.name ?? 'Unnamed'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedEmployeeId = val;
                              if (val != null) {
                                _selectedEmployeeName = employees
                                    .firstWhere((e) => e.id == val)
                                    .name;
                              }
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _leaveType,
                      items: [
                        DropdownMenuItem(
                          value: 'Casual Leave',
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.casualLeave,
                                  track: shared
                                      .TrackConstants
                                      .staffManagementPageTrack,
                                ) ??
                                'Casual Leave',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Sick Leave',
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.sickLeave,
                                  track: shared
                                      .TrackConstants
                                      .staffManagementPageTrack,
                                ) ??
                                'Sick Leave',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Paid Leave',
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.paidLeave,
                                  track: shared
                                      .TrackConstants
                                      .staffManagementPageTrack,
                                ) ??
                                'Paid Leave',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Unpaid Leave',
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.unpaidLeave,
                                  track: shared
                                      .TrackConstants
                                      .staffManagementPageTrack,
                                ) ??
                                'Unpaid Leave',
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _leaveType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      items: [
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.statusPending,
                                  track: shared
                                      .TrackConstants
                                      .staffManagementPageTrack,
                                ) ??
                                'Pending',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Approved',
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.statusApproved,
                                  track: shared
                                      .TrackConstants
                                      .staffManagementPageTrack,
                                ) ??
                                'Approved',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Rejected',
                          child: Text(
                            context.tr(
                                  shared.LocaleKeys.statusRejected,
                                  track: shared
                                      .TrackConstants
                                      .staffManagementPageTrack,
                                ) ??
                                'Rejected',
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _status = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // New field: Start DateTime
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: widget.leave?.startDateTime != null
                              ? DateTime.tryParse(
                                      widget.leave!.startDateTime!,
                                    ) ??
                                    DateTime.now()
                              : DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (!mounted) return;
                        if (picked != null) {
                          _startDateTimeController.text = picked
                              .toIso8601String();
                        }
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _startDateTimeController,
                          decoration: InputDecoration(
                            labelText: 'Start DateTime',
                            hintText: 'Select start date',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // New field: End DateTime
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: widget.leave?.endDateTime != null
                              ? DateTime.tryParse(widget.leave!.endDateTime!) ??
                                    DateTime.now()
                              : DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (!mounted) return;
                        if (picked != null) {
                          _endDateTimeController.text = picked
                              .toIso8601String();
                        }
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _endDateTimeController,
                          decoration: InputDecoration(
                            labelText: 'End DateTime',
                            hintText: 'Select end date',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.leaveReasonLabel,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Reason',
                        hintText:
                            context.tr(
                              shared.LocaleKeys.leaveReasonHint,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Enter leave reason',
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                final entity = LeaveEntity(
                                  id: widget.leave?.id,
                                  employeeId: _selectedEmployeeId ??
                                      widget.leave?.employeeId,
                                  employeeName: _selectedEmployeeName ??
                                      widget.leave?.employeeName,
                                  leaveType: _leaveType,
                                  status: _status,
                                  reason: _reasonController.text.trim(),
                                  startDateTime:
                                      _startDateTimeController.text.isNotEmpty
                                      ? _startDateTimeController.text
                                      : null,
                                  endDateTime:
                                      _endDateTimeController.text.isNotEmpty
                                      ? _endDateTimeController.text
                                      : null,
                                  createdDate:
                                      widget.leave?.createdDate ??
                                      DateTime.now().toIso8601String(),
                                );
                                widget.onSubmit(entity);
                                Navigator.pop(context);
                              }
                            },
                            child: Text(isEditing ? 'Save' : 'Apply'),
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
      ],
    );
  }
}
