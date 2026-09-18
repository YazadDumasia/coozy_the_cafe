import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'expenditure_dao.g.dart';

@DriftAccessor(tables: [ExpenditureCategoriesTable, ExpendituresTable])
class ExpenditureDao extends DatabaseAccessor<CoozyDatabase>
    with _$ExpenditureDaoMixin {
  ExpenditureDao(super.db);

  // ----------------------------------------------------
  // Safeguard & Table Initialization
  // ----------------------------------------------------

  Future<void> _ensureTablesAndDefaults() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS expenditure_categories (
        created_by INTEGER,
        updated_by INTEGER,
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        hash_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon_code_point INTEGER,
        icon_font_family TEXT,
        color_hex TEXT,
        is_custom INTEGER NOT NULL DEFAULT 0,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      );
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS expenditures (
        created_by INTEGER,
        updated_by INTEGER,
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        hash_id TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        category_id INTEGER REFERENCES expenditure_categories (id) ON DELETE SET NULL,
        category_name TEXT NOT NULL,
        amount REAL NOT NULL,
        party_name TEXT,
        date TEXT NOT NULL,
        payment_method TEXT,
        notes TEXT,
        reference_type TEXT,
        reference_id INTEGER,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        modified_at TEXT NOT NULL
      );
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_expenditures_date ON expenditures (date DESC, id DESC);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_expenditure_categories_type ON expenditure_categories (type);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_expenditure_categories_name ON expenditure_categories (name);',
    );

    try {
      final existing = await select(expenditureCategoriesTable).get();
      if (existing.isEmpty) {
        final defaultExpenses = [
          'Tax',
          'Fuel',
          'Food',
          'Bill',
          'Transportation',
          'Insurance',
          'Salary',
          'Rent',
          'Repairs',
          'Commissions',
          'Advertising',
          'Fee',
          'Interest',
          'Loan',
          'Supplies',
          'Transfer',
          'Contract',
          'Miscellaneous',
          'Disposable',
          'Bread',
          'Vegetables',
          'Milk',
          'Cold Drinks',
          'Sauce',
        ];
        final defaultIncomes = [
          'Profit',
          'Salary',
          'Awards',
          'Rental',
          'Sale',
          'Refund',
          'Lottery',
          'Dividend',
          'Investment',
          'Interest',
          'Commission',
          'Fee',
          'Loan',
          'Miscellaneous',
        ];
        await batch((b) {
          for (final exp in defaultExpenses) {
            b.insert(
              expenditureCategoriesTable,
              ExpenditureCategoriesTableCompanion.insert(
                name: exp,
                type: 'EXPENSE',
                isCustom: const Value(false),
                isEnabled: const Value(true),
              ),
            );
          }
          for (final inc in defaultIncomes) {
            b.insert(
              expenditureCategoriesTable,
              ExpenditureCategoriesTableCompanion.insert(
                name: inc,
                type: 'INCOME',
                isCustom: const Value(false),
                isEnabled: const Value(true),
              ),
            );
          }
        });
      }
    } catch (_) {
      // Table seeding already handled or in progress
    }
  }

  // ----------------------------------------------------
  // Category Operations
  // ----------------------------------------------------

  Future<List<ExpenditureCategoryTableData>> getCategoriesByType(
    String type,
  ) async {
    await _ensureTablesAndDefaults();
    final query = select(expenditureCategoriesTable)
      ..where((t) => t.type.equals(type) & t.isEnabled.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
      ]);
    return query.get();
  }

  Stream<List<ExpenditureCategoryTableData>> watchCategoriesByType(
    String type,
  ) {
    final query = select(expenditureCategoriesTable)
      ..where((t) => t.type.equals(type) & t.isEnabled.equals(true))
      ..orderBy([
        (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
      ]);
    return query.watch();
  }

  Future<int> insertCategory(
    ExpenditureCategoriesTableCompanion companion,
  ) async {
    await _ensureTablesAndDefaults();
    return into(expenditureCategoriesTable).insert(companion);
  }

  Future<bool> deleteCategory(int id) async {
    await _ensureTablesAndDefaults();
    final count = await (delete(
      expenditureCategoriesTable,
    )..where((t) => t.id.equals(id))).go();
    return count > 0;
  }

  // ----------------------------------------------------
  // Expenditure / Transaction Operations
  // ----------------------------------------------------

  Future<int> insertExpenditure(ExpendituresTableCompanion companion) async {
    await _ensureTablesAndDefaults();
    return into(expendituresTable).insert(companion);
  }

  Future<bool> updateExpenditure(ExpendituresTableCompanion companion) {
    return update(expendituresTable).replace(companion);
  }

  Future<bool> softDeleteExpenditure(int id) async {
    final count =
        await (update(expendituresTable)..where((t) => t.id.equals(id))).write(
          const ExpendituresTableCompanion(isDeleted: Value(true)),
        );
    return count > 0;
  }

  Future<List<ExpenditureTableData>> getExpendituresByDateRange({
    required String startIso,
    required String endIso,
    String? type,
    int? limit,
    int? offset,
  }) async {
    await _ensureTablesAndDefaults();
    final query = select(expendituresTable)
      ..where((t) {
        var predicate =
            t.isDeleted.equals(false) &
            t.date.isBiggerOrEqualValue(startIso) &
            t.date.isSmallerOrEqualValue(endIso);
        if (type != null && type.isNotEmpty) {
          predicate = predicate & t.type.equals(type);
        }
        return predicate;
      })
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  Stream<List<ExpenditureTableData>> watchExpendituresByDateRange({
    required String startIso,
    required String endIso,
  }) {
    final query = select(expendituresTable)
      ..where(
        (t) =>
            t.isDeleted.equals(false) &
            t.date.isBiggerOrEqualValue(startIso) &
            t.date.isSmallerOrEqualValue(endIso),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  // ----------------------------------------------------
  // Aggregation & Chart Summaries
  // ----------------------------------------------------

  Future<Map<String, double>> getTotalsByDateRange({
    required String startIso,
    required String endIso,
  }) async {
    await _ensureTablesAndDefaults();
    final incomeSum = expendituresTable.amount.sum();
    final incomeQuery = selectOnly(expendituresTable)..addColumns([incomeSum]);
    incomeQuery.where(
      expendituresTable.isDeleted.equals(false) &
          expendituresTable.type.equals('INCOME') &
          expendituresTable.date.isBiggerOrEqualValue(startIso) &
          expendituresTable.date.isSmallerOrEqualValue(endIso),
    );
    final totalIncome =
        await incomeQuery.map((row) => row.read(incomeSum)).getSingle() ?? 0.0;

    final expenseSum = expendituresTable.amount.sum();
    final expenseQuery = selectOnly(expendituresTable)
      ..addColumns([expenseSum]);
    expenseQuery.where(
      expendituresTable.isDeleted.equals(false) &
          expendituresTable.type.equals('EXPENSE') &
          expendituresTable.date.isBiggerOrEqualValue(startIso) &
          expendituresTable.date.isSmallerOrEqualValue(endIso),
    );
    final totalExpense =
        await expenseQuery.map((row) => row.read(expenseSum)).getSingle() ??
        0.0;

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'net': totalIncome - totalExpense,
    };
  }

  /// Returns daily income vs expense points for line / column / area charts.
  Future<List<Map<String, dynamic>>> getDailyIncomeExpenseSummary({
    required String startIso,
    required String endIso,
  }) async {
    await _ensureTablesAndDefaults();
    const sql = '''
      SELECT 
        DATE(date) as entryDate,
        SUM(CASE WHEN type = 'INCOME' THEN amount ELSE 0 END) as totalIncome,
        SUM(CASE WHEN type = 'EXPENSE' THEN amount ELSE 0 END) as totalExpense,
        (SUM(CASE WHEN type = 'INCOME' THEN amount ELSE 0 END) - SUM(CASE WHEN type = 'EXPENSE' THEN amount ELSE 0 END)) as netFlow
      FROM expenditures
      WHERE is_deleted = 0 AND date >= ? AND date <= ?
      GROUP BY DATE(date)
      ORDER BY entryDate ASC;
    ''';
    final rows = await customSelect(
      sql,
      variables: [Variable.withString(startIso), Variable.withString(endIso)],
    ).get();
    return rows.map((r) => r.data).toList();
  }

  /// Returns category breakdown points for doughnut / pie charts.
  Future<List<Map<String, dynamic>>> getCategoryBreakdownSummary({
    required String type,
    required String startIso,
    required String endIso,
  }) async {
    await _ensureTablesAndDefaults();
    const sql = '''
      SELECT 
        category_name as categoryName,
        SUM(amount) as totalAmount,
        COUNT(*) as transactionCount
      FROM expenditures
      WHERE is_deleted = 0 AND type = ? AND date >= ? AND date <= ?
      GROUP BY category_name
      ORDER BY totalAmount DESC;
    ''';
    final rows = await customSelect(
      sql,
      variables: [
        Variable.withString(type),
        Variable.withString(startIso),
        Variable.withString(endIso),
      ],
    ).get();
    return rows.map((r) => r.data).toList();
  }
}
