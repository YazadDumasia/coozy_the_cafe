import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../bloc/employee/employee_bloc.dart';
import '../bloc/employee/employee_event_state.dart';
import '../../domain/entities/staff_entities.dart';

class AttendanceFormDialog extends StatefulWidget {
  final AttendanceEntity? attendance;
  final Function(AttendanceEntity entity) onSubmit;

  const AttendanceFormDialog({
    super.key,
    this.attendance,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    AttendanceEntity? attendance,
    required Function(AttendanceEntity entity) onSubmit,
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
        minHeight: MediaQuery.of(context).size.height * 0.45,
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      builder: (dialogContext) {
        return BlocProvider.value(
          value: employeeBloc,
          child: AttendanceFormDialog(
            attendance: attendance,
            onSubmit: onSubmit,
          ),
        );
      },
    );
  }

  @override
  State<AttendanceFormDialog> createState() => _AttendanceFormDialogState();
}

class _AttendanceFormDialogState extends State<AttendanceFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _checkInController;
  late TextEditingController _checkOutController;
  final FocusNode _checkInFocusNode = FocusNode();
  final FocusNode _checkOutFocusNode = FocusNode();

  EmployeeEntity? _selectedEmployee;
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;

  late ValueNotifier<String> _totalWorkingTimeNotifier;
  late ValueNotifier<EmployeeEntity?> _employeeNotifier;

  @override
  void initState() {
    super.initState();
    _checkInController = TextEditingController(
      text: widget.attendance?.checkIn ?? '',
    );
    _checkOutController = TextEditingController(
      text: widget.attendance?.checkOut ?? '',
    );

    if (widget.attendance?.checkIn != null &&
        widget.attendance!.checkIn!.isNotEmpty) {
      try {
        final parsed = DateFormat.Hm().parse(widget.attendance!.checkIn!);
        _checkInTime = TimeOfDay.fromDateTime(parsed);
      } catch (_) {}
    }

    if (widget.attendance?.checkOut != null &&
        widget.attendance!.checkOut!.isNotEmpty) {
      try {
        final parsed = DateFormat.Hm().parse(widget.attendance!.checkOut!);
        _checkOutTime = TimeOfDay.fromDateTime(parsed);
      } catch (_) {}
    }

    _totalWorkingTimeNotifier = ValueNotifier<String>(
      _calculateWorkingDuration(
        _checkInController.text,
        _checkOutController.text,
      ),
    );
    _employeeNotifier = ValueNotifier<EmployeeEntity?>(null);

    _checkInController.addListener(_updateCalculations);
    _checkOutController.addListener(_updateCalculations);
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _checkInFocusNode.dispose();
    _checkOutFocusNode.dispose();
    _totalWorkingTimeNotifier.dispose();
    _employeeNotifier.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    _totalWorkingTimeNotifier.value = _calculateWorkingDuration(
      _checkInController.text,
      _checkOutController.text,
    );
  }

  DateTime? _parseTimeString(String text) {
    if (text.trim().isEmpty) return null;
    final cleanText = text.trim();
    final formats = [
      DateFormat('hh:mm a'),
      DateFormat('h:mm a'),
      DateFormat.jm(),
      DateFormat.Hm(),
    ];
    for (final fmt in formats) {
      try {
        return fmt.parse(cleanText);
      } catch (_) {}
    }
    return null;
  }

  String _calculateWorkingDuration(String fromTime, String toTime) {
    final start = _parseTimeString(fromTime);
    final end = _parseTimeString(toTime);
    if (start == null || end == null) return 'N/A';
    Duration difference = end.difference(start);
    if (difference.isNegative ||
        (difference.inMinutes == 0 && fromTime != toTime)) {
      difference += const Duration(days: 1);
    }
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    if (minutes == 0) {
      return '$hours hours';
    }
    return '$hours hours $minutes mins';
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  Future<void> _pickTime({required bool isCheckIn}) async {
    final TimeOfDay initialTod = isCheckIn
        ? (_checkInTime ?? TimeOfDay.now())
        : (_checkOutTime ?? TimeOfDay.now());

    final DateTime now = DateTime.now();
    final DateTime initialDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      initialTod.hour,
      initialTod.minute,
    );
    DateTime tempPickedDateTime = initialDateTime;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext ctx) {
        return ColoredBox(
          color: Theme.of(ctx).colorScheme.surface,
          child: SizedBox(
            width: MediaQuery.of(ctx).size.width,
            height: MediaQuery.of(ctx).size.height * 0.40,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonCancel,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Cancel',
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    TextButton(
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonDone,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Done',
                      ),
                      onPressed: () {
                        final selectedTod = TimeOfDay(
                          hour: tempPickedDateTime.hour,
                          minute: tempPickedDateTime.minute,
                        );
                        if (isCheckIn) {
                          _checkInTime = selectedTod;
                          _checkInController.text = _formatTimeOfDay(
                            selectedTod,
                          );
                        } else {
                          _checkOutTime = selectedTod;
                          _checkOutController.text = _formatTimeOfDay(
                            selectedTod,
                          );
                        }
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    backgroundColor: Theme.of(ctx).colorScheme.surface,
                    initialDateTime: initialDateTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempPickedDateTime = newDateTime;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.attendance != null;
    final employeeName =
        widget.attendance?.employeeName ?? _selectedEmployee?.name ?? '';

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
                  isEditing ? 'Edit Attendance' : 'Add Attendance',
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    if (isEditing) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: RichText(
                          text: TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: 'Employee Name: ',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: employeeName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      BlocBuilder<EmployeeBloc, EmployeeState>(
                        builder: (context, employeeState) {
                          List<EmployeeEntity> employees = [];
                          if (employeeState is EmployeeLoadedState) {
                            employees = employeeState.employees;
                          }

                          if (_selectedEmployee == null &&
                              widget.attendance != null) {
                            try {
                              _selectedEmployee = employees.firstWhere(
                                (e) => e.id == widget.attendance!.employeeId,
                              );
                              _employeeNotifier.value = _selectedEmployee;
                            } catch (_) {}
                          }

                          return DropdownButtonFormField<EmployeeEntity>(
                            initialValue: _selectedEmployee,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedEmployee = newValue;
                                _employeeNotifier.value = newValue;
                              });
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return employees.map<Widget>((
                                EmployeeEntity employee,
                              ) {
                                return Text(
                                  employee.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                );
                              }).toList();
                            },
                            items: employees.map<DropdownMenuItem<EmployeeEntity>>((
                              EmployeeEntity employee,
                            ) {
                              final isDesktop =
                                  shared.ResponsiveLayout.isDesktop(context);
                              return DropdownMenuItem<EmployeeEntity>(
                                value: employee,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: employee.name ?? ''),
                                      if (employee.position != null &&
                                          employee.position!.isNotEmpty)
                                        TextSpan(
                                          text: isDesktop
                                              ? ' - ${employee.position}'
                                              : '\nPosition: ${employee.position}',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: isDesktop ? 1 : 2,
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              labelText: context.tr(
                                    shared.LocaleKeys.employeeNameLabel,
                                    track: shared.TrackConstants.staffManagementPageTrack,
                                  ) ??
                                  'Employee name',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null && !isEditing) {
                                return context.tr(
                                      shared.LocaleKeys.selectEmployeeError,
                                      track: shared.TrackConstants.staffManagementPageTrack,
                                    ) ??
                                    'Please select an employee name.';
                              }
                              return null;
                            },

                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],

                    TextFormField(
                      controller: _checkInController,
                      focusNode: _checkInFocusNode,
                      readOnly: true,
                      onTap: () => _pickTime(isCheckIn: true),
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.startingShiftTimeLabel,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Starting Shift Time',
                        suffixIcon: _checkInController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _checkInTime = null;
                                    _checkInController.clear();
                                  });
                                },
                                child: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.tr(
                                shared.LocaleKeys.startingShiftTimeError,
                                track: shared
                                    .TrackConstants
                                    .staffManagementPageTrack,
                              ) ??
                              'Please enter start working time.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _checkOutController,
                      focusNode: _checkOutFocusNode,
                      readOnly: true,
                      onTap: () => _pickTime(isCheckIn: false),
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.endingShiftTimeLabel,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Ending Shift Time',
                        suffixIcon: _checkOutController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _checkOutTime = null;
                                    _checkOutController.clear();
                                  });
                                },
                                child: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<String>(
                      valueListenable: _totalWorkingTimeNotifier,
                      builder: (context, totalWorkingTime, child) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text:
                                          context.tr(
                                            shared
                                                .LocaleKeys
                                                .totalWorkingTimeLabel,
                                            track: shared
                                                .TrackConstants
                                                .staffManagementPageTrack,
                                          ) ??
                                          'Total Working time: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    TextSpan(
                                      text: totalWorkingTime,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<EmployeeEntity?>(
                      valueListenable: _employeeNotifier,
                      builder: (context, employee, child) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text:
                                          context.tr(
                                            shared
                                                .LocaleKeys
                                                .employeeWorkingDurationsLabel,
                                            track: shared
                                                .TrackConstants
                                                .staffManagementPageTrack,
                                          ) ??
                                          'Employee Working Durations: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    TextSpan(
                                      text: 'N/A',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (!(_formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              _formKey.currentState?.save();

                              final nowIso = DateTime.now().toIso8601String();
                              final entity = AttendanceEntity(
                                id: widget.attendance?.id,
                                employeeId:
                                    _selectedEmployee?.id ??
                                    widget.attendance?.employeeId,
                                employeeName:
                                    _selectedEmployee?.name ??
                                    widget.attendance?.employeeName,
                                date: widget.attendance?.date ?? nowIso,
                                status: widget.attendance?.status ?? 'Present',
                                checkIn: _checkInController.text,
                                checkOut: _checkOutController.text,
                                notes: widget.attendance?.notes,
                                createdDate:
                                    widget.attendance?.createdDate ?? nowIso,
                                modificationDate: nowIso,
                              );

                              widget.onSubmit(entity);
                              Navigator.of(context).pop();
                            },
                            child: Text(isEditing ? 'Save' : 'Add'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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
