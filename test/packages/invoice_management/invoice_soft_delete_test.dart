import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

void main() {
  late CoozyDatabase db;
  late InvoicesDao invoicesDao;
  late OrdersDao ordersDao;

  setUp(() {
    db = CoozyDatabase.withQueryExecutor(NativeDatabase.memory());
    invoicesDao = db.invoicesDao;
    ordersDao = db.ordersDao;
  });

  tearDown(() async {
    await db.close();
  });

  test('Soft delete invoice and linked order marks isDeleted=true in both tables', () async {
    // 1. Create an order
    final orderId = await ordersDao.createNewOrder(
      order: OrdersTableCompanion(
        hashId: const Value('order-test-hash-1'),
        tableNameText: const Value('Table 1'),
        status: const Value('completed'),
        creationDate: Value(DateTime.now().toUtc().toIso8601String()),
      ),
      orderItems: [
        const OrderItemsTableCompanion(
          quantity: Value(2),
          sellingPrice: Value(50.0),
          status: Value('completed'),
        ),
      ],
    );

    // 2. Create an invoice linked to the order
    final invoiceId = await invoicesDao.createInvoice(
      invoice: InvoicesTableCompanion(
        orderId: Value(orderId),
        hashId: const Value('inv-test-hash-1'),
        netPaymentAmount: const Value(100.0),
        createdDate: Value(DateTime.now().toUtc().toIso8601String()),
      ),
      items: [
        const InvoiceItemsTableCompanion(
          itemName: Value('Coffee'),
          quantity: Value(2),
          sellingPrice: Value(50.0),
          totalPrice: Value(100.0),
        ),
      ],
      payments: [
        const PaymentTransactionsTableCompanion(
          amount: Value(100.0),
          paymentMethodName: Value('Cash'),
          paymentStatus: Value('success'),
        ),
      ],
    );

    // Verify initial state
    final initialInvoices = await invoicesDao.getInvoicesPaginated(limit: 10, pageNo: 1);
    expect(initialInvoices.length, 1);
    expect(initialInvoices.first.id, invoiceId);

    final initialCount = await invoicesDao.getInvoicesCount();
    expect(initialCount, 1);

    // 3. Perform soft delete
    final rowsAffected = await invoicesDao.deleteInvoice(invoiceId);
    expect(rowsAffected, 1);

    // 4. Verify invoice is soft deleted (not returned in regular queries)
    final postInvoices = await invoicesDao.getInvoicesPaginated(limit: 10, pageNo: 1);
    expect(postInvoices.isEmpty, true);

    final postCount = await invoicesDao.getInvoicesCount();
    expect(postCount, 0);

    // Verify raw invoice row has isDeleted = true
    final rawInvoice = await invoicesDao.getInvoiceById(invoiceId);
    expect(rawInvoice, isNotNull);
    expect(rawInvoice!.isDeleted, true);

    // 5. Verify linked order is also soft deleted
    final orderWithItems = await ordersDao.getOrderInfo(orderId);
    expect(orderWithItems, isNotNull);
    expect(orderWithItems!.order.isDeleted, true);
    expect(orderWithItems.order.status, 'deleted');

    // Verify order items status updated to 'deleted'
    for (final item in orderWithItems.items) {
      expect(item.status, 'deleted');
    }
  });

  test('Permanently delete order completely removes record and order items from table', () async {
    // 1. Create an order
    final orderId = await ordersDao.createNewOrder(
      order: OrdersTableCompanion(
        hashId: const Value('order-perm-test-1'),
        tableNameText: const Value('Table 4'),
        status: const Value('placed'),
        creationDate: Value(DateTime.now().toUtc().toIso8601String()),
      ),
      orderItems: [
        const OrderItemsTableCompanion(
          quantity: Value(1),
          sellingPrice: Value(120.0),
          status: Value('placed'),
        ),
      ],
    );

    // Verify order exists
    final createdOrder = await ordersDao.getOrderInfo(orderId);
    expect(createdOrder, isNotNull);
    expect(createdOrder!.items.length, 1);

    // 2. Permanently delete order
    final deleteResult = await ordersDao.permanentlyDeleteOrder(orderId);
    expect(deleteResult, 1);

    // 3. Verify order is completely deleted from database
    final deletedOrder = await ordersDao.getOrderInfo(orderId);
    expect(deletedOrder, isNull);

    // Verify order items are also completely deleted
    final remainingItems = await (db.select(db.orderItemsTable)..where((t) => t.orderId.equals(orderId))).get();
    expect(remainingItems.isEmpty, true);
  });
}
