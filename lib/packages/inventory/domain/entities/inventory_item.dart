import 'package:equatable/equatable.dart';

class InventoryItem extends Equatable {
  final int? id;
  final String? hashId;
  final String? name;
  final String? shortDescription;
  final String? purchaseUnit;
  final double? currentStock;
  final bool? isEnabled;
  final String? createdDate;
  final String? modifiedDate;

  const InventoryItem({
    this.id,
    this.hashId,
    this.name,
    this.shortDescription,
    this.purchaseUnit,
    this.currentStock,
    this.isEnabled,
    this.createdDate,
    this.modifiedDate,
  });

  InventoryItem copyWith({
    int? id,
    String? hashId,
    String? name,
    String? shortDescription,
    String? purchaseUnit,
    double? currentStock,
    bool? isEnabled,
    String? createdDate,
    String? modifiedDate,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      purchaseUnit: purchaseUnit ?? this.purchaseUnit,
      currentStock: currentStock ?? this.currentStock,
      isEnabled: isEnabled ?? this.isEnabled,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    name,
    shortDescription,
    purchaseUnit,
    currentStock,
    isEnabled,
    createdDate,
    modifiedDate,
  ];
}
