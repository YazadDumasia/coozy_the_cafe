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
    return await into(customersTable)
        .insert(customer, mode: InsertMode.replace);
  }

  /// Get a single customer by ID
  Future<Customer?> getCustomer(int id) async {
    final query = select(customersTable)..where((t) => t.id.equals(id));
    return await query.getSingleOrNull();
  }

  /// Get a single customer by phone number
  Future<Customer?> getCustomerByPhoneNumber(String phoneNumber) async {
    final query = select(customersTable)
      ..where((t) => t.phoneNumber.equals(phoneNumber))
      ..limit(1);
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

  // ─────────────────────────────────────────────────────────────────────────
  // Customer Loyalty & Rewards Queries
  // ─────────────────────────────────────────────────────────────────────────

  /// Get loyalty summary for a customer
  Future<Map<String, dynamic>?> getCustomerLoyalty(int customerId) async {
    final rows = await customSelect(
      '''
      SELECT * FROM customer_loyalty WHERE customer_id = ? LIMIT 1;
      ''',
      variables: [Variable.withInt(customerId)],
    ).get();

    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first.data);
  }

  /// Ensure customer loyalty record exists or initialize it
  Future<void> ensureCustomerLoyaltyRecord(int customerId) async {
    await customStatement(
      '''
      INSERT OR IGNORE INTO customer_loyalty (
        customer_id, points_balance, lifetime_points_earned, lifetime_points_redeemed,
        tier, total_spent, total_visits, created_at, modified_at
      ) VALUES (?, 0, 0, 0, 'Bronze', 0.0, 0, datetime('now'), datetime('now'));
      ''',
      [customerId],
    );
  }

  /// Add loyalty points earned from an order
  Future<void> addLoyaltyPoints({
    required int customerId,
    required int points,
    required double billAmount,
    int? orderId,
    int? invoiceId,
    String? notes,
  }) async {
    await transaction(() async {
      await ensureCustomerLoyaltyRecord(customerId);

      // 1. Insert transaction log
      await customStatement(
        '''
        INSERT INTO loyalty_transactions (
          customer_id, order_id, invoice_id, transaction_type,
          points, bill_amount, notes, created_date
        ) VALUES (?, ?, ?, 'EARNED', ?, ?, ?, datetime('now'));
        ''',
        [customerId, orderId, invoiceId, points, billAmount, notes ?? 'Order reward'],
      );

      // 2. Update loyalty balance, spend, visits, and recalculate Tier
      final loyalty = await getCustomerLoyalty(customerId);
      final currentLifetimeEarned = (loyalty?['lifetime_points_earned'] as num?)?.toInt() ?? 0;
      final newLifetimeEarned = currentLifetimeEarned + points;

      String newTier = 'Bronze';
      if (newLifetimeEarned >= 2000) {
        newTier = 'VIP';
      } else if (newLifetimeEarned >= 1000) {
        newTier = 'Gold';
      } else if (newLifetimeEarned >= 500) {
        newTier = 'Silver';
      }

      await customStatement(
        '''
        UPDATE customer_loyalty
        SET points_balance = points_balance + ?,
            lifetime_points_earned = lifetime_points_earned + ?,
            total_spent = total_spent + ?,
            total_visits = total_visits + 1,
            tier = ?,
            last_visit_date = datetime('now'),
            modified_at = datetime('now')
        WHERE customer_id = ?;
        ''',
        [points, points, billAmount, newTier, customerId],
      );
    });
  }

  /// Redeem loyalty points as discount
  Future<bool> redeemLoyaltyPoints({
    required int customerId,
    required int pointsToRedeem,
    int? orderId,
    int? invoiceId,
    String? notes,
  }) async {
    return await transaction(() async {
      final loyalty = await getCustomerLoyalty(customerId);
      if (loyalty == null) return false;

      final currentBalance = (loyalty['points_balance'] as num?)?.toInt() ?? 0;
      if (currentBalance < pointsToRedeem) return false;

      // 1. Insert transaction log
      await customStatement(
        '''
        INSERT INTO loyalty_transactions (
          customer_id, order_id, invoice_id, transaction_type,
          points, notes, created_date
        ) VALUES (?, ?, ?, 'REDEEMED', ?, ?, datetime('now'));
        ''',
        [customerId, orderId, invoiceId, pointsToRedeem, notes ?? 'Points redemption discount'],
      );

      // 2. Deduct from balance
      await customStatement(
        '''
        UPDATE customer_loyalty
        SET points_balance = points_balance - ?,
            lifetime_points_redeemed = lifetime_points_redeemed + ?,
            modified_at = datetime('now')
        WHERE customer_id = ?;
        ''',
        [pointsToRedeem, pointsToRedeem, customerId],
      );

      return true;
    });
  }

  /// Get transaction history for customer
  Future<List<Map<String, dynamic>>> getLoyaltyTransactions(int customerId) async {
    final rows = await customSelect(
      '''
      SELECT * FROM loyalty_transactions
      WHERE customer_id = ?
      ORDER BY created_date DESC, id DESC
      LIMIT 50;
      ''',
      variables: [Variable.withInt(customerId)],
    ).get();

    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }
}
