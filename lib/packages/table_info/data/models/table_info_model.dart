import 'package:drift/drift.dart' hide TableInfo;
import '../../domain/entities/table_info.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';

class TableInfoModel extends TableInfo {
  const TableInfoModel({
    super.id,
    super.name,
    super.colorValue,
    super.sortOrderIndex,
    super.nosOfChairs,
  });

  factory TableInfoModel.fromEntity(TableInfo entity) {
    return TableInfoModel(
      id: entity.id,
      name: entity.name,
      colorValue: entity.colorValue,
      sortOrderIndex: entity.sortOrderIndex,
      nosOfChairs: entity.nosOfChairs,
    );
  }

  factory TableInfoModel.fromTableInfoData(TableInfoData data) {
    return TableInfoModel(
      id: data.id,
      name: data.name,
      colorValue: data.colorValue,
      sortOrderIndex: data.sortOrderIndex,
      nosOfChairs: data.nosOfChairs,
    );
  }

  TableInfoTableCompanion toCompanion() {
    return TableInfoTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      name: name == null ? const Value.absent() : Value(name!),
      colorValue: colorValue == null
          ? const Value.absent()
          : Value(colorValue!),
      sortOrderIndex: sortOrderIndex == null
          ? const Value.absent()
          : Value(sortOrderIndex!),
      nosOfChairs: nosOfChairs == null
          ? const Value.absent()
          : Value(nosOfChairs!),
    );
  }
}
