import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final bool isEnabled;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isEnabled = true,
  });

  PaymentMethod copyWith({
    String? id,
    String? name,
    IconData? icon,
    bool? isEnabled,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, isEnabled];
}
