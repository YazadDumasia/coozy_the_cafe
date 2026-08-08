import 'package:drift/drift.dart';
import '../../domain/entities/inventory_item.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart' as db;

class InventoryItemModel extends InventoryItem {
  InventoryItemModel({
    super.id,
    super.hashId,
    super.name,
    super.shortDescription,
    super.purchaseUnit,
    super.currentStock,
    super.isEnabled,
    super.createdDate,
    super.modifiedDate,
  });

  factory InventoryItemModel.fromEntity(InventoryItem entity) {
    return InventoryItemModel(
      id: entity.id,
      hashId: entity.hashId,
      name: entity.name,
      shortDescription: entity.shortDescription,
      purchaseUnit: entity.purchaseUnit,
      currentStock: entity.currentStock,
      isEnabled: entity.isEnabled,
      createdDate: entity.createdDate,
      modifiedDate: entity.modifiedDate,
    );
  }

  factory InventoryItemModel.fromData(db.InventoryItem data) {
    return InventoryItemModel(
      id: data.id,
      hashId: data.hashId,
      name: data.name,
      shortDescription: data.shortDescription,
      purchaseUnit: data.purchaseUnit,
      currentStock: data.currentStock,
      isEnabled: data.isEnabled,
      createdDate: data.createdDate,
      modifiedDate: data.modifiedDate,
    );
  }

  db.InventoryTableCompanion toCompanion() {
    return db.InventoryTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      hashId: hashId == null ? const Value.absent() : Value(hashId!),
      name: name == null ? const Value.absent() : Value(name!),
      shortDescription: shortDescription == null
          ? const Value.absent()
          : Value(shortDescription!),
      purchaseUnit: purchaseUnit == null
          ? const Value.absent()
          : Value(purchaseUnit!),
      currentStock: currentStock == null
          ? const Value.absent()
          : Value(currentStock!),
      isEnabled: isEnabled == null ? const Value.absent() : Value(isEnabled!),
      createdDate: createdDate == null
          ? const Value.absent()
          : Value(createdDate!),
      modifiedDate: modifiedDate == null
          ? const Value.absent()
          : Value(modifiedDate!),
    );
  }
}
