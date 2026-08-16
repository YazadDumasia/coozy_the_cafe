import 'package:equatable/equatable.dart';

enum TableStatus { empty, occupied, pendingBill }

extension TableStatusX on TableStatus {
  String get label {
    switch (this) {
      case TableStatus.empty:
        return 'Empty';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.pendingBill:
        return 'Pending Bill';
    }
  }
}

class TableEntity extends Equatable {
  final int? id;
  final String name;
  final String? colorValue;
  final int sortOrderIndex;
  final int nosOfChairs;
  final TableStatus status;

  const TableEntity({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.sortOrderIndex,
    required this.nosOfChairs,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    colorValue,
    sortOrderIndex,
    nosOfChairs,
    status,
  ];
}
