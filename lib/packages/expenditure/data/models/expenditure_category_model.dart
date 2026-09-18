import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import '../../domain/entities/expenditure_category_entity.dart';

class ExpenditureCategoryModel extends ExpenditureCategoryEntity {
  const ExpenditureCategoryModel({
    super.id,
    super.hashId,
    required super.name,
    required super.type,
    super.iconCodePoint,
    super.iconFontFamily,
    super.colorHex,
    super.isCustom,
    super.isEnabled,
    super.createdAt,
  });

  factory ExpenditureCategoryModel.fromTableData(
    ExpenditureCategoryTableData data,
  ) {
    return ExpenditureCategoryModel(
      id: data.id,
      hashId: data.hashId,
      name: data.name,
      type: data.type,
      iconCodePoint: data.iconCodePoint,
      iconFontFamily: data.iconFontFamily,
      colorHex: data.colorHex,
      isCustom: data.isCustom,
      isEnabled: data.isEnabled,
      createdAt: data.createdAt,
    );
  }

  ExpenditureCategoriesTableCompanion toCompanion() {
    return ExpenditureCategoriesTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      hashId: Value(hashId ?? const Uuid().v4()),
      name: Value(name),
      type: Value(type),
      iconCodePoint: Value(iconCodePoint),
      iconFontFamily: Value(iconFontFamily),
      colorHex: Value(colorHex),
      isCustom: Value(isCustom),
      isEnabled: Value(isEnabled),
      createdAt: Value(createdAt ?? DateTime.now().toUtc().toIso8601String()),
    );
  }
}
