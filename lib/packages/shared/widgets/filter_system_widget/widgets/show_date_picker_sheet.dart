import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Function to show a Cupertino Date and Time Picker
Future<DateTime?> showDatePickerSheet({
  required BuildContext context,
  required CupertinoDatePickerMode pickerMode,
  required DateTime initialDate,
  Color? backgroundColor,
  DateTime? minimumDate,
  DateTime? maximumDate,
  DatePickerDateOrder? dateOrder,
  DateFormat? dateFormat,
  String? textButtonCancel,
  String? textButtonOkay,
}) async {
  // Completer to handle the asynchronous operation
  final Completer<DateTime?> completer = Completer();
  DateTime selectedDate = initialDate;

  // Show a modal bottom sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Container(
      color: backgroundColor ?? Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Row for Cancel and OK buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    completer.complete(null); // User canceled
                    Navigator.pop(context);
                  },
                  child: Text(
                    textButtonCancel ?? 'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    completer.complete(selectedDate); // Return selected date
                    Navigator.pop(context);
                  },
                  child: Text(textButtonOkay ?? 'OK'),
                ),
              ),
            ],
          ),
          // CupertinoDatePicker widget
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initialDate,
              minimumDate: minimumDate,
              maximumDate: maximumDate,
              dateOrder: dateOrder ?? DatePickerDateOrder.dmy,
              onDateTimeChanged: (DateTime newDate) {
                selectedDate = dateFormat!.tryParse(newDate.toIso8601String())!;
              },
            ),
          ),
        ],
      ),
    ),
  );

  // Return the selected date when the future completes
  return completer.future;
}

// Function to show a Cupertino Time Picker
Future<TimeOfDay?> showTimePickerSheet({
  required BuildContext context,
  bool use24hFormat = false,
  int minuteInterval = 1,
  Color? backgroundColor,
  TimeOfDay? initialTime,
  String? textButtonCancel,
  String? textButtonOkay,
}) async {
  // Completer to handle the asynchronous operation
  final Completer<TimeOfDay?> completer = Completer();
  TimeOfDay selectedTime = initialTime ?? TimeOfDay.now();

  // Show a modal bottom sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Container(
      color: backgroundColor ?? Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Row for Cancel and OK buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    completer.complete(null); // User canceled
                    Navigator.pop(context);
                  },
                  child: Text(textButtonCancel ?? 'Cancel'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    completer.complete(selectedTime); // Return selected time
                    Navigator.pop(context);
                  },
                  child: Text(textButtonOkay ?? 'OK'),
                ),
              ),
            ],
          ),
          // CupertinoDatePicker widget for time
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime.now().copyWith(
                hour: selectedTime.hour,
                minute: selectedTime.minute,
              ),
              use24hFormat: use24hFormat,
              minuteInterval: minuteInterval,
              onDateTimeChanged: (DateTime newDate) {
                selectedTime = TimeOfDay.fromDateTime(
                  newDate,
                ); // Update the selected time
              },
            ),
          ),
        ],
      ),
    ),
  );

  // Return the selected time when the future completes
  return completer.future;
}

/*
// Usage example for date and time picker:
Future<void> showExample(BuildContext context) async {
  // Show date and time picker
  DateTime? selectedDate = await showDatePickerSheet(
    context: context,
    pickerMode: CupertinoDatePickerMode.dateAndTime,
    initialDate: DateTime.now(),
  );

  if (selectedDate != null) {
    print('Selected Date: $selectedDate');
  } else {
    print('Date selection canceled');
  }

  // Show time picker
  TimeOfDay? selectedTime = await showTimePickerSheet(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (selectedTime != null) {
    print('Selected Time: ${selectedTime.format(context)}');
  } else {
    print('Time selection canceled');
  }
}
*/
