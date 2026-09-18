import 'package:equatable/equatable.dart';

class ExpenditureEntity extends Equatable {
  final int? id;
  final String? hashId;
  final String type; // 'EXPENSE' or 'INCOME'
  final int? categoryId;
  final String categoryName;
  final double amount;
  final String? partyName; // Staff, vendor, or customer name
  final String date; // ISO8601 string
  final String? paymentMethod;
  final String? notes;
  final String? referenceType; // 'MANUAL', 'PURCHASE', 'SALARY', 'ORDER'
  final int? referenceId;
  final bool isDeleted;
  final String? createdAt;
  final String? modifiedAt;

  const ExpenditureEntity({
    this.id,
    this.hashId,
    required this.type,
    this.categoryId,
    required this.categoryName,
    required this.amount,
    this.partyName,
    required this.date,
    this.paymentMethod,
    this.notes,
    this.referenceType = 'MANUAL',
    this.referenceId,
    this.isDeleted = false,
    this.createdAt,
    this.modifiedAt,
  });

  ExpenditureEntity copyWith({
    int? id,
    String? hashId,
    String? type,
    int? categoryId,
    String? categoryName,
    double? amount,
    String? partyName,
    String? date,
    String? paymentMethod,
    String? notes,
    String? referenceType,
    int? referenceId,
    bool? isDeleted,
    String? createdAt,
    String? modifiedAt,
  }) {
    return ExpenditureEntity(
      id: id ?? this.id,
      hashId: hashId ?? this.hashId,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      partyName: partyName ?? this.partyName,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    hashId,
    type,
    categoryId,
    categoryName,
    amount,
    partyName,
    date,
    paymentMethod,
    notes,
    referenceType,
    referenceId,
    isDeleted,
    createdAt,
    modifiedAt,
  ];
}
