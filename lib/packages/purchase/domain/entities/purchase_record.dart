import 'package:equatable/equatable.dart';

class PurchaseRecord extends Equatable {
  final int? id;
  final String? hashId;
  final int? inventoryId;
  final String? name;
  final String? purchaseUnit;
  final double? purchaseQty;
  final String? purchaseDateTime;
  final double? purchasePrice;
  final String? createdDate;
  final String? modifiedDate;

  const PurchaseRecord({
    this.id,
    this.hashId,
    this.inventoryId,
    this.name,
    this.purchaseUnit,
    this.purchaseQty,
    this.purchaseDateTime,
    this.purchasePrice,
    this.createdDate,
    this.modifiedDate,
  });

  PurchaseRecord copyWith({
    int? id,
    String? hashId,
    int? inventoryId,
    String? name,
    String? purchaseUnit,
    double? purchaseQty,
    String? purchaseDateTime,
    double? purchasePrice,
    String? createdDate,
    String? modifiedDate,
  }) {
    return PurchaseRecord(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      inventoryId: inventoryId ?? this.inventoryId,
      name: name ?? this.name,
      purchaseUnit: purchaseUnit ?? this.purchaseUnit,
      purchaseQty: purchaseQty ?? this.purchaseQty,
      purchaseDateTime: purchaseDateTime ?? this.purchaseDateTime,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    inventoryId,
    name,
    purchaseUnit,
    purchaseQty,
    purchaseDateTime,
    purchasePrice,
    createdDate,
    modifiedDate,
  ];
}
