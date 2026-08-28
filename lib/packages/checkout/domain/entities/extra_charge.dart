import 'package:equatable/equatable.dart';

class ExtraCharge extends Equatable {
  final String id;
  final String name;
  final double value;
  final bool isPercentage;
  final bool isDefaultAdd;

  const ExtraCharge({
    required this.id,
    required this.name,
    required this.value,
    this.isPercentage = false,
    this.isDefaultAdd = false,
  });

  ExtraCharge copyWith({
    String? id,
    String? name,
    double? value,
    bool? isPercentage,
    bool? isDefaultAdd,
  }) {
    return ExtraCharge(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      isPercentage: isPercentage ?? this.isPercentage,
      isDefaultAdd: isDefaultAdd ?? this.isDefaultAdd,
    );
  }

  @override
  List<Object?> get props => [id, name, value, isPercentage, isDefaultAdd];
}
