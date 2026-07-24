import 'package:equatable/equatable.dart';

class MenuItemVariation extends Equatable {
  final int? id;
  final String? hashId;
  final int? menuItemId;
  final int? quantity;
  final String? purchaseUnit;
  final bool? isTodayAvailable;
  final double? costPrice;
  final double? sellingPrice;
  final int? stockQuantity;
  final int? sortOrderIndex;
  final String? creationDate;
  final String? modificationDate;

  const MenuItemVariation({
    this.id,
    this.hashId,
    this.menuItemId,
    this.quantity,
    this.purchaseUnit,
    this.isTodayAvailable,
    this.costPrice,
    this.sellingPrice,
    this.stockQuantity,
    this.sortOrderIndex,
    this.creationDate,
    this.modificationDate,
  });

  MenuItemVariation copyWith({
    int? id,
    String? hashId,
    int? menuItemId,
    int? quantity,
    String? purchaseUnit,
    bool? isTodayAvailable,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    int? sortOrderIndex,
    String? creationDate,
    String? modificationDate,
  }) {
    return MenuItemVariation(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      purchaseUnit: purchaseUnit ?? this.purchaseUnit,
      isTodayAvailable: isTodayAvailable ?? this.isTodayAvailable,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      sortOrderIndex: sortOrderIndex ?? this.sortOrderIndex,
      creationDate: creationDate ?? this.creationDate,
      modificationDate: modificationDate ?? this.modificationDate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    menuItemId,
    quantity,
    purchaseUnit,
    isTodayAvailable,
    costPrice,
    sellingPrice,
    stockQuantity,
    sortOrderIndex,
    creationDate,
    modificationDate,
  ];
}
