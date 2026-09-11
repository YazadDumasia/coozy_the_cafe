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
    OrdersTable,
    OrderItemsTable,
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

  Future<Invoice?> getInvoiceByOrderId(int orderId) {
    final query = select(invoicesTable)
      ..where(
        (t) =>
            t.orderId.equals(orderId) &
            (t.isDeleted.equals(false) | t.isDeleted.isNull()),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<Invoice?> getInvoiceByOrderHashId(String orderHashId) async {
    final order = await (select(ordersTable)
          ..where((t) => t.hashId.equals(orderHashId)))
        .getSingleOrNull();
    if (order == null) return null;
    return getInvoiceByOrderId(order.id);
  }

  Future<List<Invoice>> getInvoicesPaginated({
    required int limit,
    required int pageNo,
    String? search,
  }) {
    final offset = (pageNo - 1) * limit;
    final query = select(invoicesTable)
      ..where((t) => t.isDeleted.equals(false) | t.isDeleted.isNull());

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
    final query = selectOnly(invoicesTable)
      ..where(
        invoicesTable.isDeleted.equals(false) |
            invoicesTable.isDeleted.isNull(),
      )
      ..addColumns([countExpr]);
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

  Future<bool> updateInvoice(
    int id,
    InvoicesTableCompanion invoice, {
    List<InvoiceItemsTableCompanion>? items,
  }) async {
    return transaction(() async {
      // 1. Fetch current invoice to retrieve linked orderId
      final existingInvoice = await (select(invoicesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

      // 2. Update invoice record
      final rowsUpdated = await (update(invoicesTable)..where((t) => t.id.equals(id))).write(invoice);
      if (rowsUpdated <= 0) return false;

      // 2b. Sync invoice items if provided
      if (items != null) {
        await (delete(invoiceItemsTable)..where((t) => t.invoiceId.equals(id))).go();
        for (final item in items) {
          await into(invoiceItemsTable).insert(
            item.copyWith(invoiceId: Value(id)),
          );
        }
      }

      // 3. Sync linked Order record if orderId exists
      final orderId = invoice.orderId.present ? invoice.orderId.value : existingInvoice?.orderId;
      if (orderId != null) {
        final nowIso = DateTime.now().toUtc().toIso8601String();

        final orderCompanion = OrdersTableCompanion(
          customerName: invoice.customerName.present ? invoice.customerName : const Value.absent(),
          phoneNumber: invoice.phoneNumber.present ? invoice.phoneNumber : const Value.absent(),
          isoCode: invoice.isoCode.present ? invoice.isoCode : const Value.absent(),
          paymentMethodName: invoice.paymentMethodName.present ? invoice.paymentMethodName : const Value.absent(),
          paymentMethodDetails: invoice.paymentMethodDetails.present ? invoice.paymentMethodDetails : const Value.absent(),
          cashReceived: invoice.cashReceived.present ? invoice.cashReceived : const Value.absent(),
          changeAmount: invoice.changeAmount.present ? invoice.changeAmount : const Value.absent(),
          subtotalAmount: invoice.totalCost.present ? invoice.totalCost : const Value.absent(),
          discountAmount: invoice.discountAmount.present ? invoice.discountAmount : const Value.absent(),
          taxAmount: invoice.taxCost.present ? invoice.taxCost : const Value.absent(),
          grandTotal: invoice.netPaymentAmount.present ? invoice.netPaymentAmount : const Value.absent(),
          modificationDate: Value(nowIso),
        );

        await (update(ordersTable)..where((t) => t.id.equals(orderId))).write(orderCompanion);

        // Also sync order items if items are provided
        if (items != null) {
          await (delete(orderItemsTable)..where((t) => t.orderId.equals(orderId))).go();
          for (final item in items) {
            int? validItemId;
            if (item.itemId.present && item.itemId.value != null) {
              final exists = await (select(attachedDatabase.menuItemsTable)
                    ..where((m) => m.id.equals(item.itemId.value!)))
                  .getSingleOrNull();
              if (exists != null) {
                validItemId = item.itemId.value;
              }
            }

            await into(orderItemsTable).insert(
              OrderItemsTableCompanion(
                orderId: Value(orderId),
                itemId: Value(validItemId),
                menuItemId: Value(validItemId),
                quantity: item.quantity,
                sellingPrice: item.sellingPrice,
                creationDate: Value(nowIso),
                status: const Value('completed'),
              ),
            );
          }
        }
      }

      return true;
    });
  }

  Future<int> deleteInvoice(int id) async {
    return transaction(() async {
      final nowUtcIso = DateTime.now().toUtc().toIso8601String();

      // 1. Fetch invoice to get linked orderId
      final invoice = await (select(invoicesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (invoice == null) return 0;

      // 2. Soft delete the invoice
      final rowsUpdated = await (update(invoicesTable)..where((t) => t.id.equals(id))).write(
        InvoicesTableCompanion(
          isDeleted: const Value(true),
          modifiedDate: Value(nowUtcIso),
        ),
      );

      // 3. If invoice is linked to an order, soft delete the order and order items
      final linkedOrderId = invoice.orderId;
      if (linkedOrderId != null) {
        await (update(ordersTable)..where((t) => t.id.equals(linkedOrderId))).write(
          OrdersTableCompanion(
            isDeleted: const Value(true),
            status: const Value('deleted'),
            modificationDate: Value(nowUtcIso),
          ),
        );

        await (update(orderItemsTable)..where((t) => t.orderId.equals(linkedOrderId))).write(
          const OrderItemsTableCompanion(
            status: Value('deleted'),
          ),
        );
      }

      return rowsUpdated;
    });
  }

  Future<List<Invoice>> getInvoicesByDateRange(
    String startIso,
    String endIso, {
    int? limit,
    int? offset,
  }) {
    final query = select(invoicesTable)
      ..where(
        (t) =>
            t.createdDate.isBetween(Constant(startIso), Constant(endIso)) &
            (t.isDeleted.equals(false) | t.isDeleted.isNull()),
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
            ) &
            (invoicesTable.isDeleted.equals(false) |
                invoicesTable.isDeleted.isNull()),
      );
    query.addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
