import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'reports_dao.g.dart';

@DriftAccessor(
  tables: [
    InvoicesTable,
    InvoiceItemsTable,
    PaymentTransactionsTable,
    OrderItemsTable,
    InventoryTable,
    InventoryStockAdjustmentsTable,
    PurchaseTable,
    ExpendituresTable,
  ],
)
class ReportsDao extends DatabaseAccessor<CoozyDatabase>
    with _$ReportsDaoMixin {
  ReportsDao(super.db);

  // ─────────────────────────────────────────────────────────────────────────
  // Daily Sales Summary
  // Joins invoice_items → order_items to compute dailyCost & dailyProfit.
  // Excludes soft-deleted invoices.
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getDailySalesSummary(
    String startIso,
    String endIso,
  ) async {
    const sql = '''
      SELECT
        DATE(i.created_date) AS saleDate,
        COUNT(DISTINCT i.id)           AS totalInvoices,
        COALESCE(SUM(i.total_cost), 0)           AS totalSales,
        COALESCE(SUM(i.tax_cost), 0)             AS totalTax,
        COALESCE(SUM(i.discount_amount), 0)      AS totalDiscount,
        COALESCE(SUM(i.net_payment_amount), 0)   AS netTotal,
        COALESCE(SUM(ii.quantity * oi.cost_price), 0) AS dailyCost,
        COALESCE(SUM(i.net_payment_amount), 0)
          - COALESCE(SUM(ii.quantity * oi.cost_price), 0) AS dailyProfit
      FROM invoices i
      LEFT JOIN invoice_items ii ON ii.invoice_id = i.id
      LEFT JOIN order_items oi   ON oi.id = ii.order_item_id
      WHERE i.created_date >= ?
        AND i.created_date <= ?
        AND (i.is_deleted IS NULL OR i.is_deleted = 0)
      GROUP BY DATE(i.created_date)
      ORDER BY saleDate DESC
    ''';
    final rows = await customSelect(
      sql,
      variables: [Variable.withString(startIso), Variable.withString(endIso)],
    ).get();
    return rows.map((r) {
      final data = Map<String, dynamic>.from(r.data);
      final netTotal = (data['netTotal'] as num?)?.toDouble() ?? 0.0;
      final dailyCost = (data['dailyCost'] as num?)?.toDouble() ?? 0.0;
      final dailyProfit = netTotal - dailyCost;
      data['dailyProfit'] = dailyProfit;
      data['profitPercentage'] = dailyCost != 0
          ? (dailyProfit / dailyCost) * 100
          : null;
      return data;
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Monthly Sales Summary
  // Same as daily but groups by YYYY-MM.
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getMonthlySalesSummary(
    String startIso,
    String endIso,
  ) async {
    const sql = '''
      SELECT
        SUBSTR(i.created_date, 1, 7)  AS saleMonth,
        COUNT(DISTINCT i.id)           AS totalInvoices,
        COALESCE(SUM(i.total_cost), 0)           AS totalSales,
        COALESCE(SUM(i.tax_cost), 0)             AS totalTax,
        COALESCE(SUM(i.discount_amount), 0)      AS totalDiscount,
        COALESCE(SUM(i.net_payment_amount), 0)   AS netTotal,
        COALESCE(SUM(ii.quantity * oi.cost_price), 0) AS monthlyCost,
        COALESCE(SUM(i.net_payment_amount), 0)
          - COALESCE(SUM(ii.quantity * oi.cost_price), 0) AS monthlyProfit
      FROM invoices i
      LEFT JOIN invoice_items ii ON ii.invoice_id = i.id
      LEFT JOIN order_items oi   ON oi.id = ii.order_item_id
      WHERE i.created_date >= ?
        AND i.created_date <= ?
        AND (i.is_deleted IS NULL OR i.is_deleted = 0)
      GROUP BY SUBSTR(i.created_date, 1, 7)
      ORDER BY saleMonth DESC
    ''';
    final rows = await customSelect(
      sql,
      variables: [Variable.withString(startIso), Variable.withString(endIso)],
    ).get();
    return rows.map((r) {
      final data = Map<String, dynamic>.from(r.data);
      final netTotal = (data['netTotal'] as num?)?.toDouble() ?? 0.0;
      final monthlyCost = (data['monthlyCost'] as num?)?.toDouble() ?? 0.0;
      final monthlyProfit = netTotal - monthlyCost;
      data['monthlyProfit'] = monthlyProfit;
      data['profitPercentage'] = monthlyCost != 0
          ? (monthlyProfit / monthlyCost) * 100
          : null;
      return data;
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Top Selling Items
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getTopSellingItems(
    String startIso,
    String endIso, {
    int limit = 10,
  }) async {
    final sql = '''
      SELECT
        ii.item_name                          AS itemName,
        SUM(ii.quantity)                      AS totalQuantity,
        COALESCE(SUM(ii.total_price), 0)      AS totalRevenue,
        COALESCE(SUM(ii.quantity * oi.cost_price), 0) AS totalCost
      FROM invoice_items ii
      INNER JOIN invoices i ON ii.invoice_id = i.id
      LEFT JOIN  order_items oi ON oi.id = ii.order_item_id
      WHERE i.created_date >= ?
        AND i.created_date <= ?
        AND (i.is_deleted IS NULL OR i.is_deleted = 0)
      GROUP BY ii.item_name
      ORDER BY totalQuantity DESC
      LIMIT ?
    ''';
    final rows = await customSelect(
      sql,
      variables: [
        Variable.withString(startIso),
        Variable.withString(endIso),
        Variable.withInt(limit),
      ],
    ).get();
    return rows.map((r) => r.data).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Payment Mode Report
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPaymentModeReport(
    String startIso,
    String endIso,
  ) async {
    const sql = '''
      SELECT
        pt.payment_method_name            AS paymentMethodName,
        COUNT(*)                          AS transactionCount,
        COALESCE(SUM(pt.amount), 0)       AS totalAmount
      FROM payment_transactions pt
      INNER JOIN invoices i ON pt.invoice_id = i.id
      WHERE i.created_date >= ?
        AND i.created_date <= ?
        AND (i.is_deleted IS NULL OR i.is_deleted = 0)
      GROUP BY pt.payment_method_name
      ORDER BY totalAmount DESC
    ''';
    final rows = await customSelect(
      sql,
      variables: [Variable.withString(startIso), Variable.withString(endIso)],
    ).get();
    return rows.map((r) => r.data).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Sales Dashboard (KPI Summary)
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getSalesDashboard(
    String startIso,
    String endIso,
  ) async {
    const sql = '''
      SELECT
        COUNT(DISTINCT i.id)                       AS totalInvoices,
        COALESCE(SUM(i.total_cost), 0)             AS totalSales,
        COALESCE(SUM(i.tax_cost), 0)               AS totalTax,
        COALESCE(SUM(i.discount_amount), 0)        AS totalDiscount,
        COALESCE(SUM(i.net_payment_amount), 0)     AS netTotal,
        COALESCE(AVG(i.net_payment_amount), 0)     AS averageOrderValue,
        COALESCE(SUM(ii.quantity * oi.cost_price), 0) AS totalCost
      FROM invoices i
      LEFT JOIN invoice_items ii ON ii.invoice_id = i.id
      LEFT JOIN order_items oi   ON oi.id = ii.order_item_id
      WHERE i.created_date >= ?
        AND i.created_date <= ?
        AND (i.is_deleted IS NULL OR i.is_deleted = 0)
    ''';
    final row = await customSelect(
      sql,
      variables: [Variable.withString(startIso), Variable.withString(endIso)],
    ).getSingleOrNull();
    if (row == null) return {};
    final data = Map<String, dynamic>.from(row.data);
    final netTotal = (data['netTotal'] as num?)?.toDouble() ?? 0.0;
    final totalCost = (data['totalCost'] as num?)?.toDouble() ?? 0.0;
    data['totalProfit'] = netTotal - totalCost;
    data['profitPercentage'] = totalCost != 0
        ? ((netTotal - totalCost) / totalCost) * 100
        : null;
    return data;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Menu Item Sales Report (daily, for all items in range)
  // Mirrors old generateDailySalesReportForMenuItem but across all items.
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getMenuItemSalesReport(
    String startIso,
    String endIso, {
    String? itemName,
  }) async {
    final hasItemFilter = itemName != null && itemName.trim().isNotEmpty;
    final itemFilterClause = hasItemFilter ? 'AND ii.item_name = ?' : '';

    final sql =
        '''
      SELECT
        ii.item_name                                AS itemName,
        DATE(i.created_date)                        AS saleDate,
        SUM(ii.quantity)                            AS quantitySold,
        COALESCE(SUM(ii.total_price), 0)            AS totalAmount,
        COALESCE(SUM(ii.quantity * oi.cost_price), 0) AS totalCost
      FROM invoice_items ii
      INNER JOIN invoices i ON ii.invoice_id = i.id
      LEFT JOIN  order_items oi ON oi.id = ii.order_item_id
      WHERE i.created_date >= ?
        AND i.created_date <= ?
        AND (i.is_deleted IS NULL OR i.is_deleted = 0)
        $itemFilterClause
      GROUP BY ii.item_name, DATE(i.created_date)
      ORDER BY saleDate DESC, totalAmount DESC
    ''';

    final variables = <Variable>[
      Variable.withString(startIso),
      Variable.withString(endIso),
      if (hasItemFilter) Variable.withString(itemName),
    ];

    final rows = await customSelect(sql, variables: variables).get();
    return rows.map((r) {
      final data = Map<String, dynamic>.from(r.data);
      final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final totalCost = (data['totalCost'] as num?)?.toDouble() ?? 0.0;
      final profit = totalAmount - totalCost;
      data['totalProfit'] = profit;
      data['profitPercentage'] = totalAmount != 0
          ? (profit / totalAmount) * 100
          : null;
      return data;
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Analyze Menu Item Order Counts (all-time)
  // Returns total order count + revenue per menu item.
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> analyzeMenuItemOrderCounts() async {
    const sql = '''
      SELECT
        ii.item_name                          AS itemName,
        SUM(ii.quantity)                      AS totalCount,
        COALESCE(SUM(ii.total_price), 0)      AS totalRevenue,
        COALESCE(SUM(ii.quantity * oi.cost_price), 0) AS totalCost
      FROM invoice_items ii
      INNER JOIN invoices i ON ii.invoice_id = i.id
      LEFT JOIN  order_items oi ON oi.id = ii.order_item_id
      WHERE (i.is_deleted IS NULL OR i.is_deleted = 0)
      GROUP BY ii.item_name
      ORDER BY totalCount DESC
    ''';
    final rows = await customSelect(sql).get();
    return rows.map((r) => r.data).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Inventory Stock Report
  // Current stock level and unit for each active inventory item.
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getInventoryStockReport() async {
    const sql = '''
      SELECT
        id,
        name,
        current_stock AS currentStock,
        purchase_unit AS purchaseUnit,
        is_enabled AS isEnabled
      FROM inventory
      WHERE is_enabled = 1
      ORDER BY current_stock ASC, name ASC
    ''';
    final rows = await customSelect(sql).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Purchase Summary Report (by item in range)
  // Aggregate purchases: total qty bought and total spent per inventory item.
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getPurchaseSummaryReport(
    String startIso,
    String endIso,
  ) async {
    const sql = '''
      SELECT
        p.name AS itemName,
        p.purchase_unit AS purchaseUnit,
        COALESCE(SUM(p.purchase_qty), 0) AS totalQty,
        COALESCE(SUM(p.purchase_qty * p.purchase_price), 0) AS totalCost
      FROM purchase p
      WHERE p.purchase_date_time >= ?
        AND p.purchase_date_time <= ?
      GROUP BY p.name, p.purchase_unit
      ORDER BY totalCost DESC
    ''';
    final rows = await customSelect(
      sql,
      variables: [Variable.withString(startIso), Variable.withString(endIso)],
    ).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Expenditure Summary Report (by category and type in range)
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getExpenditureSummaryReport(
    String startIso,
    String endIso,
  ) async {
    const sql = '''
      SELECT
        e.type AS type,
        e.category_name AS categoryName,
        COALESCE(SUM(e.amount), 0) AS totalAmount,
        COUNT(e.id) AS transactionCount
      FROM expenditures e
      WHERE e.date >= ?
        AND e.date <= ?
        AND (e.is_deleted IS NULL OR e.is_deleted = 0)
      GROUP BY e.type, e.category_name
      ORDER BY totalAmount DESC
    ''';
    final rows = await customSelect(
      sql,
      variables: [Variable.withString(startIso), Variable.withString(endIso)],
    ).get();
    return rows.map((r) => Map<String, dynamic>.from(r.data)).toList();
  }
}
