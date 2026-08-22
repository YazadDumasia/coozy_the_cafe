import 'package:drift/drift.dart' hide TableInfo;
import '../../domain/entities/table_info.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';

class TableInfoModel extends TableInfo {
  const TableInfoModel({
    super.id,
    super.tableLabel,
    super.tableNo,
    super.colorValue,
    super.sortOrderIndex,
    super.nosOfChairs,
    super.isActive,
  });

  factory TableInfoModel.fromEntity(TableInfo entity) {
    return TableInfoModel(
      id: entity.id,
      tableLabel: entity.tableLabel,
      tableNo: entity.tableNo,
      colorValue: entity.colorValue,
      sortOrderIndex: entity.sortOrderIndex,
      nosOfChairs: entity.nosOfChairs,
      isActive: entity.isActive,
    );
  }

  factory TableInfoModel.fromTableInfoData(TableInfoData data) {
    return TableInfoModel(
      id: data.id,
      tableLabel: data.tableLabel,
      tableNo: data.tableNo,
      colorValue: data.colorValue,
      sortOrderIndex: data.sortOrderIndex,
      nosOfChairs: data.nosOfChairs,
      isActive: data.isActive,
    );
  }

  TableInfoTableCompanion toCompanion() {
    return TableInfoTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      tableLabel: tableLabel == null
          ? const Value.absent()
          : Value(tableLabel!),
      tableNo: tableNo == null ? const Value.absent() : Value(tableNo!),
      colorValue: colorValue == null
          ? const Value.absent()
          : Value(colorValue!),
      sortOrderIndex: sortOrderIndex == null
          ? const Value.absent()
          : Value(sortOrderIndex!),
      nosOfChairs: nosOfChairs == null
          ? const Value.absent()
          : Value(nosOfChairs!),
      isActive: isActive == null ? const Value.absent() : Value(isActive!),
    );
  }
}
