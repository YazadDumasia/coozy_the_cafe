import 'package:equatable/equatable.dart';

class Tax extends Equatable {
  final String id;
  final String name;
  final double ratePercent;
  final bool isDefaultAdd;

  const Tax({
    required this.id,
    required this.name,
    required this.ratePercent,
    this.isDefaultAdd = false,
  });

  Tax copyWith({
    String? id,
    String? name,
    double? ratePercent,
    bool? isDefaultAdd,
  }) {
    return Tax(
      id: id ?? this.id,
      name: name ?? this.name,
      ratePercent: ratePercent ?? this.ratePercent,
      isDefaultAdd: isDefaultAdd ?? this.isDefaultAdd,
    );
  }

  @override
  List<Object?> get props => [id, name, ratePercent, isDefaultAdd];
}
