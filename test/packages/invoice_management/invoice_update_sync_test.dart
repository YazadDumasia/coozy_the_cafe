import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:coozy_the_cafe/packages/invoice_management/data/datasources/invoice_management_remote_datasource.dart';
import 'package:coozy_the_cafe/packages/invoice_management/data/repositories/invoice_management_repository_impl.dart';
import 'package:coozy_the_cafe/packages/invoice_management/domain/entities/invoice_management_entity.dart';

void main() {
  late CoozyDatabase db;
  late InvoicesDao invoicesDao;
  late OrdersDao ordersDao;
  late InvoiceManagementRemoteDataSource remoteDataSource;
  late InvoiceManagementRepositoryImpl repository;

  setUp(() async {
    db = CoozyDatabase.withQueryExecutor(NativeDatabase.memory());
    invoicesDao = db.invoicesDao;
    ordersDao = db.ordersDao;
    remoteDataSource = InvoiceManagementRemoteDataSourceImpl(invoicesDao);
    repository =
        InvoiceManagementRepositoryImpl(remoteDataSource: remoteDataSource);

    await db.into(db.menuItemsTable).insert(
      const MenuItemsTableCompanion(
        id: Value(5),
        name: Value('Tea'),
        description: Value('Fresh tea'),
        sellingPrice: Value(40.0),
      ),
    );
    await db.into(db.menuItemsTable).insert(
      const MenuItemsTableCompanion(
        id: Value(10),
        name: Value('Cappuccino'),
        description: Value('Hot coffee'),
        sellingPrice: Value(50.0),
      ),
    );
    await db.into(db.menuItemsTable).insert(
      const MenuItemsTableCompanion(
        id: Value(20),
        name: Value('Croissant'),
        description: Value('French pastry'),
        sellingPrice: Value(80.0),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('Updating invoice in InvoicesDao updates invoicesTable, invoiceItems, ordersTable, and orderItemsTable', () async {
    // 1. Create linked order
    final orderId = await ordersDao.createNewOrder(
      order: OrdersTableCompanion(
        hashId: const Value('order-sync-1'),
        tableNameText: const Value('Table 5'),
        status: const Value('completed'),
        customerName: const Value('Original Customer'),
        phoneNumber: const Value('1111111111'),
        subtotalAmount: const Value(100.0),
        discountAmount: const Value(0.0),
        taxAmount: const Value(0.0),
        grandTotal: const Value(100.0),
        creationDate: Value(DateTime.now().toUtc().toIso8601String()),
      ),
      orderItems: [
        const OrderItemsTableCompanion(
          itemId: Value(10),
          menuItemId: Value(10),
          quantity: Value(2),
          sellingPrice: Value(50.0),
          status: Value('completed'),
        ),
      ],
    );

    // 2. Create invoice linked to order
    final invoiceId = await invoicesDao.createInvoice(
      invoice: InvoicesTableCompanion(
        orderId: Value(orderId),
        hashId: const Value('inv-sync-1'),
        customerName: const Value('Original Customer'),
        phoneNumber: const Value('1111111111'),
        paymentMethodName: const Value('Cash'),
        totalCost: const Value(100.0),
        taxableAmount: const Value(100.0),
        taxCost: const Value(0.0),
        discountAmount: const Value(0.0),
        netPaymentAmount: const Value(100.0),
        createdDate: Value(DateTime.now().toUtc().toIso8601String()),
      ),
      items: [
        const InvoiceItemsTableCompanion(
          itemId: Value(10),
          itemName: Value('Cappuccino'),
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

    // 3. Perform update with modified items and amounts
    final updatedItems = [
      const InvoiceItemsTableCompanion(
        itemId: Value(10),
        itemName: Value('Cappuccino'),
        quantity: Value(3),
        sellingPrice: Value(50.0),
        totalPrice: Value(150.0),
      ),
      const InvoiceItemsTableCompanion(
        itemId: Value(20),
        itemName: Value('Croissant'),
        quantity: Value(1),
        sellingPrice: Value(80.0),
        totalPrice: Value(80.0),
      ),
    ];

    final updatedInvoiceCompanion = InvoicesTableCompanion(
      customerName: const Value('Updated Customer'),
      phoneNumber: const Value('9999999999'),
      paymentMethodName: const Value('UPI'),
      totalCost: const Value(230.0),
      discountAmount: const Value(20.0),
      taxCost: const Value(10.5),
      netPaymentAmount: const Value(220.5),
      modifiedDate: Value(DateTime.now().toUtc().toIso8601String()),
    );

    final success = await invoicesDao.updateInvoice(
      invoiceId,
      updatedInvoiceCompanion,
      items: updatedItems,
    );

    expect(success, isTrue);

    // 4. Verify invoicesTable has updated fields
    final invoice = await invoicesDao.getInvoiceById(invoiceId);
    expect(invoice, isNotNull);
    expect(invoice!.customerName, 'Updated Customer');
    expect(invoice.phoneNumber, '9999999999');
    expect(invoice.paymentMethodName, 'UPI');
    expect(invoice.totalCost, 230.0);
    expect(invoice.discountAmount, 20.0);
    expect(invoice.taxCost, 10.5);
    expect(invoice.netPaymentAmount, 220.5);

    // 5. Verify invoiceItemsTable has 2 updated items
    final dbInvoiceItems = await invoicesDao.getInvoiceItemsByInvoiceId(invoiceId);
    expect(dbInvoiceItems.length, 2);
    expect(dbInvoiceItems.first.itemName, 'Cappuccino');
    expect(dbInvoiceItems.first.quantity, 3);
    expect(dbInvoiceItems.first.totalPrice, 150.0);
    expect(dbInvoiceItems.last.itemName, 'Croissant');
    expect(dbInvoiceItems.last.quantity, 1);
    expect(dbInvoiceItems.last.totalPrice, 80.0);

    // 6. Verify linked ordersTable has synced values
    final orderWithItems = await ordersDao.getOrderInfo(orderId);
    expect(orderWithItems, isNotNull);
    final order = orderWithItems!.order;
    expect(order.customerName, 'Updated Customer');
    expect(order.phoneNumber, '9999999999');
    expect(order.paymentMethodName, 'UPI');
    expect(order.subtotalAmount, 230.0);
    expect(order.discountAmount, 20.0);
    expect(order.taxAmount, 10.5);
    expect(order.grandTotal, 220.5);
    expect(order.modificationDate, isNotNull);

    // 7. Verify linked orderItemsTable has synced items
    final orderItems = orderWithItems.items;
    expect(orderItems.length, 2);
    expect(orderItems.any((i) => i.itemId == 10 && i.quantity == 3 && i.sellingPrice == 50.0), isTrue);
    expect(orderItems.any((i) => i.itemId == 20 && i.quantity == 1 && i.sellingPrice == 80.0), isTrue);
  });

  test('Updating invoice via InvoiceManagementRepositoryImpl syncs both invoice and order records', () async {
    // 1. Create linked order
    final orderId = await ordersDao.createNewOrder(
      order: OrdersTableCompanion(
        hashId: const Value('order-repo-sync-1'),
        status: const Value('completed'),
        creationDate: Value(DateTime.now().toUtc().toIso8601String()),
      ),
      orderItems: [
        const OrderItemsTableCompanion(
          itemId: Value(5),
          quantity: Value(1),
          sellingPrice: Value(40.0),
        ),
      ],
    );

    // 2. Create invoice linked to order
    final invoiceId = await invoicesDao.createInvoice(
      invoice: InvoicesTableCompanion(
        orderId: Value(orderId),
        hashId: const Value('inv-repo-sync-1'),
        customerName: const Value('Old Name'),
        totalCost: const Value(40.0),
        netPaymentAmount: const Value(40.0),
        createdDate: Value(DateTime.now().toUtc().toIso8601String()),
      ),
      items: [
        const InvoiceItemsTableCompanion(
          itemId: Value(5),
          itemName: Value('Tea'),
          quantity: Value(1),
          sellingPrice: Value(40.0),
          totalPrice: Value(40.0),
        ),
      ],
      payments: [],
    );

    // 3. Update using repository
    final updatedEntity = InvoiceEntity(
      id: invoiceId,
      orderId: orderId,
      hashId: 'inv-repo-sync-1',
      customerName: 'New Repo Name',
      phoneNumber: '9876543210',
      paymentMethodName: 'Card',
      totalCost: 120.0,
      taxCost: 6.0,
      discountAmount: 10.0,
      taxableAmount: 110.0,
      netPaymentAmount: 116.0,
    );

    final updatedItemsEntity = [
      const InvoiceItemEntity(
        id: 1,
        invoiceId: 0,
        itemId: 5,
        itemName: 'Tea',
        quantity: 3,
        unitPrice: 40.0,
        totalPrice: 120.0,
      ),
    ];

    final result = await repository.updateInvoice(
      invoice: updatedEntity,
      items: updatedItemsEntity,
    );

    expect(result.isRight(), isTrue);

    // 4. Verify order is synced
    final orderWithItems = await ordersDao.getOrderInfo(orderId);
    expect(orderWithItems, isNotNull);
    expect(orderWithItems!.order.customerName, 'New Repo Name');
    expect(orderWithItems.order.phoneNumber, '9876543210');
    expect(orderWithItems.order.paymentMethodName, 'Card');
    expect(orderWithItems.order.subtotalAmount, 120.0);
    expect(orderWithItems.order.discountAmount, 10.0);
    expect(orderWithItems.order.taxAmount, 6.0);
    expect(orderWithItems.order.grandTotal, 116.0);

    // 5. Verify order items synced
    expect(orderWithItems.items.length, 1);
    expect(orderWithItems.items.first.itemId, 5);
    expect(orderWithItems.items.first.quantity, 3);
    expect(orderWithItems.items.first.sellingPrice, 40.0);
  });
}
