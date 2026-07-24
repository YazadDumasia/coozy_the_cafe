import 'package:drift/drift.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/menu_item_variation.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart' as db;

class MenuItemModel extends MenuItem {
  const MenuItemModel({
    super.id,
    super.hashId,
    required super.name,
    required super.description,
    super.foodType,
    super.creationDate,
    super.modificationDate,
    super.duration,
    super.categoryId,
    super.subcategoryId,
    super.isTodayAvailable,
    super.isSimpleVariation,
    super.costPrice,
    super.sellingPrice,
    super.stockQuantity,
    super.quantity,
    super.purchaseUnit,
    super.sortOrderIndex,
    super.variations,
  });

  factory MenuItemModel.fromEntity(MenuItem entity) {
    return MenuItemModel(
      id: entity.id,
      hashId: entity.hashId,
      name: entity.name,
      description: entity.description,
      foodType: entity.foodType,
      creationDate: entity.creationDate,
      modificationDate: entity.modificationDate,
      duration: entity.duration,
      categoryId: entity.categoryId,
      subcategoryId: entity.subcategoryId,
      isTodayAvailable: entity.isTodayAvailable,
      isSimpleVariation: entity.isSimpleVariation,
      costPrice: entity.costPrice,
      sellingPrice: entity.sellingPrice,
      stockQuantity: entity.stockQuantity,
      quantity: entity.quantity,
      purchaseUnit: entity.purchaseUnit,
      sortOrderIndex: entity.sortOrderIndex,
      variations: entity.variations,
    );
  }

  factory MenuItemModel.fromData(
    db.MenuItem data, [
    List<MenuItemVariation>? variations,
  ]) {
    return MenuItemModel(
      id: data.id,
      hashId: data.hashId,
      name: data.name,
      description: data.description,
      foodType: data.foodType,
      creationDate: data.creationDate,
      modificationDate: data.modificationDate,
      duration: data.duration,
      categoryId: data.categoryId,
      subcategoryId: data.subcategoryId,
      isTodayAvailable: data.isTodayAvailable,
      isSimpleVariation: data.isSimpleVariation,
      costPrice: data.costPrice,
      sellingPrice: data.sellingPrice,
      stockQuantity: data.stockQuantity,
      quantity: data.quantity,
      purchaseUnit: data.purchaseUnit,
      sortOrderIndex: data.sortOrderIndex,
      variations: variations ?? [],
    );
  }

  db.MenuItemsTableCompanion toCompanion() {
    return db.MenuItemsTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      hashId: hashId == null ? const Value.absent() : Value(hashId!),
      name: Value(name),
      description: description == null
          ? const Value.absent()
          : Value(description!),
      foodType: foodType == null ? const Value.absent() : Value(foodType!),
      creationDate: creationDate == null
          ? const Value.absent()
          : Value(creationDate!),
      modificationDate: modificationDate == null
          ? const Value.absent()
          : Value(modificationDate!),
      duration: duration == null ? const Value.absent() : Value(duration!),
      categoryId: categoryId == null
          ? const Value.absent()
          : Value(categoryId!),
      subcategoryId: subcategoryId == null
          ? const Value.absent()
          : Value(subcategoryId!),
      isTodayAvailable: isTodayAvailable == null
          ? const Value.absent()
          : Value(isTodayAvailable!),
      isSimpleVariation: isSimpleVariation == null
          ? const Value.absent()
          : Value(isSimpleVariation!),
      costPrice: costPrice == null ? const Value.absent() : Value(costPrice!),
      sellingPrice: sellingPrice == null
          ? const Value.absent()
          : Value(sellingPrice!),
      stockQuantity: stockQuantity == null
          ? const Value.absent()
          : Value(stockQuantity!),
      quantity: quantity == null ? const Value.absent() : Value(quantity!),
      purchaseUnit: purchaseUnit == null
          ? const Value.absent()
          : Value(purchaseUnit!),
      sortOrderIndex: sortOrderIndex == null
          ? const Value.absent()
          : Value(sortOrderIndex!),
    );
  }
}
