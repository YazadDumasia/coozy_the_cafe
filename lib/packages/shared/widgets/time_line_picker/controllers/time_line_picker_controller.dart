import 'package:flutter/material.dart';
import '../models/time_slot.dart';

class TimeLinePickerController extends ChangeNotifier {
  List<TimeSlot> _selectedSlots = [];
  ScrollController? _scrollController;

  List<TimeSlot> get selectedSlots => List.unmodifiable(_selectedSlots);
  TimeSlot? get selectedSlot =>
      _selectedSlots.isNotEmpty ? _selectedSlots.first : null;

  void attachScrollController(ScrollController scrollController) {
    _scrollController = scrollController;
  }

  void detachScrollController() {
    _scrollController = null;
  }

  void selectSlot(TimeSlot slot, {bool isMultiple = false}) {
    if (slot.isDisabled || !slot.isAvailable) return;

    if (isMultiple) {
      if (_selectedSlots.contains(slot)) {
        _selectedSlots.remove(slot);
      } else {
        _selectedSlots.add(slot);
      }
    } else {
      _selectedSlots = [slot];
    }
    notifyListeners();
  }

  void selectSlots(List<TimeSlot> slots) {
    _selectedSlots = List.from(
      slots.where((s) => !s.isDisabled && s.isAvailable),
    );
    notifyListeners();
  }

  void selectRange(
    TimeSlot startSlot,
    TimeSlot endSlot,
    List<TimeSlot> allSlots,
  ) {
    final startIndex = allSlots.indexOf(startSlot);
    final endIndex = allSlots.indexOf(endSlot);

    if (startIndex == -1 || endIndex == -1) return;

    final first = startIndex <= endIndex ? startIndex : endIndex;
    final last = startIndex <= endIndex ? endIndex : startIndex;

    final range = allSlots
        .sublist(first, last + 1)
        .where((s) => !s.isDisabled && s.isAvailable)
        .toList();
    _selectedSlots = range;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSlots.clear();
    notifyListeners();
  }

  void scrollToSlot(
    int index, {
    double itemExtent = 100.0,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (_scrollController != null && _scrollController!.hasClients) {
      final targetOffset = (index * itemExtent).clamp(
        0.0,
        _scrollController!.position.maxScrollExtent,
      );
      _scrollController!.animateTo(
        targetOffset,
        duration: duration,
        curve: curve,
      );
    }
  }

  bool isSelected(TimeSlot slot) {
    return _selectedSlots.contains(slot);
  }
}
