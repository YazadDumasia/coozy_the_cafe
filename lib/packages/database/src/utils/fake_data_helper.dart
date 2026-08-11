import 'dart:math';
import 'package:drift/drift.dart';
import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

typedef FakeDataProgressCallback =
    void Function(
      String stageKey,
      String stageDescription,
      int currentStep,
      int totalSteps,
    );

class FakeDataHelper {
  static const String fakePrefix = 'FAKE_';

  /// Generates fake records across all modules with stage progress updates.
  static Future<int> generateFakeData(
    CoozyDatabase db, {
    FakeDataProgressCallback? onProgress,
  }) async {
    final faker = Faker();
    final random = Random();
    final uuid = const Uuid();
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 547)); // 1.5 years ago

    int totalInsertedRecords = 0;
    const totalSteps = 7;

    DateTime getRandomDate() {
      final diffDays = now.difference(startDate).inDays;
      final randomDays = random.nextInt(diffDays > 0 ? diffDays : 1);
      final randomMinutes = random.nextInt(1440);
      return startDate.add(Duration(days: randomDays, minutes: randomMinutes));
    }

    // 1. Customers (200 entries)
    onProgress?.call(
      'customers',
      'Generating Customers & Contact Info...',
      1,
      totalSteps,
    );
    final customerIds = <int>[];
    final customerNames = <int, String>{};
    for (int i = 0; i < 200; i++) {
      final custName = faker.person.name();
      final phone =
          '+91 ${faker.randomGenerator.integer(999999999, min: 600000000)}';
      final created = getRandomDate();
      final id = await db
          .into(db.customersTable)
          .insert(
            CustomersTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              name: Value(custName),
              phoneNumber: Value(phone),
              isoCode: const Value('IN'),
              createdDate: Value(created.toIso8601String()),
            ),
          );
      customerIds.add(id);
      customerNames[id] = custName;
      totalInsertedRecords++;
    }

    // 2. Employees (200 entries)
    onProgress?.call(
      'employees',
      'Generating Staff & Employee Profiles...',
      2,
      totalSteps,
    );
    final employeeIds = <int>[];
    final employeeNamesMap = <int, String>{};
    final employeePositionsMap = <int, String>{};

    final positions = [
      'Manager',
      'Assistant Manager',
      'Head Chef',
      'Sous Chef',
      'Pastry Chef',
      'Senior Barista',
      'Barista',
      'Senior Waiter',
      'Junior Waiter',
      'Cashier',
      'Kitchen Helper',
      'Cleaner',
    ];

    for (int i = 0; i < 200; i++) {
      final empName = faker.person.name();
      final phone =
          '+91 ${faker.randomGenerator.integer(999999999, min: 600000000)}';
      final pos = positions[i % positions.length];
      final joining = getRandomDate();
      final email = faker.internet.email();
      final salary = 18000.0 + random.nextInt(40000);

      final id = await db
          .into(db.employeesTable)
          .insert(
            EmployeesTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              name: Value(empName),
              phoneNumber: Value(phone),
              isoCode: const Value('IN'),
              position: Value(pos),
              joiningDate: Value(joining.toIso8601String()),
              startWorkingTime: const Value('09:00 AM'),
              endWorkingTime: const Value('06:00 PM'),
              workingHours: const Value('9 hours'),
              email: Value(email),
              salary: Value(salary),
              addressLine1: Value('${10 + i} Main Cafe Avenue'),
              addressLine2: const Value('Downtown Sector 12'),
              idProof: const Value('Aadhaar Card'),
              idProofNumber: Value('99${100000000 + i}'),
              totalLeaves: const Value(12),
              isDeleted: const Value(false),
              creationDate: Value(joining.toIso8601String()),
            ),
          );

      employeeIds.add(id);
      employeeNamesMap[id] = empName;
      employeePositionsMap[id] = pos;
      totalInsertedRecords++;
    }

    // 3. Attendance & Leaves (Full-time & Half-time realistic demo logs)
    onProgress?.call(
      'attendance_leaves',
      'Generating Full-Time & Half-Day Attendance and Leave Records...',
      3,
      totalSteps,
    );

    final fullDayLeaveReasons = [
      'Full Day Leave - Medical Emergency & Doctor Advice',
      'Full Day Leave - Family Function & Relative Wedding',
      'Full Day Leave - Annual Paid Vacation',
      'Full Day Leave - Personal Work & Bank Visit',
      'Full Day Leave - Out of Station Travel',
      'Full Day Leave - Sick Leave (Fever & Rest)',
    ];

    final halfDayLeaveReasons = [
      'Half Day Leave - Morning Shift (Doctor Visit & Health Checkup)',
      'Half Day Leave - Afternoon Shift (Urgent Family Errand)',
      'Half Day Leave - Morning Shift (Personal Work)',
      'Half Day Leave - Afternoon Shift (Vehicle Repair & Maintenance)',
      'Half Day Leave - Morning Shift (Government Office Work)',
    ];

    // Generate 300 realistic Leave Records (Full-time & Half-time)
    for (int i = 0; i < 300; i++) {
      final empIndex = random.nextInt(employeeIds.length);
      final empId = employeeIds[empIndex];
      final empName = employeeNamesMap[empId] ?? 'Staff Member';
      final empPos = employeePositionsMap[empId] ?? 'Staff';
      final leaveDate = getRandomDate();

      final isHalfDay = random.nextDouble() < 0.4; // 40% half-day, 60% full-day
      final String reason;
      final DateTime endDate;

      if (isHalfDay) {
        reason =
            halfDayLeaveReasons[random.nextInt(halfDayLeaveReasons.length)];
        endDate = leaveDate;
      } else {
        reason =
            fullDayLeaveReasons[random.nextInt(fullDayLeaveReasons.length)];
        endDate = leaveDate.add(Duration(days: 1 + random.nextInt(2)));
      }

      // Status: 1 = Approved (75%), 2 = Pending (20%), 3 = Rejected (5%)
      final rVal = random.nextDouble();
      final status = rVal < 0.75 ? 1 : (rVal < 0.95 ? 2 : 3);

      await db
          .into(db.leavesTable)
          .insert(
            LeavesTableCompanion.insert(
              employeeId: Value(empId),
              employeeName: Value(empName),
              employeePosition: Value(empPos),
              currentStatus: Value(status),
              startDate: Value(leaveDate.toIso8601String()),
              endDate: Value(endDate.toIso8601String()),
              reason: Value(reason),
              creationDate: Value(leaveDate.toIso8601String()),
              isDeleted: const Value(false),
            ),
          );
      totalInsertedRecords++;

      // If approved leave, insert correlating Attendance entry on leaveDate
      if (status == 1) {
        if (isHalfDay) {
          final isMorningShift = reason.contains('Morning');
          final checkInStr = isMorningShift ? '02:00 PM' : '09:00 AM';
          final checkOutStr = isMorningShift ? '06:00 PM' : '01:00 PM';
          final durationStr = '4 hours (Half Day)';

          await db
              .into(db.attendanceTable)
              .insert(
                AttendanceTableCompanion.insert(
                  employeeId: Value(empId),
                  employeeName: Value(empName),
                  employeePosition: Value(empPos),
                  currentStatus: const Value(2), // 2 = Half Day
                  checkIn: Value(checkInStr),
                  checkOut: Value(checkOutStr),
                  employeeWorkingDurations: Value(durationStr),
                  creationDate: Value(leaveDate.toIso8601String()),
                  isDeleted: const Value(false),
                ),
              );
          totalInsertedRecords++;
        } else {
          await db
              .into(db.attendanceTable)
              .insert(
                AttendanceTableCompanion.insert(
                  employeeId: Value(empId),
                  employeeName: Value(empName),
                  employeePosition: Value(empPos),
                  currentStatus: const Value(3), // 3 = Absent / On Leave
                  checkIn: const Value('N/A'),
                  checkOut: const Value('N/A'),
                  employeeWorkingDurations: const Value('Full Day Leave'),
                  creationDate: Value(leaveDate.toIso8601String()),
                  isDeleted: const Value(false),
                ),
              );
          totalInsertedRecords++;
        }
      }
    }

    // Generate 600 General Working Day Attendance Records for employees
    final checkInTimes = [
      '08:45 AM',
      '09:00 AM',
      '09:15 AM',
      '09:30 AM',
      '10:00 AM',
    ];
    final checkOutTimes = [
      '05:30 PM',
      '06:00 PM',
      '06:15 PM',
      '06:30 PM',
      '07:00 PM',
    ];

    // Generate Current Month Daily Attendance Records for ALL Employees (ensures date picker works out-of-the-box)
    final currentDay = now.day;
    for (int day = 1; day <= currentDay; day++) {
      final dayDate = DateTime(now.year, now.month, day, 9, 0);
      for (int empIndex = 0; empIndex < employeeIds.length; empIndex++) {
        final empId = employeeIds[empIndex];
        final empName = employeeNamesMap[empId] ?? 'Staff Member';
        final empPos = employeePositionsMap[empId] ?? 'Staff';

        final randType = random.nextDouble();
        int status;
        String checkInStr;
        String checkOutStr;
        String durationStr;

        if (randType < 0.80) {
          status = 1; // Full Day Present
          checkInStr = checkInTimes[random.nextInt(checkInTimes.length)];
          checkOutStr = checkOutTimes[random.nextInt(checkOutTimes.length)];
          durationStr = '8 hours 30 mins';
        } else if (randType < 0.92) {
          status = 2; // Half Day
          checkInStr = '09:00 AM';
          checkOutStr = '01:00 PM';
          durationStr = '4 hours (Half Day)';
        } else {
          status = 3; // Absent
          checkInStr = 'N/A';
          checkOutStr = 'N/A';
          durationStr = 'Absent / On Leave';
        }

        await db
            .into(db.attendanceTable)
            .insert(
              AttendanceTableCompanion.insert(
                employeeId: Value(empId),
                employeeName: Value(empName),
                employeePosition: Value(empPos),
                currentStatus: Value(status),
                checkIn: Value(checkInStr),
                checkOut: Value(checkOutStr),
                employeeWorkingDurations: Value(durationStr),
                creationDate: Value(dayDate.toIso8601String()),
                isDeleted: const Value(false),
              ),
            );
        totalInsertedRecords++;
      }
    }

    // Historical attendance records over 1.5 years
    for (int i = 0; i < 600; i++) {
      final empIndex = random.nextInt(employeeIds.length);
      final empId = employeeIds[empIndex];
      final empName = employeeNamesMap[empId] ?? 'Staff Member';
      final empPos = employeePositionsMap[empId] ?? 'Staff';
      final attDate = getRandomDate();

      final randType = random.nextDouble();
      int status;
      String checkInStr;
      String checkOutStr;
      String durationStr;

      if (randType < 0.75) {
        status = 1; // Full Day Present
        checkInStr = checkInTimes[random.nextInt(checkInTimes.length)];
        checkOutStr = checkOutTimes[random.nextInt(checkOutTimes.length)];
        final hrs = 8 + random.nextInt(2);
        final mins = (random.nextInt(4) * 15);
        durationStr = mins == 0 ? '$hrs hours' : '$hrs hours $mins mins';
      } else if (randType < 0.90) {
        status = 2; // Half Day
        if (random.nextBool()) {
          checkInStr = '09:00 AM';
          checkOutStr = '01:00 PM';
        } else {
          checkInStr = '02:00 PM';
          checkOutStr = '06:00 PM';
        }
        durationStr = '4 hours (Half Day)';
      } else {
        status = 3; // Absent
        checkInStr = 'N/A';
        checkOutStr = 'N/A';
        durationStr = 'Absent / Unexcused';
      }

      await db
          .into(db.attendanceTable)
          .insert(
            AttendanceTableCompanion.insert(
              employeeId: Value(empId),
              employeeName: Value(empName),
              employeePosition: Value(empPos),
              currentStatus: Value(status),
              checkIn: Value(checkInStr),
              checkOut: Value(checkOutStr),
              employeeWorkingDurations: Value(durationStr),
              creationDate: Value(attDate.toIso8601String()),
              isDeleted: const Value(false),
            ),
          );
      totalInsertedRecords++;
    }

    // 4. Tables & Menu (12 Tables, 7 Categories, 35 Menu Items)
    onProgress?.call(
      'tables_menu',
      'Generating Dining Tables & Menu Items...',
      4,
      totalSteps,
    );
    final tableIds = <int>[];
    for (int i = 1; i <= 12; i++) {
      final id = await db
          .into(db.tableInfoTable)
          .insert(
            TableInfoTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              name: Value('Table $i (Demo)'),
              colorValue: const Value('4280391411'),
              sortOrderIndex: Value(i),
              nosOfChairs: Value(2 + (i % 4) * 2),
            ),
          );
      tableIds.add(id);
      totalInsertedRecords++;
    }

    final categoryNames = [
      'Beverages',
      'Main Course',
      'Desserts',
      'Starters & Appetizers',
      'Snacks & Quick Bites',
      'Bakery & Pastries',
      'Breakfast Specials',
      'Italian & Pasta',
      'Chinese & Pan-Asian',
      'Mexican & Tacos',
      'Indian Thalis & Curries',
      'Pizzas & Calzones',
      'Burgers & Sandwiches',
      'Healthy Bowls & Salads',
      'Mocktails & Shakes',
      'Coffee & Artisanal Teas',
      'Soups & Broths',
      'Ice Creams & Sundaes',
      'Seafood & Grill',
      'Chef Specials & Combos',
    ];

    final subcategoryPrefixes = [
      'Classic Specials',
      'Gourmet Choice',
      'Chef Signature',
      'Deluxe Collection',
      'House Specials',
      'Artisanal Range',
      'Premium Selection',
      'Sizzling Delights',
      'Spicy & Bold',
      'Sweet & Savory',
      'Authentic Feast',
      'Organic Harvest',
      'Crispy Favorites',
      'Seasonal Specials',
      'Masterpiece Combos',
    ];

    final itemPrefixes = [
      'Classic',
      'Deluxe',
      'Special',
      'Gourmet',
      'Chef Special',
      'Royal',
      'Crispy',
      'Grilled',
      'Loaded',
      'Supreme',
      'Signature',
      'Fresh',
      'Rich',
      'Hot & Spicy',
      'Smokey',
      'Traditional',
      'Ultimate',
      'Golden',
      'Sizzling',
      'Double Delight',
      'Superstar',
      'Grand',
      'Fiesta',
      'Extreme',
      'Paradise',
    ];

    final menuItemIds = <int>[];
    final menuItemPrices = <int, double>{};
    final menuItemNamesMap = <int, String>{};

    for (int c = 0; c < categoryNames.length; c++) {
      final catName = categoryNames[c];
      final catId = await db
          .into(db.categoriesTable)
          .insert(
            CategoriesTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              name: Value(catName),
              isActive: const Value(true),
              position: Value(c + 1),
              createdDate: Value(startDate.toIso8601String()),
            ),
          );
      totalInsertedRecords++;

      for (int s = 0; s < 15; s++) {
        final subName = '$catName - ${subcategoryPrefixes[s]}';
        final subCatId = await db
            .into(db.subcategoriesTable)
            .insert(
              SubcategoriesTableCompanion.insert(
                hashId: Value('$fakePrefix${uuid.v4()}'),
                name: Value(subName),
                categoryId: Value(catId),
                isActive: const Value(true),
                position: Value(s + 1),
                createdDate: Value(startDate.toIso8601String()),
              ),
            );
        totalInsertedRecords++;

        for (int m = 0; m < 25; m++) {
          final itemName = '${itemPrefixes[m]} $catName ${s + 1}-${m + 1}';
          final sellingPrice = 90.0 + random.nextInt(350);
          final costPrice = sellingPrice * 0.55;

          final bool isSimple = m % 2 == 0;
          final itemId = await db
              .into(db.menuItemsTable)
              .insert(
                MenuItemsTableCompanion.insert(
                  hashId: Value('$fakePrefix${uuid.v4()}'),
                  name: itemName,
                  description: 'Delicious $itemName prepared fresh daily.',
                  foodType: Value(m % 2 == 0 ? 'Veg' : 'Non-Veg'),
                  creationDate: Value(startDate.toIso8601String()),
                  duration: const Value(15),
                  categoryId: Value(catId),
                  subcategoryId: Value(subCatId),
                  isTodayAvailable: const Value(true),
                  isSimpleVariation: Value(isSimple),
                  costPrice: Value(costPrice),
                  sellingPrice: Value(sellingPrice),
                  stockQuantity: const Value(150),
                  quantity: const Value('1'),
                  purchaseUnit: const Value('portion'),
                  sortOrderIndex: Value(m + 1),
                ),
              );
          menuItemIds.add(itemId);
          menuItemPrices[itemId] = sellingPrice;
          menuItemNamesMap[itemId] = itemName;
          totalInsertedRecords++;

          if (isSimple) {
            // Single variation for simple item
            await db
                .into(db.menuItemVariationsTable)
                .insert(
                  MenuItemVariationsTableCompanion.insert(
                    hashId: Value('$fakePrefix${uuid.v4()}'),
                    name: const Value(null),
                    menuItemId: Value(itemId),
                    quantity: const Value(1),
                    purchaseUnit: const Value('portion'),
                    isTodayAvailable: const Value(true),
                    costPrice: Value(costPrice),
                    sellingPrice: Value(sellingPrice),
                    stockQuantity: const Value(150),
                    sortOrderIndex: const Value(1),
                    creationDate: Value(startDate.toIso8601String()),
                  ),
                );
            totalInsertedRecords++;
          } else {
            // Multiple variations (between 2 and 12 variations per item)
            final variationNamesPool = [
              'Small',
              'Medium',
              'Large',
              'Extra Large',
              'Family Pack',
              'Combo Pack',
              'Half Portion',
              'Full Portion',
              'Single Shot',
              'Double Shot',
              'Triple Shot',
              'Party Size',
            ];

            final int varCount =
                2 + ((c + s + m) % 11); // Generates between 2 to 12 variations

            for (int v = 0; v < varCount; v++) {
              final double scale = 0.7 + (v * 0.15);
              final String varName =
                  variationNamesPool[v % variationNamesPool.length];

              await db
                  .into(db.menuItemVariationsTable)
                  .insert(
                    MenuItemVariationsTableCompanion.insert(
                      hashId: Value('$fakePrefix${uuid.v4()}'),
                      name: Value(varName),
                      menuItemId: Value(itemId),
                      quantity: const Value(1),
                      purchaseUnit: const Value('portion'),
                      isTodayAvailable: Value(v % 6 != 0),
                      costPrice: Value(costPrice * scale),
                      sellingPrice: Value(sellingPrice * scale),
                      stockQuantity: const Value(100),
                      sortOrderIndex: Value(v + 1),
                      creationDate: Value(startDate.toIso8601String()),
                    ),
                  );
              totalInsertedRecords++;
            }
          }

          // Customer review for every 5th item
          if (m % 5 == 0) {
            final custId = customerIds[(c + s + m) % customerIds.length];
            await db
                .into(db.menuItemReviewsTable)
                .insert(
                  MenuItemReviewsTableCompanion.insert(
                    id: Value(totalInsertedRecords + 100000),
                    itemId: Value(itemId),
                    customerId: Value(custId),
                    rating: Value(4.0 + (m % 3) * 0.5),
                    reviewText: Value(
                      'Delicious $itemName! High quality and fast preparation.',
                    ),
                    reviewDate: Value(getRandomDate()),
                  ),
                );
            totalInsertedRecords++;
          }
        }
      }
    }

    // 5. Inventory & Purchases (20 Items, 150 Purchases)
    onProgress?.call(
      'inventory_purchases',
      'Generating Inventory Items & Stock Purchases...',
      5,
      totalSteps,
    );
    final inventoryNames = [
      'Espresso Beans',
      'Whole Milk',
      'Refined Flour',
      'White Sugar',
      'Green Tea Bags',
      'Cheddar Cheese',
      'Fresh Tomatoes',
      'Cooking Oil',
      'Butter',
      'Mixed Spices',
      'Farm Eggs',
      'Chicken Breast',
      'Basmati Rice',
      'Sparkling Soda',
      'Fresh Fruits',
      'Heavy Cream',
      'Chocolate Syrup',
      'Mozzarella Cheese',
      'Oat Milk',
      'Almond Syrup',
    ];
    final inventoryIds = <int>[];
    for (int i = 0; i < inventoryNames.length; i++) {
      final invId = await db
          .into(db.inventoryTable)
          .insert(
            InventoryTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              name: Value(inventoryNames[i]),
              shortDescription: Value(faker.lorem.sentences(7).join()),
              purchaseUnit: Value(i % 2 == 0 ? 'kg' : 'ltr'),
              currentStock: Value(80.0 + random.nextInt(200)),
              isEnabled: const Value(true),
              createdDate: Value(startDate.toIso8601String()),
            ),
          );
      inventoryIds.add(invId);
      totalInsertedRecords++;
    }

    for (int p = 0; p < 150; p++) {
      final invIndex = random.nextInt(inventoryIds.length);
      final invId = inventoryIds[invIndex];

      DateTime pDate;
      if (p < 5) {
        // Today
        pDate = DateTime(
          now.year,
          now.month,
          now.day,
          random.nextInt(12) + 8,
          random.nextInt(60),
        );
      } else if (p < 20) {
        // Current week (past 1-6 days)
        final daysAgo = random.nextInt(6) + 1;
        final d = now.subtract(Duration(days: daysAgo));
        pDate = DateTime(
          d.year,
          d.month,
          d.day,
          random.nextInt(12) + 8,
          random.nextInt(60),
        );
      } else if (p < 40) {
        // Current month (past 7-25 days)
        final daysAgo = random.nextInt(18) + 7;
        final d = now.subtract(Duration(days: daysAgo));
        pDate = DateTime(
          d.year,
          d.month,
          d.day,
          random.nextInt(12) + 8,
          random.nextInt(60),
        );
      } else {
        // Historical (past 1.5 years)
        pDate = getRandomDate();
      }

      final qty = 15.0 + random.nextInt(50);
      final unitPrice = 45.0 + random.nextInt(220);

      await db
          .into(db.purchaseTable)
          .insert(
            PurchaseTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              inventoryId: Value(invId),
              name: Value(inventoryNames[invIndex]),
              purchaseUnit: Value(invIndex % 2 == 0 ? 'kg' : 'ltr'),
              purchaseQty: Value(qty),
              purchaseDateTime: Value(pDate.toIso8601String()),
              purchasePrice: Value(qty * unitPrice),
              createdDate: Value(pDate.toIso8601String()),
            ),
          );
      totalInsertedRecords++;
    }

    // 6. Reservations (80 entries)
    onProgress?.call(
      'reservations',
      'Generating Table Reservations...',
      6,
      totalSteps,
    );
    for (int r = 0; r < 80; r++) {
      final custIndex = random.nextInt(customerIds.length);
      final custId = customerIds[custIndex];
      final custName = customerNames[custId] ?? 'Customer';
      final rDate = getRandomDate();
      final tableId = tableIds[random.nextInt(tableIds.length)];

      await db
          .into(db.reservationsTable)
          .insert(
            ReservationsTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              customerName: Value(custName),
              phoneNumber: Value(
                '+91 ${faker.randomGenerator.integer(999999999, min: 600000000)}',
              ),
              isoCode: const Value('IN'),
              customerId: Value(custId),
              tableId: Value(tableId),
              tableReservedName: Value('Table ${(r % 12) + 1}'),
              reservationDateTime: Value(rDate.toIso8601String()),
              numberOfPeople: Value(2 + random.nextInt(6)),
              status: Value(
                1 + random.nextInt(2),
              ), // 1: Confirmed, 2: Completed
              notes: Value(faker.lorem.sentence()),
              creationDate: Value(rDate.toIso8601String()),
            ),
          );
      totalInsertedRecords++;
    }

    // 7. Orders, Invoices, Kitchen Orders & Payments
    onProgress?.call(
      'orders_invoices',
      'Generating Active Kitchen Orders, Historical Invoices & Payment Reports...',
      7,
      totalSteps,
    );

    final paymentMethods = ['Cash', 'UPI', 'Credit Card'];

    for (int o = 0; o < 250; o++) {
      final bool isActiveKitchenOrder = o < 20; // 20 active kitchen orders!
      final DateTime oDate = isActiveKitchenOrder
          ? now.subtract(Duration(minutes: 5 + (o * 4)))
          : getRandomDate();

      final custIndex = random.nextInt(customerIds.length);
      final custId = customerIds[custIndex];
      final custName = customerNames[custId] ?? 'Customer';
      final tableId = tableIds[random.nextInt(tableIds.length)];
      final paymentMethod = paymentMethods[o % paymentMethods.length];

      final String orderStatus;
      final String itemStatus;
      if (isActiveKitchenOrder) {
        orderStatus = o % 2 == 0 ? 'inProgress' : 'pending';
        itemStatus = o % 2 == 0 ? 'preparing' : 'pending';
      } else {
        orderStatus = o % 8 == 0 ? 'served' : 'completed';
        itemStatus = 'completed';
      }

      final orderId = await db
          .into(db.ordersTable)
          .insert(
            OrdersTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              tableInfoId: Value(tableId),
              creationDate: Value(oDate.toIso8601String()),
              isCanceled: const Value(false),
              isDeleted: const Value(false),
              status: Value(orderStatus),
              orderType: Value(
                o % 3 == 0 ? 'Dine-In' : (o % 3 == 1 ? 'Takeaway' : 'Delivery'),
              ),
              paymentMethodName: Value(paymentMethod),
              customerId: Value(custId),
              customerName: Value(custName),
              phoneNumber: Value(
                '+91 ${faker.randomGenerator.integer(999999999, min: 600000000)}',
              ),
              isoCode: const Value('IN'),
            ),
          );
      totalInsertedRecords++;

      double subtotal = 0.0;
      final numItems = 1 + random.nextInt(3);
      final addedItemNames = <String>[];
      final addedItemQuantities = <int>[];
      final addedItemPrices = <double>[];

      for (int k = 0; k < numItems; k++) {
        final itemIndex = (o + k) % menuItemIds.length;
        final itemId = menuItemIds[itemIndex];
        final itemName = menuItemNamesMap[itemId] ?? 'Special Coffee';
        final price = menuItemPrices[itemId] ?? 120.0;
        final qty = 1 + random.nextInt(2);
        final itemTotal = price * qty;
        subtotal += itemTotal;

        addedItemNames.add(itemName);
        addedItemQuantities.add(qty);
        addedItemPrices.add(price);

        await db
            .into(db.orderItemsTable)
            .insert(
              OrderItemsTableCompanion.insert(
                orderId: Value(orderId),
                itemId: Value(itemId),
                menuItemId: Value(itemId),
                quantity: Value(qty),
                sellingPrice: Value(price),
                costPrice: Value(price * 0.55),
                status: Value(itemStatus),
                isMenuItem: const Value(true),
                creationDate: Value(oDate.toIso8601String()),
              ),
            );
        totalInsertedRecords++;
      }

      final taxCost = subtotal * 0.05; // 5% GST
      final grandTotal = subtotal + taxCost;

      final invoiceId = await db
          .into(db.invoicesTable)
          .insert(
            InvoicesTableCompanion.insert(
              orderId: Value(orderId),
              hashId: Value('$fakePrefix${uuid.v4()}'),
              taxPercentage: const Value(5.0),
              totalCost: Value(subtotal),
              taxCost: Value(taxCost),
              taxableAmount: Value(subtotal),
              netPaymentAmount: Value(grandTotal),
              recordAmountPaid: Value(grandTotal),
              createdDate: Value(oDate.toIso8601String()),
              customerId: Value(custId),
              customerName: Value(custName),
              phoneNumber: Value(
                '+91 ${faker.randomGenerator.integer(999999999, min: 600000000)}',
              ),
              paymentMethodName: Value(paymentMethod),
            ),
          );
      totalInsertedRecords++;

      for (int k = 0; k < addedItemNames.length; k++) {
        await db
            .into(db.invoiceItemsTable)
            .insert(
              InvoiceItemsTableCompanion.insert(
                invoiceId: Value(invoiceId),
                itemName: Value(addedItemNames[k]),
                quantity: Value(addedItemQuantities[k]),
                sellingPrice: Value(addedItemPrices[k]),
                totalPrice: Value(addedItemPrices[k] * addedItemQuantities[k]),
                createdDate: Value(oDate.toIso8601String()),
              ),
            );
        totalInsertedRecords++;
      }

      await db
          .into(db.paymentTransactionsTable)
          .insert(
            PaymentTransactionsTableCompanion.insert(
              invoiceId: Value(invoiceId),
              amount: Value(grandTotal),
              paymentMethodName: Value(paymentMethod),
              transactionReference: Value(
                'TXN${uuid.v4().substring(0, 8).toUpperCase()}',
              ),
              paymentStatus: const Value('Success'),
              createdDate: Value(oDate.toIso8601String()),
            ),
          );
      totalInsertedRecords++;
    }

    return totalInsertedRecords;
  }

  /// Removes all fake records generated with [fakePrefix], reporting progress steps.
  static Future<void> removeFakeData(
    CoozyDatabase db, {
    FakeDataProgressCallback? onProgress,
  }) async {
    onProgress?.call(
      'cleaning_child_tables',
      'Cleaning dependent records (Order items, Payments, Leaves, Attendance)...',
      1,
      2,
    );
    await db.customStatement(
      "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$fakePrefix%');",
    );
    await db.customStatement(
      "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE hash_id LIKE '$fakePrefix%');",
    );
    await db.customStatement(
      "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE hash_id LIKE '$fakePrefix%');",
    );
    await db.customStatement(
      "DELETE FROM attendance WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$fakePrefix%');",
    );
    await db.customStatement(
      "DELETE FROM leaves WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$fakePrefix%');",
    );
    await db.customStatement(
      "DELETE FROM menu_item_variations WHERE menu_item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$fakePrefix%');",
    );
    await db.customStatement(
      "DELETE FROM menu_item_reviews WHERE item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$fakePrefix%');",
    );
    await db.customStatement(
      "DELETE FROM menu_subcategories WHERE hash_id LIKE '$fakePrefix%' OR category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$fakePrefix%');",
    );

    onProgress?.call(
      'cleaning_parent_tables',
      'Cleaning primary module records (Customers, Staff, Orders, Inventory, Reservations)...',
      2,
      2,
    );
    await db.customStatement(
      "DELETE FROM orders WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM invoices WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM purchase WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM inventory WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM reservations WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM menu_items WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM menu_categories WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM table_info WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM customers WHERE hash_id LIKE '$fakePrefix%';",
    );
    await db.customStatement(
      "DELETE FROM employees WHERE hash_id LIKE '$fakePrefix%';",
    );
  }

  /// Removes specific fake records associated with stage keys.
  static Future<void> removeDatasetData(
    CoozyDatabase db,
    List<String> stageKeys,
  ) async {
    for (final key in stageKeys) {
      if (key == 'customers') {
        await db.customStatement(
          "DELETE FROM customers WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'employees' || key == 'attendance_leaves') {
        await db.customStatement(
          "DELETE FROM attendance WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM leaves WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM employees WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'tables_menu') {
        await db.customStatement(
          "DELETE FROM menu_item_variations WHERE menu_item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_item_reviews WHERE item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_subcategories WHERE hash_id LIKE '$fakePrefix%' OR category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_items WHERE hash_id LIKE '$fakePrefix%';",
        );
        await db.customStatement(
          "DELETE FROM menu_categories WHERE hash_id LIKE '$fakePrefix%';",
        );
        await db.customStatement(
          "DELETE FROM table_info WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'inventory_purchases') {
        await db.customStatement(
          "DELETE FROM purchase WHERE hash_id LIKE '$fakePrefix%';",
        );
        await db.customStatement(
          "DELETE FROM inventory WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'reservations') {
        await db.customStatement(
          "DELETE FROM reservations WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'orders_invoices') {
        await db.customStatement(
          "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM orders WHERE hash_id LIKE '$fakePrefix%';",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE hash_id LIKE '$fakePrefix%';",
        );
      }
    }
  }

  /// Returns current fake record counts per dataset key.
  static Future<Map<String, int>> getDatasetCounts(CoozyDatabase db) async {
    final Map<String, int> counts = {};

    try {
      final cust = await db
          .customSelect(
            "SELECT COUNT(*) as c FROM customers WHERE hash_id LIKE '$fakePrefix%'",
          )
          .getSingle();
      counts['customers'] = cust.read<int>('c');

      final emp = await db
          .customSelect(
            "SELECT COUNT(*) as c FROM employees WHERE hash_id LIKE '$fakePrefix%'",
          )
          .getSingle();
      counts['employees'] = emp.read<int>('c');
      counts['attendance_leaves'] = emp.read<int>('c');

      final orders = await db
          .customSelect(
            "SELECT COUNT(*) as c FROM orders WHERE hash_id LIKE '$fakePrefix%'",
          )
          .getSingle();
      counts['orders_invoices'] = orders.read<int>('c');

      final inv = await db
          .customSelect(
            "SELECT COUNT(*) as c FROM inventory WHERE hash_id LIKE '$fakePrefix%'",
          )
          .getSingle();
      counts['inventory_purchases'] = inv.read<int>('c');

      final res = await db
          .customSelect(
            "SELECT COUNT(*) as c FROM reservations WHERE hash_id LIKE '$fakePrefix%'",
          )
          .getSingle();
      counts['reservations'] = res.read<int>('c');
      counts['tables_menu'] = res.read<int>('c');
    } catch (_) {}

    return counts;
  }
}
