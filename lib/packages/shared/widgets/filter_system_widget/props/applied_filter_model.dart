// Importing filter_item_model.dart file that consists of FilterItemModel class.

// Declaring AppliedFilterModel class with three instance variables: filterKey, filterTitle (can be nullable), and applied List of FilterItemModel objects.
import 'props.dart';

class AppliedFilterModel {
  // Constructor with named parameters: filterKey, applied (required), and filterTitle(optional).
  AppliedFilterModel({
    required this.filterKey,
    required this.applied,
    this.filterTitle,
  });
  final dynamic filterKey;
  final String? filterTitle;
  final List<FilterItemModel> applied;

  // Method that returns a Map object consisting of applied filters list and their filter key and title.
  Map<String, dynamic> toMap() {
    return (<String, dynamic>{
      'applied_filter': applied.map((e) => e.toMap()).toList(),
      'filter_key': filterKey,
      'filter_title': filterTitle,
    });
  }

  @override
  String toString() {
    return 'AppliedFilterModel{filterKey: $filterKey, filterTitle: $filterTitle, applied: $applied}';
  }
}
