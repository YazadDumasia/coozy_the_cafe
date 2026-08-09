import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [CustomersTable, TableInfoTable])
class CustomersDao extends DatabaseAccessor<CoozyDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  /// Create a new customer
  Future<int> createCustomer(CustomersTableCompanion customer) async {
    return await into(
      customersTable,
    ).insert(customer, mode: InsertMode.replace);
  }

  /// Get a single customer by ID
  Future<Customer?> getCustomer(int id) async {
    final query = select(customersTable)..where((t) => t.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Get a list of all customers with pagination and optional search
  Future<List<Customer>?> searchCustomers({
    int pageNumber = 1,
    int limit = 20,
    String? search,
  }) async {
    final offset = (pageNumber - 1) * limit;
    final query = select(customersTable);

    query.orderBy([
      (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
    ]);
    if (search != null && search.isNotEmpty) {
      query.where(
        (t) =>
            t.name.like('%$search%') |
            t.phoneNumber.like('%$search%') |
            t.isoCode.like('%$search%'),
      );
    }
    final results = await (query..limit(limit, offset: offset)).get();
    return results.isNotEmpty ? results : null;
  }

  /// is customer exist or not
  Future<bool> isCustomerExist(String searchTerm) async {
    final query = select(customersTable)
      ..where(
        (t) =>
            t.name.like('%$searchTerm%') | t.phoneNumber.like('%$searchTerm%'),
      )
      ..limit(1);
    final results = await query.get();
    return results.isNotEmpty;
  }

  /// Update a customer
  Future<int?> updateCustomer(CustomersTableCompanion customer) async {
    await transaction(() async {
      await update(customersTable).replace(customer);
    });
    return 1;
  }

  /// Delete a customer
  Future<int?> deleteCustomer(int id) async {
    return await transaction(() async {
      // // Unlink customer from orders, invoices, reservations, and reviews to prevent foreign key constraint failures
      // await customUpdate(
      //   'UPDATE orders_table SET customer_id = NULL WHERE customer_id = ?',
      //   variables: [Variable.withInt(id)],
      //   updates: {db.ordersTable},
      // );
      // await customUpdate(
      //   'UPDATE invoices_table SET customer_id = NULL WHERE customer_id = ?',
      //   variables: [Variable.withInt(id)],
      //   updates: {db.invoicesTable},
      // );
      // await customUpdate(
      //   'UPDATE reservations_table SET customer_id = NULL WHERE customer_id = ?',
      //   variables: [Variable.withInt(id)],
      //   updates: {db.reservationsTable},
      // );
      // await customUpdate(
      //   'UPDATE menu_item_reviews_table SET customer_id = NULL WHERE customer_id = ?',
      //   variables: [Variable.withInt(id)],
      //   updates: {db.menuItemReviewsTable},
      // );

      return await (delete(customersTable)..where((t) => t.id.equals(id))).go();
    });
  }

  // TableInfo CRUD operations

  /// Create a new table info
  Future<int?> addTableInfo(TableInfoTableCompanion newTableInfo) async {
    return await transaction(() async {
      // Get max sortOrderIndex
      final maxIndexExpr = tableInfoTable.sortOrderIndex.max();
      final maxQuery = selectOnly(tableInfoTable)..addColumns([maxIndexExpr]);
      final maxRow = await maxQuery.getSingle();
      final maxIndex = maxRow.read(maxIndexExpr) ?? -1;

      final nextIndex = maxIndex + 1;

      final toInsert = newTableInfo.copyWith(sortOrderIndex: Value(nextIndex));

      await into(tableInfoTable).insert(toInsert, mode: InsertMode.replace);

      return nextIndex;
    });
  }

  /// Get a list of all table infos
  Future<List<TableInfoData>?> getTableInfos() async {
    final query = select(tableInfoTable);
    final results =
        await (query..orderBy([
              (t) => OrderingTerm(
                expression: t.sortOrderIndex,
                mode: OrderingMode.asc,
              ),
            ]))
            .get();
    return results.isNotEmpty ? results : null;
  }

  /// Get table infos page (default: 20 per page, page 1)
  Future<List<TableInfoData>?> getTableInfosPage({
    int limit = 20,
    int pageNumber = 1,
  }) async {
    final offset = (pageNumber - 1) * limit;
    final query = select(tableInfoTable);
    final results =
        await (query
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.sortOrderIndex,
                  mode: OrderingMode.asc,
                ),
              ])
              ..limit(limit, offset: offset))
            .get();
    return results.isNotEmpty ? results : null;
  }

  /// Get a single table info by ID
  Future<TableInfoData?> getTableInfo(int id) async {
    final query = select(tableInfoTable)..where((t) => t.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Update a table info
  Future<int?> updateTableInfo(TableInfoTableCompanion tableInfo) async {
    await transaction(() async {
      await update(tableInfoTable).replace(tableInfo);
    });
    return 1;
  }

  /// Get table info record count (for pagination)
  Future<int> getTableInfoRecordCount() async {
    final countExpr = tableInfoTable.id.count();
    final query = selectOnly(tableInfoTable)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Delete a table info
  Future<int?> deleteTableInfo(TableInfoData model) async {
    return await transaction(() async {
      final int sortRecordIndexToDelete = model.sortOrderIndex ?? 0;

      final rowsAffected = await (delete(
        tableInfoTable,
      )..where((t) => t.id.equals(model.id))).go();

      final colName = tableInfoTable.sortOrderIndex.name;
      await customUpdate(
        'UPDATE ${tableInfoTable.actualTableName} SET $colName = $colName - 1 WHERE $colName > ?',
        variables: [Variable.withInt(sortRecordIndexToDelete)],
        updates: {tableInfoTable},
      );

      return rowsAffected > 0 ? rowsAffected : null;
    });
  }
}
