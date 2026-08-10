import 'package:drift/drift.dart';
import '../../domain/entities/purchase_record.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart' as db;

class PurchaseRecordModel extends PurchaseRecord {
  const PurchaseRecordModel({
    super.id,
    super.hashId,
    super.inventoryId,
    super.name,
    super.purchaseUnit,
    super.purchaseQty,
    super.purchaseDateTime,
    super.purchasePrice,
    super.createdDate,
    super.modifiedDate,
    super.currentStock,
  });

  factory PurchaseRecordModel.fromEntity(PurchaseRecord entity) {
    return PurchaseRecordModel(
      id: entity.id,
      hashId: entity.hashId,
      inventoryId: entity.inventoryId,
      name: entity.name,
      purchaseUnit: entity.purchaseUnit,
      purchaseQty: entity.purchaseQty,
      purchaseDateTime: entity.purchaseDateTime,
      purchasePrice: entity.purchasePrice,
      createdDate: entity.createdDate,
      modifiedDate: entity.modifiedDate,
      currentStock: entity.currentStock,
    );
  }

  factory PurchaseRecordModel.fromData(
    db.PurchaseRecord data, {
    double? currentStock,
  }) {
    return PurchaseRecordModel(
      id: data.id,
      hashId: data.hashId,
      inventoryId: data.inventoryId,
      name: data.name,
      purchaseUnit: data.purchaseUnit,
      purchaseQty: data.purchaseQty,
      purchaseDateTime: data.purchaseDateTime,
      purchasePrice: data.purchasePrice,
      createdDate: data.createdDate,
      modifiedDate: data.modifiedDate,
      currentStock: currentStock,
    );
  }

  db.PurchaseTableCompanion toCompanion() {
    return db.PurchaseTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      hashId: hashId == null ? const Value.absent() : Value(hashId!),
      inventoryId: inventoryId == null
          ? const Value.absent()
          : Value(inventoryId!),
      name: name == null ? const Value.absent() : Value(name!),
      purchaseUnit: purchaseUnit == null
          ? const Value.absent()
          : Value(purchaseUnit!),
      purchaseQty: purchaseQty == null
          ? const Value.absent()
          : Value(purchaseQty!),
      purchaseDateTime: purchaseDateTime == null
          ? const Value.absent()
          : Value(purchaseDateTime!),
      purchasePrice: purchasePrice == null
          ? const Value.absent()
          : Value(purchasePrice!),
      createdDate: createdDate == null
          ? const Value.absent()
          : Value(createdDate!),
      modifiedDate: modifiedDate == null
          ? const Value.absent()
          : Value(modifiedDate!),
    );
  }

  @override
  PurchaseRecordModel copyWith({
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
    double? currentStock,
  }) {
    return PurchaseRecordModel(
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
      currentStock: currentStock ?? this.currentStock,
    );
  }
}
