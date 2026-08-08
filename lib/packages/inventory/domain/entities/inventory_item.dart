import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class InventoryItem implements shared.ISuspensionBean {
  final int? id;
  final String? hashId;
  final String? name;
  final String? shortDescription;
  final String? purchaseUnit;
  final double? currentStock;
  final bool? isEnabled;
  final String? createdDate;
  final String? modifiedDate;

  @override
  bool isShowSuspension = false;

  InventoryItem({
    this.id,
    this.hashId,
    this.name,
    this.shortDescription,
    this.purchaseUnit,
    this.currentStock,
    this.isEnabled,
    this.createdDate,
    this.modifiedDate,
    this.isShowSuspension = false,
  });

  @override
  String getSuspensionTag() {
    if (name != null && name!.isNotEmpty) {
      final tag = name![0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(tag)) {
        return tag;
      }
    }
    return '#';
  }

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          id == other.id &&
          hashId == other.hashId &&
          name == other.name &&
          shortDescription == other.shortDescription &&
          purchaseUnit == other.purchaseUnit &&
          currentStock == other.currentStock &&
          isEnabled == other.isEnabled &&
          createdDate == other.createdDate &&
          modifiedDate == other.modifiedDate;

  @override
  int get hashCode => Object.hash(
    id,
    hashId,
    name,
    shortDescription,
    purchaseUnit,
    currentStock,
    isEnabled,
    createdDate,
    modifiedDate,
  );
}
