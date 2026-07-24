import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'reports_dao.g.dart';

@DriftAccessor(
  tables: [InvoicesTable, InvoiceItemsTable, PaymentTransactionsTable],
)
class ReportsDao extends DatabaseAccessor<CoozyDatabase>
    with _$ReportsDaoMixin {
  ReportsDao(super.db);

  Future<List<Map<String, dynamic>>> getDailySalesSummary(
    String startIso,
    String endIso,
  ) async {
    String sql = '''
      SELECT 
        DATE(created_date) as saleDate,
        COUNT(*) as totalInvoices,
        SUM(total_cost) as totalSales,
        SUM(tax_cost) as totalTax,
        SUM(discount_amount) as totalDiscount,
        SUM(net_payment_amount) as netTotal
      FROM invoices
      WHERE created_date >= ? AND created_date <= ?
    ''';
    List<Variable> vars = [
      Variable.withString(startIso),
      Variable.withString(endIso),
    ];
    sql += '''
      GROUP BY DATE(created_date)
      ORDER BY saleDate DESC
      ''';
    final rows = await customSelect(sql, variables: vars).get();
    return rows.map((r) => r.data).toList();
  }

  Future<List<Map<String, dynamic>>> getTopSellingItems(
    String startIso,
    String endIso, {
    int limit = 10,
  }) async {
    String sql = '''
      SELECT 
        ii.item_name as itemName,
        SUM(ii.quantity) as totalQuantity,
        SUM(ii.total_price) as totalRevenue
      FROM invoice_items ii
      INNER JOIN invoices i ON ii.invoice_id = i.id
      WHERE i.created_date >= ? AND i.created_date <= ?
    ''';
    List<Variable> vars = [
      Variable.withString(startIso),
      Variable.withString(endIso),
    ];
    sql += '''
      GROUP BY ii.item_name
      ORDER BY totalQuantity DESC
      LIMIT ?
      ''';
    vars.add(Variable.withInt(limit));

    final rows = await customSelect(sql, variables: vars).get();
    return rows.map((r) => r.data).toList();
  }

  Future<List<Map<String, dynamic>>> getPaymentModeReport(
    String startIso,
    String endIso,
  ) async {
    String sql = '''
      SELECT 
        pt.payment_method_name as paymentMethodName,
        COUNT(*) as transactionCount,
        SUM(pt.amount) as totalAmount
      FROM payment_transactions pt
      INNER JOIN invoices i ON pt.invoice_id = i.id
      WHERE i.created_date >= ? AND i.created_date <= ?
    ''';
    List<Variable> vars = [
      Variable.withString(startIso),
      Variable.withString(endIso),
    ];
    sql += '''
      GROUP BY pt.payment_method_name
      ORDER BY totalAmount DESC
      ''';
    final rows = await customSelect(sql, variables: vars).get();
    return rows.map((r) => r.data).toList();
  }

  Future<Map<String, dynamic>> getSalesDashboard(
    String startIso,
    String endIso,
  ) async {
    String sql = '''
      SELECT 
        COUNT(*) as totalInvoices,
        COALESCE(SUM(total_cost), 0) as totalSales,
        COALESCE(SUM(tax_cost), 0) as totalTax,
        COALESCE(SUM(discount_amount), 0) as totalDiscount,
        COALESCE(SUM(net_payment_amount), 0) as netTotal,
        COALESCE(AVG(net_payment_amount), 0) as averageOrderValue
      FROM invoices
      WHERE created_date >= ? AND created_date <= ?
    ''';
    List<Variable> vars = [
      Variable.withString(startIso),
      Variable.withString(endIso),
    ];

    final row = await customSelect(sql, variables: vars).getSingleOrNull();
    return row?.data ?? {};
  }
}
