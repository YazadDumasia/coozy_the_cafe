import 'package:equatable/equatable.dart';

class Discount extends Equatable {
  final String id;
  final String name;
  final double value;
  final bool isPercentage;
  final bool isDefaultAdd;

  const Discount({
    required this.id,
    required this.name,
    required this.value,
    this.isPercentage = false,
    this.isDefaultAdd = false,
  });

  Discount copyWith({
    String? id,
    String? name,
    double? value,
    bool? isPercentage,
    bool? isDefaultAdd,
  }) {
    return Discount(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      isPercentage: isPercentage ?? this.isPercentage,
      isDefaultAdd: isDefaultAdd ?? this.isDefaultAdd,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'value': value,
        'isPercentage': isPercentage,
        'isDefaultAdd': isDefaultAdd,
      };

  factory Discount.fromJson(Map<String, dynamic> json) => Discount(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
        isPercentage: json['isPercentage'] == true,
        isDefaultAdd: json['isDefaultAdd'] == true,
      );

  @override
  List<Object?> get props => [id, name, value, isPercentage, isDefaultAdd];
}
