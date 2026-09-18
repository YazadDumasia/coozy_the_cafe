import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import '../../domain/entities/expenditure_entity.dart';

class ExpenditureModel extends ExpenditureEntity {
  const ExpenditureModel({
    super.id,
    super.hashId,
    required super.type,
    super.categoryId,
    required super.categoryName,
    required super.amount,
    super.partyName,
    required super.date,
    super.paymentMethod,
    super.notes,
    super.referenceType,
    super.referenceId,
    super.isDeleted,
    super.createdAt,
    super.modifiedAt,
  });

  factory ExpenditureModel.fromTableData(ExpenditureTableData data) {
    return ExpenditureModel(
      id: data.id,
      hashId: data.hashId,
      type: data.type,
      categoryId: data.categoryId,
      categoryName: data.categoryName,
      amount: data.amount,
      partyName: data.partyName,
      date: data.date,
      paymentMethod: data.paymentMethod,
      notes: data.notes,
      referenceType: data.referenceType,
      referenceId: data.referenceId,
      isDeleted: data.isDeleted,
      createdAt: data.createdAt,
      modifiedAt: data.modifiedAt,
    );
  }

  ExpendituresTableCompanion toCompanion() {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    return ExpendituresTableCompanion(
      id: id == null ? const Value.absent() : Value(id!),
      hashId: Value(hashId ?? const Uuid().v4()),
      type: Value(type),
      categoryId: categoryId == null ? const Value.absent() : Value(categoryId),
      categoryName: Value(categoryName),
      amount: Value(amount),
      partyName: Value(partyName),
      date: Value(date),
      paymentMethod: Value(paymentMethod),
      notes: Value(notes),
      referenceType: Value(referenceType),
      referenceId: referenceId == null
          ? const Value.absent()
          : Value(referenceId),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt ?? nowIso),
      modifiedAt: Value(modifiedAt ?? nowIso),
    );
  }
}
