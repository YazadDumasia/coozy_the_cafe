import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:drift/drift.dart';

import '../../domain/entities/table_entity.dart';

class TablePickerDao {
  final CoozyDatabase db;

  const TablePickerDao(this.db);

  Stream<List<TableEntity>> watchTablesWithStatus() {
    final query =
        db.select(db.tableInfoTable).join([
          leftOuterJoin(
            db.ordersTable,
            db.ordersTable.tableInfoId.equalsExp(db.tableInfoTable.id) &
                (db.ordersTable.isCanceled.isNull() |
                    db.ordersTable.isCanceled.equals(false)) &
                (db.ordersTable.isDeleted.isNull() |
                    db.ordersTable.isDeleted.equals(false)) &
                db.ordersTable.status.isNotIn([
                  'completed',
                  'paid',
                  'cancelled',
                ]),
          ),
        ])..orderBy([
          OrderingTerm(
            expression: db.tableInfoTable.sortOrderIndex,
            mode: OrderingMode.asc,
          ),
        ]);

    return query.watch().map((rows) {
      final tablesById = <int, TableEntity>{};

      for (final row in rows) {
        final table = row.readTable(db.tableInfoTable);
        final order = row.readTableOrNull(db.ordersTable);
        final status = _resolveStatus(order);
        final entity = TableEntity(
          id: table.id,
          name: table.tableLabel ?? 'Table ${table.id}',
          tableNumber: table.tableNo,
          colorValue: table.colorValue,
          sortOrderIndex: table.sortOrderIndex ?? 0,
          nosOfChairs: table.nosOfChairs ?? 0,
          status: status,
          orderCreationDate: order != null
              ? DateTime.tryParse(order.creationDate ?? '')
              : null,
        );

        final existing = tablesById[table.id];
        if (existing == null) {
          tablesById[table.id] = entity;
        } else {
          final pNew = _priority(entity.status);
          final pOld = _priority(existing.status);
          if (pNew > pOld) {
            tablesById[table.id] = entity;
          } else if (pNew == pOld && entity.orderCreationDate != null) {
            if (existing.orderCreationDate == null ||
                entity.orderCreationDate!.isAfter(
                  existing.orderCreationDate!,
                )) {
              tablesById[table.id] = entity;
            }
          }
        }
      }

      final list = tablesById.values.toList()
        ..sort((a, b) => a.sortOrderIndex.compareTo(b.sortOrderIndex));
      return list;
    });
  }

  static TableStatus _resolveStatus(Order? order) {
    if (order == null) {
      return TableStatus.empty;
    }

    final statusValue = (order.status ?? '').trim().toLowerCase();

    if (statusValue == 'completed' ||
        statusValue == 'paid' ||
        statusValue == 'cancelled') {
      return TableStatus.empty;
    }

    if (statusValue.contains('pending_payment') ||
        statusValue.contains('pending_bill')) {
      return TableStatus.pendingBill;
    }

    return TableStatus.occupied;
  }

  static int _priority(TableStatus status) {
    switch (status) {
      case TableStatus.empty:
        return 0;
      case TableStatus.reserved:
        return 1;
      case TableStatus.occupied:
        return 2;
      case TableStatus.pendingBill:
        return 3;
    }
  }
}
