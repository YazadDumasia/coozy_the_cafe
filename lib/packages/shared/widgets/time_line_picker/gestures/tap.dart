import 'package:flutter/material.dart';

typedef TimeChangeListener = void Function(TimeOfDay selectedTime);
typedef TimeSlotChangeListener =
    void Function(TimeOfDay startTime, TimeOfDay endTime);
