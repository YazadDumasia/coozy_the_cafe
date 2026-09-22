import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CoozyDatabase db;
  late ReportsDao reportsDao;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = CoozyDatabase.withQueryExecutor(NativeDatabase.memory());
    reportsDao = db.reportsDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('FakeDataHelper & Reports Integration Tests', () {
    test(
      'generateDatasetData generates orders, invoices, inventory and purchases',
      () async {
        final insertedCount = await FakeDataHelper.generateDatasetData(db, [
          'inventory',
          'purchases',
          'orders',
          'invoices',
        ]);

        expect(insertedCount, greaterThan(0));

        final orders = await db.select(db.ordersTable).get();
        final invoices = await db.select(db.invoicesTable).get();
        final invoiceItems = await db.select(db.invoiceItemsTable).get();
        final purchases = await db.select(db.purchaseTable).get();
        final inventory = await db.select(db.inventoryTable).get();

        expect(orders, isNotEmpty);
        expect(invoices, isNotEmpty);
        expect(invoiceItems, isNotEmpty);
        expect(purchases, isNotEmpty);
        expect(inventory, isNotEmpty);

        // Verify invoice items link orderItemId and itemId
        final firstLinkedItem = invoiceItems.firstWhere(
          (ii) => ii.orderItemId != null,
        );
        expect(firstLinkedItem.orderItemId, isNotNull);
        expect(firstLinkedItem.itemId, isNotNull);

        // Verify orders have financial totals
        final completedOrder = orders.firstWhere(
          (o) => o.status == 'completed',
        );
        expect(completedOrder.grandTotal, greaterThan(0.0));
        expect(completedOrder.subtotalAmount, greaterThan(0.0));
        expect(completedOrder.taxAmount, greaterThan(0.0));
        expect(completedOrder.placedAt, isNotNull);
        expect(completedOrder.servedAt, isNotNull);
      },
    );

    test(
      'ReportsDao daily and monthly sales summaries compute positive cost and profit',
      () async {
        await FakeDataHelper.generateDatasetData(db, [
          'customers',
          'table_info',
          'categories',
          'subcategories',
          'menu_items',
          'orders',
          'invoices',
        ]);

        final now = DateTime.now();
        final startIso = now
            .subtract(const Duration(days: 700))
            .toIso8601String();
        final endIso = now.add(const Duration(days: 10)).toIso8601String();

        final dailySales = await reportsDao.getDailySalesSummary(
          startIso,
          endIso,
        );
        expect(dailySales, isNotEmpty);

        // Cost and profit should be non-zero because orderItemId and oi.cost_price are properly linked
        final rowWithCost = dailySales.firstWhere(
          (r) => (r['dailyCost'] as num) > 0,
        );
        expect((rowWithCost['dailyCost'] as num).toDouble(), greaterThan(0.0));
        expect(
          (rowWithCost['dailyProfit'] as num).toDouble(),
          greaterThan(0.0),
        );
        expect((rowWithCost['netTotal'] as num).toDouble(), greaterThan(0.0));

        final monthlySales = await reportsDao.getMonthlySalesSummary(
          startIso,
          endIso,
        );
        expect(monthlySales, isNotEmpty);
        final monthRow = monthlySales.firstWhere(
          (r) => (r['monthlyCost'] as num) > 0,
        );
        expect((monthRow['monthlyCost'] as num).toDouble(), greaterThan(0.0));
        expect((monthRow['monthlyProfit'] as num).toDouble(), greaterThan(0.0));
      },
    );

    test(
      'ReportsDao top selling items and sales dashboard KPI aggregate accurately',
      () async {
        await FakeDataHelper.generateDatasetData(db, [
          'customers',
          'table_info',
          'categories',
          'subcategories',
          'menu_items',
          'orders',
          'invoices',
        ]);

        final now = DateTime.now();
        final startIso = now
            .subtract(const Duration(days: 700))
            .toIso8601String();
        final endIso = now.add(const Duration(days: 10)).toIso8601String();

        final topSelling = await reportsDao.getTopSellingItems(
          startIso,
          endIso,
          limit: 5,
        );
        expect(topSelling, isNotEmpty);
        expect(topSelling.first['itemName'], isNotNull);
        expect(
          (topSelling.first['totalQuantity'] as num).toInt(),
          greaterThan(0),
        );
        expect(
          (topSelling.first['totalCost'] as num).toDouble(),
          greaterThan(0.0),
        );

        final dashboard = await reportsDao.getSalesDashboard(startIso, endIso);
        expect(dashboard['totalInvoices'], greaterThan(0));
        expect((dashboard['totalCost'] as num).toDouble(), greaterThan(0.0));
        expect((dashboard['totalProfit'] as num).toDouble(), greaterThan(0.0));
      },
    );

    test(
      'ReportsDao payment modes, inventory stock, and purchases report correctly',
      () async {
        await FakeDataHelper.generateDatasetData(db, [
          'inventory',
          'purchases',
          'customers',
          'table_info',
          'categories',
          'subcategories',
          'menu_items',
          'orders',
          'invoices',
        ]);

        final now = DateTime.now();
        final startIso = now
            .subtract(const Duration(days: 700))
            .toIso8601String();
        final endIso = now.add(const Duration(days: 10)).toIso8601String();

        // Payment modes
        final paymentReport = await reportsDao.getPaymentModeReport(
          startIso,
          endIso,
        );
        expect(paymentReport, isNotEmpty);
        expect(paymentReport.first['paymentMethodName'], isNotNull);
        expect(
          (paymentReport.first['totalAmount'] as num).toDouble(),
          greaterThan(0.0),
        );

        // Inventory stock
        final stockReport = await reportsDao.getInventoryStockReport();
        expect(stockReport, isNotEmpty);
        expect(
          (stockReport.first['currentStock'] as num).toDouble(),
          greaterThan(0.0),
        );

        // Purchase summary
        final purchaseReport = await reportsDao.getPurchaseSummaryReport(
          startIso,
          endIso,
        );
        expect(purchaseReport, isNotEmpty);
        expect(
          (purchaseReport.first['totalCost'] as num).toDouble(),
          greaterThan(0.0),
        );
        expect(
          (purchaseReport.first['totalQty'] as num).toDouble(),
          greaterThan(0.0),
        );
      },
    );

    test(
      'removeDatasetData cleanly removes generated sample data without deleting pre-existing records',
      () async {
        // 1. Insert a pre-existing custom customer and table
        await db
            .into(db.customersTable)
            .insert(
              CustomersTableCompanion.insert(
                hashId: const Value('custom-user-customer-123'),
                name: const Value('Existing User'),
                phoneNumber: const Value('+91 9999999999'),
              ),
            );

        // 2. Generate fake dataset
        await FakeDataHelper.generateDatasetData(db, [
          'customers',
          'orders',
          'invoices',
        ]);

        var allCustomers = await db.select(db.customersTable).get();
        expect(allCustomers.length, greaterThan(1));

        // 3. Remove fake dataset
        await FakeDataHelper.removeDatasetData(db, [
          'invoices',
          'orders',
          'customers',
        ]);

        allCustomers = await db.select(db.customersTable).get();
        // Only the pre-existing customer remains
        expect(allCustomers.length, equals(1));
        expect(allCustomers.first.name, equals('Existing User'));
      },
    );
  });
}
