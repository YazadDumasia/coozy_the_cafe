import 'package:drift/drift.dart';
import '../../domain/entities/menu_category.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';

class MenuCategoryModel extends MenuCategory {
  const MenuCategoryModel({
    super.id,
    super.hashId,
    super.name,
    super.isActive,
    super.position,
    super.createdDate,
  });

  factory MenuCategoryModel.fromEntity(MenuCategory entity) {
    return MenuCategoryModel(
      id: entity.id,
      hashId: entity.hashId,
      name: entity.name,
      isActive: entity.isActive,
      position: entity.position,
      createdDate: entity.createdDate,
    );
  }

  factory MenuCategoryModel.fromData(Category data) {
    return MenuCategoryModel(
      id: data.id,
      hashId: data.hashId,
      name: data.name,
      isActive: data.isActive,
      position: data.position,
      createdDate: data.createdDate,
    );
  }

  CategoriesTableCompanion toCompanion() {
    return CategoriesTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      hashId: hashId == null ? const Value.absent() : Value(hashId!),
      name: name == null ? const Value.absent() : Value(name!),
      isActive: isActive == null ? const Value.absent() : Value(isActive!),
      position: position == null ? const Value.absent() : Value(position!),
      createdDate: createdDate == null
          ? const Value.absent()
          : Value(createdDate!),
    );
  }
}
