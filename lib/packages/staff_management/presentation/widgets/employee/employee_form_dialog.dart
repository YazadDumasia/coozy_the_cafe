import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import '../../../domain/entities/staff_entities.dart';

class EmployeeFormDialog extends StatefulWidget {
  final EmployeeEntity? employee;
  final Function(EmployeeEntity entity) onSubmit;

  const EmployeeFormDialog({super.key, this.employee, required this.onSubmit});

  static Future<void> show(
    BuildContext context, {
    EmployeeEntity? employee,
    required Function(EmployeeEntity entity) onSubmit,
  }) async {
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
        minHeight: MediaQuery.of(context).size.height * 0.40,
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      builder: (dialogContext) {
        return EmployeeFormDialog(employee: employee, onSubmit: onSubmit);
      },
    );
  }

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _positionController;
  late TextEditingController _salaryController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _idProofController;
  late TextEditingController _idProofNumberController;
  late TextEditingController _totalLeavesController;
  // New controllers for additional fields
  late TextEditingController _joiningDateController;
  late TextEditingController _leavingDateController;
  late TextEditingController _startWorkingTimeController;
  late TextEditingController _endWorkingTimeController;
  late TextEditingController _workingHoursController;
  final FocusNode _phoneFocusNode = FocusNode();
  String? _isoCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _emailController = TextEditingController(
      text: widget.employee?.email ?? '',
    );
    _positionController = TextEditingController(
      text: widget.employee?.position ?? '',
    );
    _salaryController = TextEditingController(
      text: widget.employee?.salary != null
          ? widget.employee!.salary.toString()
          : '',
    );
    _addressLine1Controller = TextEditingController(
      text: widget.employee?.addressLine1 ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: widget.employee?.addressLine2 ?? '',
    );
    _idProofController = TextEditingController(
      text: widget.employee?.idProof ?? '',
    );
    _idProofNumberController = TextEditingController(
      text: widget.employee?.idProofNumber ?? '',
    );
    _totalLeavesController = TextEditingController(
      text: widget.employee?.totalLeaves != null
          ? widget.employee!.totalLeaves.toString()
          : '',
    );
    // Initialize new field controllers
    _joiningDateController = TextEditingController(
      text: widget.employee?.joiningDate ?? '',
    );
    _leavingDateController = TextEditingController(
      text: widget.employee?.leavingDate ?? '',
    );
    _startWorkingTimeController = TextEditingController(
      text: widget.employee?.startWorkingTime ?? '',
    );
    _endWorkingTimeController = TextEditingController(
      text: widget.employee?.endWorkingTime ?? '',
    );
    _workingHoursController = TextEditingController(
      text: widget.employee?.workingHours ?? '',
    );

    _startWorkingTimeController.addListener(_calculateAndSetWorkingHours);
    _endWorkingTimeController.addListener(_calculateAndSetWorkingHours);

    String? dbIsoCode =
        widget.employee?.isoCode; // The db saves phone code like "+91"
    final phone = widget.employee?.phoneNumber ?? '';

    String? determinedIsoCode;

    // First try to get country by ISO code (e.g., "IN" or "US")
    if (dbIsoCode != null && dbIsoCode.isNotEmpty) {
      try {
        final country = shared.CountryPickerUtils.getCountryByIsoCode(
          dbIsoCode,
        );
        determinedIsoCode = country.isoCode;
      } catch (_) {}
    }

    // Next try to get country by phone code (e.g., "+91" or "91")
    if (determinedIsoCode == null &&
        dbIsoCode != null &&
        dbIsoCode.isNotEmpty) {
      try {
        final codeToSearch = dbIsoCode.startsWith('+')
            ? dbIsoCode.substring(1)
            : dbIsoCode;
        final country = shared.CountryPickerUtils.getCountryByPhoneCode(
          codeToSearch,
        );
        determinedIsoCode = country.isoCode;
      } catch (_) {}
    }

    // Fallback: parse complete phone number if unable to determine from dbIsoCode
    if (determinedIsoCode == null && phone.isNotEmpty) {
      try {
        final parsed = shared.PhoneNumber.fromCompleteNumber(
          completeNumber: phone.startsWith('+') ? phone : '+$phone',
        );
        if (parsed.countryISOCode.isNotEmpty) {
          determinedIsoCode = parsed.countryISOCode;
        }
      } catch (_) {
        determinedIsoCode = 'IN';
      }
    }

    _isoCode = determinedIsoCode ?? 'IN';

    // Ensure _phoneController only contains the national number
    String initialPhoneNumber = phone;
    if (_isoCode != null) {
      try {
        final country = shared.CountryPickerUtils.getCountryByIsoCode(
          _isoCode!,
        );
        final dialCode = '+${country.phoneCode}';
        if (initialPhoneNumber.startsWith(dialCode)) {
          initialPhoneNumber = initialPhoneNumber
              .substring(dialCode.length)
              .trim();
        } else if (initialPhoneNumber.startsWith(country.phoneCode)) {
          initialPhoneNumber = initialPhoneNumber
              .substring(country.phoneCode.length)
              .trim();
        }
      } catch (_) {}
    }

    _phoneController = TextEditingController(text: initialPhoneNumber);
  }

  void _calculateAndSetWorkingHours() {
    final computed = _calculateWorkingDuration(
      _startWorkingTimeController.text,
      _endWorkingTimeController.text,
    );
    if (computed != 'N/A') {
      _workingHoursController.text = computed;
    }
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

  @override
  void dispose() {
    _startWorkingTimeController.removeListener(_calculateAndSetWorkingHours);
    _endWorkingTimeController.removeListener(_calculateAndSetWorkingHours);
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _idProofController.dispose();
    _idProofNumberController.dispose();
    _totalLeavesController.dispose();
    _phoneFocusNode.dispose();
    // Dispose new controllers
    _joiningDateController.dispose();
    _leavingDateController.dispose();
    _startWorkingTimeController.dispose();
    _endWorkingTimeController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.employee != null;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 10,
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
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    isEditing
                        ? context.tr(
                                shared.LocaleKeys.editEmployeeTitle,
                                track: shared
                                    .TrackConstants
                                    .staffManagementPageTrack,
                              ) ??
                              'Edit Employee'
                        : context.tr(
                                shared.LocaleKeys.addEmployeeTitle,
                                track: shared
                                    .TrackConstants
                                    .staffManagementPageTrack,
                              ) ??
                              'Add Employee',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ],
          ),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.employeeNameLabel,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Employee Name',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.employeeNameHint,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Enter employee name',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? context.tr(
                              shared.LocaleKeys.employeeNameError,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Enter employee name'
                      : null,
                ),
                const SizedBox(height: 10),
                shared.PhoneNumberTextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  showDropdownIcon: true,
                  showCountryFlag: true,
                  initialCountryCode: _isoCode,
                  flagsButtonMargin: const EdgeInsets.all(10),
                  isCountryButtonPersistent: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    labelText:
                        context.tr(
                          shared.LocaleKeys.commonPhoneNumberLabel,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Phone Number',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.commonCommonPhoneNumberHint,
                          track: shared.TrackConstants.commonTrack,
                        ) ??
                        'Enter your phone number.',
                    border: const OutlineInputBorder(),
                  ),
                  onCountryChanged: (shared.Country country) {
                    setState(() {
                      _isoCode = country.isoCode;
                    });
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (phoneNumber) {
                    if (phoneNumber == null ||
                        phoneNumber.number.trim().isEmpty ||
                        phoneNumber.number == '') {
                      return context.tr(
                            shared
                                .LocaleKeys
                                .commonCommonPhoneNumberValidatorErrorEmptyMsg,
                            track: shared.TrackConstants.commonTrack,
                          ) ??
                          'Please enter your phone number.';
                    } else {
                      try {
                        phoneNumber.isValidNumber();
                        return null;
                      } catch (_) {
                        return context.tr(
                              shared
                                  .LocaleKeys
                                  .commonPhoneNumberValidatorErrorMsg,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'Please enter a valid phone number.';
                      }
                    }
                  },
                  invalidNumberMessage:
                      context.tr(
                        shared.LocaleKeys.commonPhoneNumberValidatorErrorMsg,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'Please enter a valid phone number.',
                  priorityList: <shared.Country>[
                    shared.CountryPickerUtils.getCountryByIsoCode('IN'),
                    shared.CountryPickerUtils.getCountryByIsoCode('US'),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.employeeEmailLabel,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Email Address',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.employeeEmailHint,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Enter email address',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr(
                            shared.LocaleKeys.employeeEmailError,
                            track:
                                shared.TrackConstants.staffManagementPageTrack,
                          ) ??
                          'Please enter your email address';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return context.tr(
                            shared.LocaleKeys.employeeEmailInvalidError,
                            track:
                                shared.TrackConstants.staffManagementPageTrack,
                          ) ??
                          'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.addressLine1Label,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Address Line 1',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.addressLine1Hint,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Enter address line 1',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressLine2Controller,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.addressLine2Label,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Address Line 2',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.addressLine2Hint,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Enter address line 2',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _idProofController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.idProofLabel,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'ID Proof (e.g. Passport, License)',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.idProofHint,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Enter ID proof type',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _idProofNumberController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.idProofNumberLabel,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'ID Proof Number',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.idProofNumberHint,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Enter ID proof number',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _totalLeavesController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.totalLeavesLabel,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Total Number of Leaves',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.totalLeavesHint,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Enter total leaves allocated',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 10),
                TextFormField(
                  controller: _positionController,
                  decoration: InputDecoration(
                    labelText:
                        context.tr(
                          shared.LocaleKeys.employeePositionLabel,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Position',
                    hintText:
                        context.tr(
                          shared.LocaleKeys.employeePositionHint,
                          track: shared.TrackConstants.staffManagementPageTrack,
                        ) ??
                        'Enter job position',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _salaryController,
                  decoration: InputDecoration(
                    labelText: context.tr(
                      shared.LocaleKeys.employeeSalaryLabel,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ),
                    hintText: context.tr(
                      shared.LocaleKeys.employeeSalaryHint,
                      track: shared.TrackConstants.staffManagementPageTrack,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 15),
                // Joining Date
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _joiningDateController,
                  builder: (context, val, child) {
                    return TextFormField(
                      controller: _joiningDateController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime initialDate =
                            DateTime.tryParse(_joiningDateController.text) ??
                            DateTime.now();
                        DateTime tempPickedDate = initialDate;
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        TextButton(
                                          child: Text(
                                            context.tr(
                                                  shared
                                                      .LocaleKeys
                                                      .commonCancel,
                                                  track: shared
                                                      .TrackConstants
                                                      .commonTrack,
                                                ) ??
                                                'Cancel',
                                          ),
                                          onPressed: () => Navigator.pop(ctx),
                                        ),
                                        TextButton(
                                          child: Text(
                                            context.tr(
                                                  shared.LocaleKeys.commonDone,
                                                  track: shared
                                                      .TrackConstants
                                                      .commonTrack,
                                                ) ??
                                                'Done',
                                          ),
                                          onPressed: () {
                                            _joiningDateController.text =
                                                DateFormat(
                                                  'dd-MM-yyyy',
                                                ).format(tempPickedDate);
                                            Navigator.pop(ctx);
                                          },
                                        ),
                                      ],
                                    ).paddingOnly(
                                      top: 15,
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                    ),
                                    Expanded(
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        backgroundColor: Theme.of(
                                          ctx,
                                        ).colorScheme.surface,
                                        dateOrder: DatePickerDateOrder.dmy,
                                        initialDateTime: initialDate,
                                        onDateTimeChanged: (DateTime newDate) {
                                          tempPickedDate = newDate;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.joiningDateLabel,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Joining Date',
                        border: const OutlineInputBorder(),
                        suffixIcon: val.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _joiningDateController.clear(),
                                child: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Leaving Date
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _leavingDateController,
                  builder: (context, val, child) {
                    return TextFormField(
                      controller: _leavingDateController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime initialDate =
                            DateTime.tryParse(_leavingDateController.text) ??
                            DateTime.now();
                        DateTime tempPickedDate = initialDate;
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        TextButton(
                                          child: Text(
                                            context.tr(
                                                  shared
                                                      .LocaleKeys
                                                      .commonCancel,
                                                  track: shared
                                                      .TrackConstants
                                                      .staffManagementPageTrack,
                                                ) ??
                                                'Cancel',
                                          ),
                                          onPressed: () => Navigator.pop(ctx),
                                        ),
                                        TextButton(
                                          child: Text(
                                            context.tr(
                                                  shared.LocaleKeys.commonDone,
                                                  track: shared
                                                      .TrackConstants
                                                      .staffManagementPageTrack,
                                                ) ??
                                                'Done',
                                          ),
                                          onPressed: () {
                                            _leavingDateController.text =
                                                DateFormat(
                                                  'dd-MM-yyyy',
                                                ).format(tempPickedDate);
                                            Navigator.pop(ctx);
                                          },
                                        ),
                                      ],
                                    ).paddingOnly(
                                      top: 15,
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                    ),
                                    Expanded(
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        backgroundColor: Theme.of(
                                          ctx,
                                        ).colorScheme.surface,
                                        dateOrder: DatePickerDateOrder.dmy,
                                        initialDateTime: initialDate,
                                        onDateTimeChanged: (DateTime newDate) {
                                          tempPickedDate = newDate;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.leavingDateLabel,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Leaving Date',
                        border: const OutlineInputBorder(),

                        suffixIcon: val.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _leavingDateController.clear(),
                                child: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Start Working Time
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _startWorkingTimeController,
                  builder: (context, val, child) {
                    return TextFormField(
                      controller: _startWorkingTimeController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime now = DateTime.now();
                        final DateTime initialDateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          12,
                          0,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        TextButton(
                                          child: Text(
                                            context.tr(
                                                  shared
                                                      .LocaleKeys
                                                      .commonCancel,
                                                  track: shared
                                                      .TrackConstants
                                                      .commonTrack,
                                                ) ??
                                                'Cancel',
                                          ),
                                          onPressed: () => Navigator.pop(ctx),
                                        ),
                                        TextButton(
                                          child: Text(
                                            context.tr(
                                                  shared.LocaleKeys.commonDone,
                                                  track: shared
                                                      .TrackConstants
                                                      .commonTrack,
                                                ) ??
                                                'Done',
                                          ),
                                          onPressed: () {
                                            final tod = TimeOfDay(
                                              hour: tempPickedDateTime.hour,
                                              minute: tempPickedDateTime.minute,
                                            );
                                            _startWorkingTimeController.text =
                                                DateFormat('hh:mm a').format(
                                                  DateTime(
                                                    now.year,
                                                    now.month,
                                                    now.day,
                                                    tod.hour,
                                                    tod.minute,
                                                  ),
                                                );
                                            Navigator.pop(ctx);
                                          },
                                        ),
                                      ],
                                    ).paddingOnly(
                                      top: 15,
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                    ),
                                    Expanded(
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.time,
                                        backgroundColor: Theme.of(
                                          ctx,
                                        ).colorScheme.surface,
                                        initialDateTime: initialDateTime,
                                        onDateTimeChanged:
                                            (DateTime newDateTime) {
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
                      },
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.startingShiftTimeLabel,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Starting Shift Time',
                        border: const OutlineInputBorder(),
                        suffixIcon: val.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () =>
                                    _startWorkingTimeController.clear(),
                                child: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // End Working Time
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _endWorkingTimeController,
                  builder: (context, val, child) {
                    return TextFormField(
                      controller: _endWorkingTimeController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime now = DateTime.now();
                        final DateTime initialDateTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          12,
                          0,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        TextButton(
                                          child: Text(
                                            context.tr(
                                                  shared
                                                      .LocaleKeys
                                                      .commonCancel,
                                                  track: shared
                                                      .TrackConstants
                                                      .commonTrack,
                                                ) ??
                                                'Cancel',
                                          ),
                                          onPressed: () => Navigator.pop(ctx),
                                        ),
                                        TextButton(
                                          child: Text(
                                            context.tr(
                                                  shared.LocaleKeys.commonDone,
                                                  track: shared
                                                      .TrackConstants
                                                      .commonTrack,
                                                ) ??
                                                'Done',
                                          ),
                                          onPressed: () {
                                            final tod = TimeOfDay(
                                              hour: tempPickedDateTime.hour,
                                              minute: tempPickedDateTime.minute,
                                            );
                                            _endWorkingTimeController.text =
                                                DateFormat('hh:mm a').format(
                                                  DateTime(
                                                    now.year,
                                                    now.month,
                                                    now.day,
                                                    tod.hour,
                                                    tod.minute,
                                                  ),
                                                );
                                            Navigator.pop(ctx);
                                          },
                                        ),
                                      ],
                                    ).paddingOnly(
                                      top: 15,
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                    ),
                                    Expanded(
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.time,
                                        backgroundColor: Theme.of(
                                          ctx,
                                        ).colorScheme.surface,
                                        initialDateTime: initialDateTime,
                                        onDateTimeChanged:
                                            (DateTime newDateTime) {
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
                      },
                      decoration: InputDecoration(
                        labelText:
                            context.tr(
                              shared.LocaleKeys.endingShiftTimeLabel,
                              track: shared
                                  .TrackConstants
                                  .staffManagementPageTrack,
                            ) ??
                            'Ending Shift Time',
                        border: const OutlineInputBorder(),
                        suffixIcon: val.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () => _endWorkingTimeController.clear(),
                                child: const Icon(Icons.clear),
                              )
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // ValueListenableBuilder for total working time display
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _workingHoursController,
                  builder: (context, val, child) {
                    final String displayVal = val.text.isNotEmpty
                        ? val.text
                        : 'N/A';
                    return Row(
                      children: <Widget>[
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: <InlineSpan>[
                                TextSpan(
                                  text: 'Total Working time: ',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: displayVal,
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                          if (_formKey.currentState?.validate() ?? false) {
                            final rawPhone = _phoneController.text.trim();
                            String dialCode = '+91';
                            if (_isoCode != null && _isoCode!.isNotEmpty) {
                              try {
                                final country =
                                    shared
                                        .CountryPickerUtils.getCountryByIsoCode(
                                      _isoCode!,
                                    );
                                dialCode = '+${country.phoneCode}';
                              } catch (_) {}
                            }

                            final String formattedPhone =
                                rawPhone.startsWith('+')
                                ? rawPhone
                                : '$dialCode $rawPhone';

                            final newEntity = EmployeeEntity(
                              id: widget.employee?.id,
                              name: _nameController.text.trim(),
                              phoneNumber: formattedPhone,
                              isoCode: _isoCode,
                              email: _emailController.text.trim(),
                              addressLine1: _addressLine1Controller.text.trim(),
                              addressLine2: _addressLine2Controller.text.trim(),
                              idProof: _idProofController.text.trim(),
                              idProofNumber: _idProofNumberController.text
                                  .trim(),
                              totalLeaves: int.tryParse(
                                _totalLeavesController.text.trim(),
                              ),
                              position: _positionController.text.trim(),
                              salary: double.tryParse(
                                _salaryController.text.trim(),
                              ),
                              joiningDate:
                                  _joiningDateController.text.isNotEmpty
                                  ? _joiningDateController.text
                                  : null,
                              leavingDate:
                                  _leavingDateController.text.isNotEmpty
                                  ? _leavingDateController.text
                                  : null,
                              startWorkingTime:
                                  _startWorkingTimeController.text.isNotEmpty
                                  ? _startWorkingTimeController.text
                                  : null,
                              endWorkingTime:
                                  _endWorkingTimeController.text.isNotEmpty
                                  ? _endWorkingTimeController.text
                                  : null,
                              workingHours:
                                  _workingHoursController.text.isNotEmpty
                                  ? _workingHoursController.text
                                  : null,
                              createdDate: widget.employee?.createdDate,
                              modificationDate:
                                  widget.employee?.modificationDate,
                              isDeleted: widget.employee?.isDeleted,
                            );
                            widget.onSubmit(newEntity);
                            Navigator.pop(context);
                          }
                        },
                        child: Text(isEditing ? 'Save' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
