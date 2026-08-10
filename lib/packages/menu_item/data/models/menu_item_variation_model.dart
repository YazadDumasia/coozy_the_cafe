import 'package:drift/drift.dart';
import '../../domain/entities/menu_item_variation.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart' as db;

class MenuItemVariationModel extends MenuItemVariation {
  const MenuItemVariationModel({
    super.id,
    super.hashId,
    super.name,
    super.menuItemId,
    super.quantity,
    super.purchaseUnit,
    super.isTodayAvailable,
    super.costPrice,
    super.sellingPrice,
    super.stockQuantity,
    super.sortOrderIndex,
    super.creationDate,
    super.modificationDate,
  });

  factory MenuItemVariationModel.fromEntity(MenuItemVariation entity) {
    return MenuItemVariationModel(
      id: entity.id,
      hashId: entity.hashId,
      name: entity.name,
      menuItemId: entity.menuItemId,
      quantity: entity.quantity,
      purchaseUnit: entity.purchaseUnit,
      isTodayAvailable: entity.isTodayAvailable,
      costPrice: entity.costPrice,
      sellingPrice: entity.sellingPrice,
      stockQuantity: entity.stockQuantity,
      sortOrderIndex: entity.sortOrderIndex,
      creationDate: entity.creationDate,
      modificationDate: entity.modificationDate,
    );
  }

  factory MenuItemVariationModel.fromData(db.MenuItemVariation data) {
    return MenuItemVariationModel(
      id: data.id,
      hashId: data.hashId,
      name: data.name,
      menuItemId: data.menuItemId,
      quantity: data.quantity,
      purchaseUnit: data.purchaseUnit,
      isTodayAvailable: data.isTodayAvailable,
      costPrice: data.costPrice,
      sellingPrice: data.sellingPrice,
      stockQuantity: data.stockQuantity,
      sortOrderIndex: data.sortOrderIndex,
      creationDate: data.creationDate,
      modificationDate: data.modificationDate,
    );
  }

  db.MenuItemVariationsTableCompanion toCompanion() {
    return db.MenuItemVariationsTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      hashId: hashId == null ? const Value.absent() : Value(hashId!),
      name: name == null ? const Value.absent() : Value(name!),
      menuItemId: menuItemId == null
          ? const Value.absent()
          : Value(menuItemId!),
      quantity: quantity == null ? const Value.absent() : Value(quantity!),
      purchaseUnit: purchaseUnit == null
          ? const Value.absent()
          : Value(purchaseUnit!),
      isTodayAvailable: isTodayAvailable == null
          ? const Value.absent()
          : Value(isTodayAvailable!),
      costPrice: costPrice == null ? const Value.absent() : Value(costPrice!),
      sellingPrice: sellingPrice == null
          ? const Value.absent()
          : Value(sellingPrice!),
      stockQuantity: stockQuantity == null
          ? const Value.absent()
          : Value(stockQuantity!),
      sortOrderIndex: sortOrderIndex == null
          ? const Value.absent()
          : Value(sortOrderIndex!),
      creationDate: creationDate == null
          ? const Value.absent()
          : Value(creationDate!),
      modificationDate: modificationDate == null
          ? const Value.absent()
          : Value(modificationDate!),
    );
  }
}
