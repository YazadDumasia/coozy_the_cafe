/// Layout options for TimeLinePicker
enum TimelineLayoutMode {
  /// Single line horizontal scrollable list
  horizontal,

  /// Single line vertical scrollable list
  vertical,

  /// Multi-line grid layout with customizable cross axis count
  grid,

  /// Flexible wrap layout adapting dynamically to container width
  wrap,
}

/// Selection modes for TimeLinePicker
enum TimeSelectionMode {
  /// Only one time slot can be selected at a time
  single,

  /// Multiple time slots can be selected independently
  multiple,

  /// Selecting a start and end range of time slots
  range,
}
