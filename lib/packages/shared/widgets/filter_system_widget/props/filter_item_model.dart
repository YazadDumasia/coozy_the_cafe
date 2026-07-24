import 'package:equatable/equatable.dart';

class FilterItemModel extends Equatable {
  // Initialize the Filter Item Model with Title and Key as required parameters
  const FilterItemModel({required this.filterTitle, required this.filterKey});
  final String filterTitle;
  final dynamic filterKey;

  @override
  List<Object?> get props => <Object?>[filterTitle, filterKey];

  // Convert the Filter Item Model into a Map format with the corresponding data in it.
  Map<String, dynamic> toMap() {
    return (<String, dynamic>{
      'filter_title': filterTitle,
      'filter_key': filterKey,
    });
  }
}
