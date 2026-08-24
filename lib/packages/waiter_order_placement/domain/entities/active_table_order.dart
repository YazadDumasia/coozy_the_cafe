import 'package:equatable/equatable.dart';

class ActiveTableOrder extends Equatable {
  final int orderId;
  final int? tableId;
  final String tableName;
  final String? tableShape;
  final String? tableLocationNotes;
  final DateTime? creationDate;
  final int pendingItemCount;
  final int cookingItemCount;
  final int servedItemCount;

  const ActiveTableOrder({
    required this.orderId,
    this.tableId,
    required this.tableName,
    this.tableShape,
    this.tableLocationNotes,
    this.creationDate,
    this.pendingItemCount = 0,
    this.cookingItemCount = 0,
    this.servedItemCount = 0,
  });

  @override
  List<Object?> get props => [
    orderId,
    tableId,
    tableName,
    tableShape,
    tableLocationNotes,
    creationDate,
    pendingItemCount,
    cookingItemCount,
    servedItemCount,
  ];
}
