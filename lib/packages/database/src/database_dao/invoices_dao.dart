import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'invoices_dao.g.dart';

@DriftAccessor(
  tables: [
    PaymentModesTable,
    InvoicesTable,
    InvoiceItemsTable,
    PaymentTransactionsTable,
  ],
)
class InvoicesDao extends DatabaseAccessor<CoozyDatabase>
    with _$InvoicesDaoMixin {
  InvoicesDao(super.db);

  // ---- PAYMENT MODES ----
  Future<int> addPaymentMode(PaymentModesTableCompanion mode) =>
      into(paymentModesTable).insertOnConflictUpdate(mode);

  Future<List<PaymentMode>> getPaymentModes() {
    final query = select(paymentModesTable);
    return query.get();
  }

  Future<int> deletePaymentMode(int id) =>
      (delete(paymentModesTable)..where((t) => t.id.equals(id))).go();

  // ---- INVOICES ----
  Future<int> createInvoice({
    required InvoicesTableCompanion invoice,
    required List<InvoiceItemsTableCompanion> items,
    required List<PaymentTransactionsTableCompanion> payments,
  }) async {
    return transaction(() async {
      final invoiceId = await into(invoicesTable).insert(invoice);
      for (final item in items) {
        await into(
          invoiceItemsTable,
        ).insert(item.copyWith(invoiceId: Value(invoiceId)));
      }
      for (final payment in payments) {
        await into(
          paymentTransactionsTable,
        ).insert(payment.copyWith(invoiceId: Value(invoiceId)));
      }
      return invoiceId;
    });
  }

  Future<Invoice?> getInvoiceById(int id) {
    final query = select(invoicesTable)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(int invoiceId) {
    final query = select(invoiceItemsTable)
      ..where((t) => t.invoiceId.equals(invoiceId));
    return query.get();
  }

  Future<List<PaymentTransaction>> getPaymentTransactionsByInvoiceId(
    int invoiceId,
  ) {
    final query = select(paymentTransactionsTable)
      ..where((t) => t.invoiceId.equals(invoiceId));
    return query.get();
  }

  Future<Invoice?> getInvoiceByHashId(String hashId) {
    final query = select(invoicesTable)..where((t) => t.hashId.equals(hashId));
    return query.getSingleOrNull();
  }

  Future<List<Invoice>> getInvoicesPaginated({
    required int limit,
    required int pageNo,
    String? search,
  }) {
    final offset = (pageNo - 1) * limit;
    final query = select(invoicesTable);

    query.orderBy([
      (t) => OrderingTerm(expression: t.createdDate, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
    ]);

    if (search != null && search.isNotEmpty) {
      query.where(
        (t) =>
            t.hashId.like('%$search%') |
            t.customerName.like('%$search%') |
            t.phoneNumber.like('%$search%'),
      );
    }
    return (query..limit(limit, offset: offset)).get();
  }

  Future<int> getInvoicesCount({String? search}) async {
    final countExpr = invoicesTable.id.count();
    final query = selectOnly(invoicesTable)..addColumns([countExpr]);
    if (search != null && search.isNotEmpty) {
      query.where(
        invoicesTable.hashId.like('%$search%') |
            invoicesTable.customerName.like('%$search%') |
            invoicesTable.phoneNumber.like('%$search%') |
            invoicesTable.isoCode.like('%$search%'),
      );
    }
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<bool> updateInvoice(int id, InvoicesTableCompanion invoice) => (update(
    invoicesTable,
  )..where((t) => t.id.equals(id))).write(invoice).then((rows) => rows > 0);

  Future<int> deleteInvoice(int id) =>
      (delete(invoicesTable)..where((t) => t.id.equals(id))).go();

  Future<List<Invoice>> getInvoicesByDateRange(
    String startIso,
    String endIso, {
    int? limit,
    int? offset,
  }) {
    final query = select(invoicesTable)
      ..where(
        (t) => t.createdDate.isBetween(Constant(startIso), Constant(endIso)),
      );
    query.orderBy([
      (t) => OrderingTerm(expression: t.createdDate, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
    ]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  Future<int> getInvoicesCountByDateRange(
    String startIso,
    String endIso,
  ) async {
    final countExpr = invoicesTable.id.count();
    final query = selectOnly(invoicesTable)
      ..where(
        invoicesTable.createdDate.isBetween(
          Constant(startIso),
          Constant(endIso),
        ),
      );
    query.addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
