import 'package:drift/drift.dart';
import '../../domain/entities/menu_subcategory.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';

class MenuSubcategoryModel extends MenuSubcategory {
  const MenuSubcategoryModel({
    super.id,
    super.hashId,
    super.categoryId,
    super.name,
    super.isActive,
    super.position,
    super.createdDate,
  });

  factory MenuSubcategoryModel.fromEntity(MenuSubcategory entity) {
    return MenuSubcategoryModel(
      id: entity.id,
      hashId: entity.hashId,
      categoryId: entity.categoryId,
      name: entity.name,
      isActive: entity.isActive,
      position: entity.position,
      createdDate: entity.createdDate,
    );
  }

  factory MenuSubcategoryModel.fromData(Subcategory data) {
    return MenuSubcategoryModel(
      id: data.id,
      hashId: data.hashId,
      categoryId: data.categoryId,
      name: data.name,
      isActive: data.isActive,
      position: data.position,
      createdDate: data.createdDate,
    );
  }

  @override
  MenuSubcategoryModel copyWith({
    int? id,
    String? hashId,
    int? categoryId,
    String? name,
    bool? isActive,
    int? position,
    String? createdDate,
  }) {
    return MenuSubcategoryModel(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      position: position ?? this.position,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  SubcategoriesTableCompanion toCompanion() {
    return SubcategoriesTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      hashId: hashId == null ? const Value.absent() : Value(hashId!),
      categoryId: categoryId == null
          ? const Value.absent()
          : Value(categoryId!),
      name: name == null ? const Value.absent() : Value(name!),
      isActive: isActive == null ? const Value.absent() : Value(isActive!),
      position: position == null ? const Value.absent() : Value(position!),
      createdDate: createdDate == null
          ? const Value.absent()
          : Value(createdDate!),
    );
  }
}
