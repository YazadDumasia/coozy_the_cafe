import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart' hide Column;
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

  /// List of all supported individual dataset keys.
  static const List<String> allDatasetKeys = [
    'customers',
    'employees',
    'attendance',
    'leaves',
    'table_info',
    'categories',
    'subcategories',
    'menu_items',
    'recipes',
    'inventory',
    'purchases',
    'reservations',
    'orders',
    'invoices',
  ];

  /// Generates fake records across all modules with stage progress updates.
  static Future<int> generateFakeData(
    CoozyDatabase db, {
    FakeDataProgressCallback? onProgress,
  }) async {
    return await generateDatasetData(
      db,
      allDatasetKeys,
      onProgress: onProgress,
    );
  }

  /// Generates fake records for specific stage keys only.
  static Future<int> generateDatasetData(
    CoozyDatabase db,
    List<String> rawStageKeys, {
    FakeDataProgressCallback? onProgress,
  }) async {
    // Expand composite keys to individual keys if passed
    final Set<String> stageKeys = {};
    for (final k in rawStageKeys) {
      if (k == 'tables_menu') {
        stageKeys.addAll([
          'table_info',
          'categories',
          'subcategories',
          'menu_items',
        ]);
      } else if (k == 'attendance_leaves') {
        stageKeys.addAll(['employees', 'attendance', 'leaves']);
      } else if (k == 'inventory_purchases') {
        stageKeys.addAll(['inventory', 'purchases']);
      } else if (k == 'orders_invoices') {
        stageKeys.addAll([
          'customers',
          'table_info',
          'categories',
          'subcategories',
          'menu_items',
          'orders',
          'invoices',
        ]);
      } else {
        stageKeys.add(k);
      }
    }

    final faker = Faker();
    final random = Random();
    final uuid = const Uuid();
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 547));

    int totalInserted = 0;
    int stepIndex = 0;
    final totalSteps = stageKeys.length;

    DateTime getRandomDate() {
      final diffDays = now.difference(startDate).inDays;
      final randomDays = random.nextInt(diffDays > 0 ? diffDays : 1);
      final randomMinutes = random.nextInt(1440);
      return startDate.add(Duration(days: randomDays, minutes: randomMinutes));
    }

    // 1. Customers
    if (stageKeys.contains('customers')) {
      stepIndex++;
      onProgress?.call(
        'customers',
        'Generating Customers & Contact Info...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateCustomers(
        db,
        faker,
        random,
        uuid,
        now,
        startDate,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 2. Employees
    if (stageKeys.contains('employees')) {
      stepIndex++;
      onProgress?.call(
        'employees',
        'Generating Staff & Employee Profiles...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateEmployees(
        db,
        faker,
        random,
        uuid,
        now,
        startDate,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 3. Attendance
    if (stageKeys.contains('attendance')) {
      stepIndex++;
      onProgress?.call(
        'attendance',
        'Generating Staff Attendance Logs...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateAttendance(db, random, now, startDate);
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 4. Leaves
    if (stageKeys.contains('leaves')) {
      stepIndex++;
      onProgress?.call(
        'leaves',
        'Generating Staff Leave Applications...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateLeaves(db, random, now, startDate);
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 5. Dining Tables
    if (stageKeys.contains('table_info')) {
      stepIndex++;
      onProgress?.call(
        'table_info',
        'Generating Dining Tables...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateDiningTables(db, uuid);
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 6. Categories
    if (stageKeys.contains('categories')) {
      stepIndex++;
      onProgress?.call(
        'categories',
        'Generating Menu Categories...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateCategories(db, uuid, startDate);
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 7. Subcategories
    if (stageKeys.contains('subcategories')) {
      stepIndex++;
      onProgress?.call(
        'subcategories',
        'Generating Menu Subcategories...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateSubcategories(db, uuid, startDate);
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 8. Menu Items & Variations
    if (stageKeys.contains('menu_items')) {
      stepIndex++;
      onProgress?.call(
        'menu_items',
        'Generating Menu Items, Variations & Reviews...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateMenuItems(
        db,
        random,
        uuid,
        startDate,
        getRandomDate,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 9. Recipes
    if (stageKeys.contains('recipes')) {
      stepIndex++;
      onProgress?.call(
        'recipes',
        'Generating Cafe Recipes...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateRecipes(db, random);
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 10. Inventory Raw Stock
    if (stageKeys.contains('inventory')) {
      stepIndex++;
      onProgress?.call(
        'inventory',
        'Generating Inventory Raw Items...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateInventory(
        db,
        faker,
        random,
        uuid,
        startDate,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 11. Stock Purchases
    if (stageKeys.contains('purchases')) {
      stepIndex++;
      onProgress?.call(
        'purchases',
        'Generating Stock Purchase Records...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generatePurchases(
        db,
        random,
        uuid,
        now,
        startDate,
        getRandomDate,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 12. Reservations
    if (stageKeys.contains('reservations')) {
      stepIndex++;
      onProgress?.call(
        'reservations',
        'Generating Table Reservations...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateReservations(
        db,
        faker,
        random,
        uuid,
        now,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 13. Orders
    if (stageKeys.contains('orders')) {
      stepIndex++;
      onProgress?.call(
        'orders',
        'Generating Customer Orders...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateOrders(
        db,
        faker,
        random,
        uuid,
        now,
        getRandomDate,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    // 14. Invoices & Payments
    if (stageKeys.contains('invoices')) {
      stepIndex++;
      onProgress?.call(
        'invoices',
        'Generating Invoices & Payment Transactions...',
        stepIndex,
        totalSteps,
      );
      totalInserted += await _generateInvoices(
        db,
        faker,
        random,
        uuid,
        now,
        getRandomDate,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    return totalInserted;
  }

  // --- INDIVIDUAL GENERATOR HELPERS ---

  static Future<int> _generateCustomers(
    CoozyDatabase db,
    Faker faker,
    Random random,
    Uuid uuid,
    DateTime now,
    DateTime startDate,
  ) async {
    final list = <CustomersTableCompanion>[];
    for (int i = 0; i < 250; i++) {
      final custName = faker.person.name();
      final phone = '+91 ${random.nextInt(899999999) + 100000000}';
      final diffDays = now.difference(startDate).inDays;
      final randomDays = random.nextInt(diffDays > 0 ? diffDays : 1);
      final created = startDate.add(
        Duration(days: randomDays, minutes: random.nextInt(1440)),
      );
      list.add(
        CustomersTableCompanion.insert(
          hashId: Value('$fakePrefix${uuid.v4()}'),
          name: Value(custName),
          phoneNumber: Value(phone),
          isoCode: const Value('IN'),
          createdDate: Value(created.toIso8601String()),
        ),
      );
    }
    await db.batch((b) {
      b.insertAll(db.customersTable, list);
    });
    return list.length;
  }

  static Future<int> _generateEmployees(
    CoozyDatabase db,
    Faker faker,
    Random random,
    Uuid uuid,
    DateTime now,
    DateTime startDate,
  ) async {
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

    final list = <EmployeesTableCompanion>[];
    for (int i = 0; i < 100; i++) {
      final empName = faker.person.name();
      final phone = '+91 ${random.nextInt(899999999) + 100000000}';
      final pos = positions[i % positions.length];
      final diffDays = now.difference(startDate).inDays;
      final randomDays = random.nextInt(diffDays > 0 ? diffDays : 1);
      final joining = startDate.add(
        Duration(days: randomDays, minutes: random.nextInt(1440)),
      );
      final email = faker.internet.email();
      final salary = 18000.0 + random.nextInt(40000);

      list.add(
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
    }
    await db.batch((b) {
      b.insertAll(db.employeesTable, list);
    });
    return list.length;
  }

  static Future<int> _generateAttendance(
    CoozyDatabase db,
    Random random,
    DateTime now,
    DateTime startDate,
  ) async {
    // Fetch employees (create sample if none exist)
    var employees = await db.select(db.employeesTable).get();
    if (employees.isEmpty) {
      await _generateEmployees(
        db,
        Faker(),
        random,
        const Uuid(),
        now,
        startDate,
      );
      employees = await db.select(db.employeesTable).get();
    }

    final attendanceCompanions = <AttendanceTableCompanion>[];
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

    final currentDay = now.day;
    for (int day = 1; day <= currentDay; day++) {
      final dayDate = DateTime(now.year, now.month, day, 9, 0);
      for (final emp in employees) {
        final randType = random.nextDouble();
        int status = randType < 0.80 ? 1 : (randType < 0.92 ? 2 : 3);
        String checkInStr = status == 1
            ? checkInTimes[random.nextInt(checkInTimes.length)]
            : (status == 2 ? '09:00 AM' : 'N/A');
        String checkOutStr = status == 1
            ? checkOutTimes[random.nextInt(checkOutTimes.length)]
            : (status == 2 ? '01:00 PM' : 'N/A');
        String durationStr = status == 1
            ? '8 hours 30 mins'
            : (status == 2 ? '4 hours (Half Day)' : 'Absent / On Leave');

        attendanceCompanions.add(
          AttendanceTableCompanion.insert(
            employeeId: Value(emp.id),
            employeeName: Value(emp.name ?? 'Staff'),
            employeePosition: Value(emp.position ?? 'Staff'),
            currentStatus: Value(status),
            checkIn: Value(checkInStr),
            checkOut: Value(checkOutStr),
            employeeWorkingDurations: Value(durationStr),
            creationDate: Value(dayDate.toIso8601String()),
            isDeleted: const Value(false),
          ),
        );
      }
    }

    await db.batch((b) {
      b.insertAll(db.attendanceTable, attendanceCompanions);
    });
    return attendanceCompanions.length;
  }

  static Future<int> _generateLeaves(
    CoozyDatabase db,
    Random random,
    DateTime now,
    DateTime startDate,
  ) async {
    var employees = await db.select(db.employeesTable).get();
    if (employees.isEmpty) {
      await _generateEmployees(
        db,
        Faker(),
        random,
        const Uuid(),
        now,
        startDate,
      );
      employees = await db.select(db.employeesTable).get();
    }

    final fullDayLeaveReasons = [
      'Full Day Leave - Medical Emergency & Doctor Advice',
      'Full Day Leave - Family Function & Relative Wedding',
      'Full Day Leave - Annual Paid Vacation',
      'Full Day Leave - Personal Work & Bank Visit',
      'Full Day Leave - Sick Leave (Fever & Rest)',
    ];
    final halfDayLeaveReasons = [
      'Half Day Leave - Morning Shift (Doctor Visit)',
      'Half Day Leave - Afternoon Shift (Urgent Family Errand)',
      'Half Day Leave - Morning Shift (Personal Work)',
    ];

    final leaveCompanions = <LeavesTableCompanion>[];
    for (int i = 0; i < 200; i++) {
      final emp = employees[random.nextInt(employees.length)];
      final diffDays = now.difference(startDate).inDays;
      final leaveDate = startDate.add(
        Duration(days: random.nextInt(diffDays > 0 ? diffDays : 1)),
      );

      final isHalfDay = random.nextBool();
      final reason = isHalfDay
          ? halfDayLeaveReasons[random.nextInt(halfDayLeaveReasons.length)]
          : fullDayLeaveReasons[random.nextInt(fullDayLeaveReasons.length)];
      final endDate = isHalfDay
          ? leaveDate
          : leaveDate.add(Duration(days: 1 + random.nextInt(2)));
      final status = random.nextDouble() < 0.75 ? 1 : 2;

      leaveCompanions.add(
        LeavesTableCompanion.insert(
          employeeId: Value(emp.id),
          employeeName: Value(emp.name ?? 'Staff'),
          employeePosition: Value(emp.position ?? 'Staff'),
          currentStatus: Value(status),
          startDate: Value(leaveDate.toIso8601String()),
          endDate: Value(endDate.toIso8601String()),
          reason: Value(reason),
          creationDate: Value(leaveDate.toIso8601String()),
          isDeleted: const Value(false),
        ),
      );
    }

    await db.batch((b) {
      b.insertAll(db.leavesTable, leaveCompanions);
    });
    return leaveCompanions.length;
  }

  static Future<int> _generateDiningTables(CoozyDatabase db, Uuid uuid) async {
    int inserted = 0;
    for (int i = 1; i <= 12; i++) {
      await db
          .into(db.tableInfoTable)
          .insert(
            TableInfoTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              tableLabel: Value('Table $i (Demo)'),
              tableNo: Value('T-$i'),
              colorValue: const Value('4280391411'),
              sortOrderIndex: Value(i),
              nosOfChairs: Value(2 + (i % 4) * 2),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  static Future<int> _generateCategories(
    CoozyDatabase db,
    Uuid uuid,
    DateTime startDate,
  ) async {
    final categoryNames = [
      'Beverages',
      'Main Course',
      'Desserts',
      'Starters & Appetizers',
      'Snacks & Quick Bites',
      'Bakery & Pastries',
      'Breakfast Specials',
    ];

    int inserted = 0;
    for (int c = 0; c < categoryNames.length; c++) {
      await db
          .into(db.categoriesTable)
          .insert(
            CategoriesTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              name: Value(categoryNames[c]),
              isActive: const Value(true),
              position: Value(c + 1),
              createdDate: Value(startDate.toIso8601String()),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  static Future<int> _generateSubcategories(
    CoozyDatabase db,
    Uuid uuid,
    DateTime startDate,
  ) async {
    var categories = await db.select(db.categoriesTable).get();
    if (categories.isEmpty) {
      await _generateCategories(db, uuid, startDate);
      categories = await db.select(db.categoriesTable).get();
    }

    final subcategoryPrefixes = [
      'Classic Specials',
      'Gourmet Choice',
      'Chef Signature',
    ];

    int inserted = 0;
    for (final cat in categories) {
      for (int s = 0; s < subcategoryPrefixes.length; s++) {
        await db
            .into(db.subcategoriesTable)
            .insert(
              SubcategoriesTableCompanion.insert(
                hashId: Value('$fakePrefix${uuid.v4()}'),
                name: Value('${cat.name} - ${subcategoryPrefixes[s]}'),
                categoryId: Value(cat.id),
                isActive: const Value(true),
                position: Value(s + 1),
                createdDate: Value(startDate.toIso8601String()),
              ),
            );
        inserted++;
      }
    }
    return inserted;
  }

  static Future<int> _generateMenuItems(
    CoozyDatabase db,
    Random random,
    Uuid uuid,
    DateTime startDate,
    DateTime Function() getRandomDate,
  ) async {
    var categories = await db.select(db.categoriesTable).get();
    if (categories.isEmpty) {
      await _generateCategories(db, uuid, startDate);
      categories = await db.select(db.categoriesTable).get();
    }

    var subcategories = await db.select(db.subcategoriesTable).get();
    if (subcategories.isEmpty) {
      await _generateSubcategories(db, uuid, startDate);
      subcategories = await db.select(db.subcategoriesTable).get();
    }

    final itemPrefixes = ['Classic', 'Deluxe', 'Special', 'Gourmet'];
    int inserted = 0;

    for (int i = 0; i < 28; i++) {
      final cat = categories[i % categories.length];
      final subCat = subcategories[i % subcategories.length];
      final itemName =
          '${itemPrefixes[i % itemPrefixes.length]} ${cat.name} #${i + 1}';
      final sellingPrice = 90.0 + random.nextInt(350);
      final costPrice = sellingPrice * 0.55;
      final bool isSimple = i % 2 == 0;

      final itemId = await db
          .into(db.menuItemsTable)
          .insert(
            MenuItemsTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              name: itemName,
              description: 'Delicious $itemName prepared fresh daily.',
              foodType: Value(i % 2 == 0 ? 'Veg' : 'Non-Veg'),
              creationDate: Value(startDate.toIso8601String()),
              duration: const Value(15),
              categoryId: Value(cat.id),
              subcategoryId: Value(subCat.id),
              isTodayAvailable: const Value(true),
              isSimpleVariation: Value(isSimple),
              costPrice: Value(costPrice),
              sellingPrice: Value(sellingPrice),
              stockQuantity: const Value(150),
              quantity: const Value('1'),
              purchaseUnit: const Value('portion'),
              sortOrderIndex: Value(i + 1),
            ),
          );
      inserted++;

      if (isSimple) {
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
        inserted++;
      } else {
        final variationNamesPool = ['Small', 'Medium', 'Large'];
        for (int v = 0; v < variationNamesPool.length; v++) {
          final scale = 0.7 + (v * 0.2);
          await db
              .into(db.menuItemVariationsTable)
              .insert(
                MenuItemVariationsTableCompanion.insert(
                  hashId: Value('$fakePrefix${uuid.v4()}'),
                  name: Value(variationNamesPool[v]),
                  menuItemId: Value(itemId),
                  quantity: const Value(1),
                  purchaseUnit: const Value('portion'),
                  isTodayAvailable: Value(v % 2 == 0),
                  costPrice: Value(costPrice * scale),
                  sellingPrice: Value(sellingPrice * scale),
                  stockQuantity: const Value(100),
                  sortOrderIndex: Value(v + 1),
                  creationDate: Value(startDate.toIso8601String()),
                ),
              );
          inserted++;
        }
      }
    }
    return inserted;
  }

  static Future<int> _generateRecipes(CoozyDatabase db, Random random) async {
    final recipeNames = [
      'Espresso Cappuccino Blend',
      'Gourmet Paneer Tikka Wrap',
      'Artisanal Chocolate Mousse',
      'Classic Cold Coffee Smooth',
      'Crispy Veg Spring Rolls',
      'Fresh Garden Berry Smoothie',
      'Cheesy Loaded Fries Supreme',
      'Tuscan Grilled Chicken Sandwich',
    ];

    int inserted = 0;
    for (int i = 0; i < recipeNames.length; i++) {
      await db
          .into(db.recipesTable)
          .insert(
            RecipesTableCompanion.insert(
              recipeOriginalName: Value('$fakePrefix${recipeNames[i]}'),
              translatedRecipeName: Value(recipeNames[i]),
              recipeOriginalIngredients: Value(
                'Ingredient A, Ingredient B, Special Spice Mix',
              ),
              recipeTranslatedIngredientList: Value('Coffee, Milk, Sugar, Ice'),
              recipePreparationTimeInMins: Value(5 + random.nextInt(10)),
              recipeCookingTimeInMins: Value(5 + random.nextInt(15)),
              recipeTotalTimeInMins: Value(10 + random.nextInt(25)),
              recipeServings: Value(1 + random.nextInt(3)),
              recipeCuisine: Value(i % 2 == 0 ? 'Italian' : 'Continental'),
              recipeCourse: Value('Main Course'),
              recipeDiet: Value(i % 2 == 0 ? 'Vegetarian' : 'Non-Vegetarian'),
              isBookmark: Value(i % 2 == 0),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  static Future<int> _generateInventory(
    CoozyDatabase db,
    Faker faker,
    Random random,
    Uuid uuid,
    DateTime startDate,
  ) async {
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
    ];

    int inserted = 0;
    for (int i = 0; i < inventoryNames.length; i++) {
      await db
          .into(db.inventoryTable)
          .insert(
            InventoryTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              name: Value(inventoryNames[i]),
              shortDescription: Value(faker.lorem.sentence()),
              purchaseUnit: Value(i % 2 == 0 ? 'kg' : 'ltr'),
              currentStock: Value(80.0 + random.nextInt(200)),
              isEnabled: const Value(true),
              createdDate: Value(startDate.toIso8601String()),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  static Future<int> _generatePurchases(
    CoozyDatabase db,
    Random random,
    Uuid uuid,
    DateTime now,
    DateTime startDate,
    DateTime Function() getRandomDate,
  ) async {
    var inventory = await db.select(db.inventoryTable).get();
    if (inventory.isEmpty) {
      await _generateInventory(db, Faker(), random, uuid, startDate);
      inventory = await db.select(db.inventoryTable).get();
    }

    int inserted = 0;
    for (int p = 0; p < 100; p++) {
      final inv = inventory[random.nextInt(inventory.length)];
      final pDate = getRandomDate();
      final qty = 10.0 + random.nextInt(40);
      final unitPrice = 50.0 + random.nextInt(150);

      await db
          .into(db.purchaseTable)
          .insert(
            PurchaseTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              inventoryId: Value(inv.id),
              name: Value(inv.name ?? 'Raw Material'),
              purchaseUnit: Value(inv.purchaseUnit ?? 'kg'),
              purchaseQty: Value(qty),
              purchaseDateTime: Value(pDate.toIso8601String()),
              purchasePrice: Value(qty * unitPrice),
              createdDate: Value(pDate.toIso8601String()),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  static Future<int> _generateReservations(
    CoozyDatabase db,
    Faker faker,
    Random random,
    Uuid uuid,
    DateTime now,
  ) async {
    var customers = await db.select(db.customersTable).get();
    if (customers.isEmpty) {
      await _generateCustomers(
        db,
        faker,
        random,
        uuid,
        now,
        now.subtract(const Duration(days: 100)),
      );
      customers = await db.select(db.customersTable).get();
    }

    var tables = await db.select(db.tableInfoTable).get();
    if (tables.isEmpty) {
      await _generateDiningTables(db, uuid);
      tables = await db.select(db.tableInfoTable).get();
    }

    var menuItems = await db.select(db.menuItemsTable).get();
    if (menuItems.isEmpty) {
      await _generateMenuItems(
        db,
        random,
        uuid,
        now.subtract(const Duration(days: 100)),
        () => now,
      );
      menuItems = await db.select(db.menuItemsTable).get();
    }

    int inserted = 0;
    final todayStart = DateTime(now.year, now.month, now.day);

    String generateRandomPreOrders(Random random, List<dynamic> menuItems) {
      if (menuItems.isEmpty || random.nextDouble() > 0.6) return '';
      final count = 1 + random.nextInt(3);
      final List<Map<String, dynamic>> items = [];
      for (int i = 0; i < count; i++) {
        final item = menuItems[random.nextInt(menuItems.length)];
        items.add({
          'id': item.id,
          'item_name': item.name ?? 'Cafe Item',
          'quantity': 1 + random.nextInt(3),
          'price': item.price ?? 5.0,
        });
      }
      return 'PRE_ORDERED_ITEMS:${jsonEncode(items)}';
    }

    // 1. Current Reservations: 15 records for Today
    for (int r = 0; r < 15; r++) {
      final cust = customers[random.nextInt(customers.length)];
      final table = tables[random.nextInt(tables.length)];
      final rDate = todayStart.add(
        Duration(
          hours: 9 + random.nextInt(13),
          minutes: random.nextInt(4) * 15,
        ),
      );

      final preOrdersStr = generateRandomPreOrders(random, menuItems);
      final baseNotes = faker.lorem.sentence();
      final finalNotes = preOrdersStr.isNotEmpty
          ? '$baseNotes\n$preOrdersStr'
          : baseNotes;

      await db
          .into(db.reservationsTable)
          .insert(
            ReservationsTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              customerName: Value(cust.name ?? 'Customer'),
              phoneNumber: Value(cust.phoneNumber ?? '+91 9876543210'),
              isoCode: const Value('IN'),
              customerId: Value(cust.id),
              tableId: Value(table.id),
              tableReservedName: Value(table.tableLabel ?? 'Table 1'),
              reservationDateTime: Value(rDate.toIso8601String()),
              numberOfPeople: Value(1 + random.nextInt(8)),
              status: Value(random.nextInt(2)),
              notes: Value(finalNotes),
              creationDate: Value(now.toIso8601String()),
            ),
          );
      inserted++;
    }

    // 2. Upcoming Reservations: 200 records spanning next day to 2 weeks (days 1 to 14)
    for (int r = 0; r < 200; r++) {
      final cust = customers[random.nextInt(customers.length)];
      final table = tables[random.nextInt(tables.length)];
      final dayOffset = 1 + random.nextInt(14);
      final rDate = todayStart.add(
        Duration(
          days: dayOffset,
          hours: 9 + random.nextInt(13),
          minutes: random.nextInt(4) * 15,
        ),
      );

      final preOrdersStr = generateRandomPreOrders(random, menuItems);
      final baseNotes = faker.lorem.sentence();
      final finalNotes = preOrdersStr.isNotEmpty
          ? '$baseNotes\n$preOrdersStr'
          : baseNotes;

      await db
          .into(db.reservationsTable)
          .insert(
            ReservationsTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              customerName: Value(cust.name ?? 'Customer'),
              phoneNumber: Value(cust.phoneNumber ?? '+91 9876543210'),
              isoCode: const Value('IN'),
              customerId: Value(cust.id),
              tableId: Value(table.id),
              tableReservedName: Value(table.tableLabel ?? 'Table 1'),
              reservationDateTime: Value(rDate.toIso8601String()),
              numberOfPeople: Value(1 + random.nextInt(8)),
              status: Value(random.nextInt(2)),
              notes: Value(finalNotes),
              creationDate: Value(now.toIso8601String()),
            ),
          );
      inserted++;
    }

    return inserted;
  }

  static Future<int> _generateOrders(
    CoozyDatabase db,
    Faker faker,
    Random random,
    Uuid uuid,
    DateTime now,
    DateTime Function() getRandomDate,
  ) async {
    var customers = await db.select(db.customersTable).get();
    if (customers.isEmpty) {
      await _generateCustomers(
        db,
        faker,
        random,
        uuid,
        now,
        now.subtract(const Duration(days: 100)),
      );
      customers = await db.select(db.customersTable).get();
    }

    var tables = await db.select(db.tableInfoTable).get();
    if (tables.isEmpty) {
      await _generateDiningTables(db, uuid);
      tables = await db.select(db.tableInfoTable).get();
    }

    var menuItems = await db.select(db.menuItemsTable).get();
    if (menuItems.isEmpty) {
      await _generateMenuItems(
        db,
        random,
        uuid,
        now.subtract(const Duration(days: 100)),
        getRandomDate,
      );
      menuItems = await db.select(db.menuItemsTable).get();
    }

    int inserted = 0;
    for (int o = 0; o < 150; o++) {
      final cust = customers[random.nextInt(customers.length)];
      final table = tables[random.nextInt(tables.length)];
      final oDate = getRandomDate();

      final orderId = await db
          .into(db.ordersTable)
          .insert(
            OrdersTableCompanion.insert(
              hashId: Value('$fakePrefix${uuid.v4()}'),
              tableInfoId: Value(table.id),
              creationDate: Value(oDate.toIso8601String()),
              isCanceled: const Value(false),
              isDeleted: const Value(false),
              status: Value(o % 10 == 0 ? 'inProgress' : 'completed'),
              orderType: Value(o % 2 == 0 ? 'Dine-In' : 'Takeaway'),
              paymentMethodName: const Value('UPI'),
              customerId: Value(cust.id),
              customerName: Value(cust.name ?? 'Customer'),
              phoneNumber: Value(cust.phoneNumber ?? '+91 9876543210'),
              isoCode: const Value('IN'),
            ),
          );
      inserted++;

      final item = menuItems[random.nextInt(menuItems.length)];
      await db
          .into(db.orderItemsTable)
          .insert(
            OrderItemsTableCompanion.insert(
              orderId: Value(orderId),
              itemId: Value(item.id),
              menuItemId: Value(item.id),
              quantity: Value(1 + random.nextInt(2)),
              sellingPrice: Value(item.sellingPrice ?? 120.0),
              costPrice: Value((item.sellingPrice ?? 120.0) * 0.55),
              status: const Value('completed'),
              isMenuItem: const Value(true),
              creationDate: Value(oDate.toIso8601String()),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  static Future<int> _generateInvoices(
    CoozyDatabase db,
    Faker faker,
    Random random,
    Uuid uuid,
    DateTime now,
    DateTime Function() getRandomDate,
  ) async {
    var orders = await db.select(db.ordersTable).get();
    if (orders.isEmpty) {
      await _generateOrders(db, faker, random, uuid, now, getRandomDate);
      orders = await db.select(db.ordersTable).get();
    }

    int inserted = 0;
    for (final order in orders.take(100)) {
      final subtotal = 250.0 + random.nextInt(500);
      final tax = subtotal * 0.05;
      final total = subtotal + tax;

      final invoiceId = await db
          .into(db.invoicesTable)
          .insert(
            InvoicesTableCompanion.insert(
              orderId: Value(order.id),
              hashId: Value('$fakePrefix${uuid.v4()}'),
              taxPercentage: const Value(5.0),
              totalCost: Value(subtotal),
              taxCost: Value(tax),
              taxableAmount: Value(subtotal),
              netPaymentAmount: Value(total),
              recordAmountPaid: Value(total),
              createdDate: Value(order.creationDate ?? now.toIso8601String()),
              customerId: Value(order.customerId),
              customerName: Value(order.customerName ?? 'Customer'),
              phoneNumber: Value(order.phoneNumber ?? '+91 9876543210'),
              paymentMethodName: const Value('UPI'),
            ),
          );
      inserted++;

      await db
          .into(db.invoiceItemsTable)
          .insert(
            InvoiceItemsTableCompanion.insert(
              invoiceId: Value(invoiceId),
              itemName: const Value('Special Item'),
              quantity: const Value(2),
              sellingPrice: Value(subtotal / 2),
              totalPrice: Value(subtotal),
              createdDate: Value(order.creationDate ?? now.toIso8601String()),
            ),
          );
      inserted++;

      await db
          .into(db.paymentTransactionsTable)
          .insert(
            PaymentTransactionsTableCompanion.insert(
              invoiceId: Value(invoiceId),
              amount: Value(total),
              paymentMethodName: const Value('UPI'),
              transactionReference: Value(
                'TXN${uuid.v4().substring(0, 8).toUpperCase()}',
              ),
              paymentStatus: const Value('Success'),
              createdDate: Value(order.creationDate ?? now.toIso8601String()),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  /// Removes all fake records.
  static Future<void> removeFakeData(
    CoozyDatabase db, {
    FakeDataProgressCallback? onProgress,
  }) async {
    await removeDatasetData(db, allDatasetKeys, onProgress: onProgress);
  }

  static const List<String> deletionOrder = [
    'invoices',
    'orders',
    'reservations',
    'purchases',
    'recipes',
    'inventory',
    'menu_items',
    'subcategories',
    'categories',
    'attendance',
    'leaves',
    'employees',
    'customers',
    'table_info',
  ];

  /// Removes specific fake records associated with stage keys.
  static Future<void> removeDatasetData(
    CoozyDatabase db,
    List<String> rawStageKeys, {
    FakeDataProgressCallback? onProgress,
  }) async {
    final expandedKeys = <String>{};
    for (final key in rawStageKeys) {
      if (key == 'tables_menu') {
        expandedKeys.addAll([
          'table_info',
          'categories',
          'subcategories',
          'menu_items',
        ]);
      } else if (key == 'attendance_leaves') {
        expandedKeys.addAll(['employees', 'attendance', 'leaves']);
      } else if (key == 'inventory_purchases') {
        expandedKeys.addAll(['inventory', 'purchases']);
      } else if (key == 'orders_invoices') {
        expandedKeys.addAll(['orders', 'invoices']);
      } else {
        expandedKeys.add(key);
      }
    }

    final sortedKeys = expandedKeys.toList()
      ..sort((a, b) {
        final indexA = deletionOrder.indexOf(a);
        final indexB = deletionOrder.indexOf(b);
        return (indexA == -1 ? 99 : indexA).compareTo(
          indexB == -1 ? 99 : indexB,
        );
      });

    int stepIndex = 0;
    final totalSteps = sortedKeys.length;

    for (final key in sortedKeys) {
      stepIndex++;
      onProgress?.call(
        key,
        'Cleaning up $key fake records...',
        stepIndex,
        totalSteps,
      );
      if (key == 'invoices') {
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'orders') {
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM orders WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'reservations') {
        await db.customStatement(
          "DELETE FROM reservations WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'purchases') {
        await db.customStatement(
          "DELETE FROM purchase WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'recipes') {
        await db.customStatement(
          "DELETE FROM recipes WHERE recipe_original_name LIKE '$fakePrefix%';",
        );
      } else if (key == 'inventory') {
        await db.customStatement(
          "DELETE FROM purchase WHERE inventory_id IN (SELECT id FROM inventory WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM inventory WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'menu_items') {
        await db.customStatement(
          "DELETE FROM order_items WHERE menu_item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_item_variations WHERE menu_item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_item_reviews WHERE item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_items WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'subcategories') {
        await db.customStatement(
          "DELETE FROM menu_item_variations WHERE menu_item_id IN (SELECT id FROM menu_items WHERE subcategory_id IN (SELECT id FROM menu_subcategories WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM menu_item_reviews WHERE item_id IN (SELECT id FROM menu_items WHERE subcategory_id IN (SELECT id FROM menu_subcategories WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM menu_items WHERE subcategory_id IN (SELECT id FROM menu_subcategories WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_subcategories WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'categories') {
        await db.customStatement(
          "DELETE FROM menu_item_variations WHERE menu_item_id IN (SELECT id FROM menu_items WHERE category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM menu_item_reviews WHERE item_id IN (SELECT id FROM menu_items WHERE category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM menu_items WHERE category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_subcategories WHERE category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM menu_categories WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'attendance') {
        await db.customStatement(
          "DELETE FROM attendance WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$fakePrefix%');",
        );
      } else if (key == 'leaves') {
        await db.customStatement(
          "DELETE FROM leaves WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$fakePrefix%');",
        );
      } else if (key == 'employees') {
        await db.customStatement(
          "DELETE FROM attendance WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM leaves WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM employees WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'customers') {
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM orders WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM reservations WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM customers WHERE hash_id LIKE '$fakePrefix%';",
        );
      } else if (key == 'table_info') {
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$fakePrefix%')));",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$fakePrefix%')));",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$fakePrefix%'));",
        );
        await db.customStatement(
          "DELETE FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM reservations WHERE table_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$fakePrefix%');",
        );
        await db.customStatement(
          "DELETE FROM table_info WHERE hash_id LIKE '$fakePrefix%';",
        );
      }
    }
  }

  /// Returns current fake record counts per dataset key.
  static Future<Map<String, int>> getDatasetCounts(CoozyDatabase db) async {
    final Map<String, int> counts = {};

    Future<int> queryCount(String sql) async {
      try {
        final res = await db.customSelect(sql).getSingle();
        return res.read<int>('c');
      } catch (_) {
        return 0;
      }
    }

    counts['customers'] = await queryCount(
      "SELECT COUNT(*) as c FROM customers WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['employees'] = await queryCount(
      "SELECT COUNT(*) as c FROM employees WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['attendance'] = await queryCount(
      "SELECT COUNT(*) as c FROM attendance WHERE creation_date IS NOT NULL",
    );
    counts['leaves'] = await queryCount(
      "SELECT COUNT(*) as c FROM leaves WHERE creation_date IS NOT NULL",
    );
    counts['table_info'] = await queryCount(
      "SELECT COUNT(*) as c FROM table_info WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['categories'] = await queryCount(
      "SELECT COUNT(*) as c FROM menu_categories WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['subcategories'] = await queryCount(
      "SELECT COUNT(*) as c FROM menu_subcategories WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['menu_items'] = await queryCount(
      "SELECT COUNT(*) as c FROM menu_items WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['recipes'] = await queryCount(
      "SELECT COUNT(*) as c FROM recipes WHERE recipe_original_name LIKE '$fakePrefix%'",
    );
    counts['inventory'] = await queryCount(
      "SELECT COUNT(*) as c FROM inventory WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['purchases'] = await queryCount(
      "SELECT COUNT(*) as c FROM purchase WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['reservations'] = await queryCount(
      "SELECT COUNT(*) as c FROM reservations WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['orders'] = await queryCount(
      "SELECT COUNT(*) as c FROM orders WHERE hash_id LIKE '$fakePrefix%'",
    );
    counts['invoices'] = await queryCount(
      "SELECT COUNT(*) as c FROM invoices WHERE hash_id LIKE '$fakePrefix%'",
    );

    // Composite keys for backward compatibility
    counts['tables_menu'] =
        (counts['menu_items'] ?? 0) + (counts['table_info'] ?? 0);
    counts['attendance_leaves'] =
        (counts['attendance'] ?? 0) + (counts['leaves'] ?? 0);
    counts['inventory_purchases'] =
        (counts['inventory'] ?? 0) + (counts['purchases'] ?? 0);
    counts['orders_invoices'] =
        (counts['orders'] ?? 0) + (counts['invoices'] ?? 0);

    return counts;
  }

  /// Shows a quick module-level fake data toggle dialog.
  static Future<void> showFakeDataToggleDialog({
    required BuildContext context,
    required String title,
    required List<String> stageKeys,
    required VoidCallback onRefresh,
  }) async {
    final database = GetIt.instance<CoozyDatabase>();
    final counts = await getDatasetCounts(database);
    final isPresent = stageKeys.any((key) => (counts[key] ?? 0) > 0);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.data_array_rounded, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fake $title Data',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPresent
                        ? 'Fake $title data is currently ACTIVE in database.'
                        : 'Fake $title data is currently INACTIVE.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isPresent
                          ? Colors.green.shade800
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPresent
                        ? Colors.red.shade600
                        : Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          try {
                            if (isPresent) {
                              await removeDatasetData(database, stageKeys);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Fake $title data removed.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            } else {
                              final count = await generateDatasetData(
                                database,
                                stageKeys,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Generated $count fake $title records!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                            onRefresh();
                          } finally {
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          }
                        },
                  icon: Icon(
                    isPresent ? Icons.delete_outline : Icons.add_rounded,
                  ),
                  label: Text(isPresent ? 'Remove Data' : 'Populate Data'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
