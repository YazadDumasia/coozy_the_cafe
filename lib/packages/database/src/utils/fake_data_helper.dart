import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart' hide Column;
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';

typedef FakeDataProgressCallback =
    void Function(
      String stageKey,
      String stageDescription,
      int currentStep,
      int totalSteps,
    );

/// Key used to persist the seed-data session token in SharedPreferences.
const _kSeedTokenKey = 'coozy_seed_data_token';

class FakeDataHelper {
  /// Returns the stored seed token, or generates and stores a new one.
  /// The token is an 8-char lowercase hex string embedded as the first
  /// segment of every seed-record hashId (e.g. "a1b2c3d4-xxxx-…").
  /// This keeps hashIds looking like normal UUIDs while still allowing
  /// targeted bulk-delete without any visible "FAKE_" label.
  static Future<String> _getSeedToken() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(_kSeedTokenKey);
    if (token == null || token.isEmpty) {
      token = _randomHex8();
      await prefs.setString(_kSeedTokenKey, token);
    }
    return token;
  }

  static String _randomHex8() {
    final rng = Random.secure();
    return List.generate(8, (_) => rng.nextInt(16).toRadixString(16)).join();
  }

  /// Generates a hashId that looks like a real UUID but has the seed token
  /// embedded as the first 8 hex chars so we can query it later.
  static String _seedId(String token) {
    final rest = const Uuid().v4().substring(8); // "-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    return '$token$rest';
  }

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

  /// Generates seed records across all modules with stage progress updates.
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

  /// Generates seed records for specific stage keys only.
  static Future<int> generateDatasetData(
    CoozyDatabase db,
    List<String> rawStageKeys, {
    FakeDataProgressCallback? onProgress,
  }) async {
    final token = await _getSeedToken();

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
        token,
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
        token,
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
      totalInserted += await _generateDiningTables(db, token);
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
      totalInserted += await _generateCategories(db, token, startDate);
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
      totalInserted += await _generateSubcategories(db, token, startDate);
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
        token,
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
        token,
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
        token,
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
        token,
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
        token,
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
        token,
        now,
        getRandomDate,
      );
      await Future.delayed(const Duration(milliseconds: 1));
    }

    return totalInserted;
  }

  // --- INDIVIDUAL GENERATOR HELPERS ---

  // Real Indian customer names for the Coozy The Cafe demo dataset
  static const List<String> _customerNames = [
    'Aarav Mehta', 'Priya Sharma', 'Rohan Desai', 'Sneha Iyer', 'Karan Patel',
    'Ananya Nair', 'Vikram Singh', 'Pooja Joshi', 'Arjun Kapoor', 'Divya Rao',
    'Rahul Bose', 'Nisha Kulkarni', 'Aditya Verma', 'Kavya Reddy', 'Suresh Pillai',
    'Meera Agarwal', 'Manish Gupta', 'Swati Bhatt', 'Deepak Jain', 'Ritika Mishra',
    'Siddharth Shah', 'Anjali Tripathi', 'Harish Nambiar', 'Sonali Patil', 'Akash Tiwari',
    'Preeti Chawla', 'Nikhil Pandey', 'Rukmini Das', 'Tarun Banerjee', 'Shweta Malhotra',
    'Gaurav Saxena', 'Lakshmi Venkatesh', 'Vishal Arora', 'Pallavi Dubey', 'Abhishek Rathi',
    'Geeta Krishnan', 'Kunal Chopra', 'Namrata Shetty', 'Omkar Salvi', 'Tanvi Ghosh',
    'Sachin Kulkarni', 'Isha Choudhary', 'Rohit Naik', 'Poonam Goswami', 'Jay Patel',
    'Ritu Menon', 'Varun Hegde', 'Shilpa Mukherjee', 'Yash Deshpande', 'Chandni Bhat',
    'Neeraj Wadhwa', 'Amrita Pillai', 'Devang Patel', 'Komal Sinha', 'Parth Shah',
    'Sarita Rana', 'Vivek Mahajan', 'Lata Subramaniam', 'Tushar Acharya', 'Mrunal Desai',
    'Chirag Thakkar', 'Sunita Pawar', 'Prashant Dixit', 'Bhavna Trivedi', 'Nilesh Rane',
    'Apoorva Kadam', 'Girish Nair', 'Shefali Rawat', 'Arun Srivastava', 'Nandini Pandey',
    'Hemant Biswas', 'Shraddha Gaikwad', 'Ranjeet Joshi', 'Disha Sharma', 'Milind Karpe',
    'Madhuri Patil', 'Sandeep Agrawal', 'Rashmi Sood', 'Yogesh Kaur', 'Supriya Wagh',
    'Ashok Tomar', 'Vandana Bajpai', 'Hardik Pandya', 'Kajal Rathod', 'Sumit Bhosale',
    'Tejal Mehta', 'Pranav Limaye', 'Amruta Shirke', 'Kishore Mane', 'Smita Londhe',
    'Shubham Khot', 'Vrushali Godse', 'Kapil Lokhande', 'Ujjwala Salunkhe', 'Santosh More',
    'Pratibha Bhosale', 'Mangesh Chavan', 'Radha Kale', 'Ramesh Jadhav', 'Sanjay Nalawade',
  ];

  static Future<int> _generateCustomers(
    CoozyDatabase db,
    Faker faker,
    Random random,
    String token,
    DateTime now,
    DateTime startDate,
  ) async {
    final list = <CustomersTableCompanion>[];
    final phonePrefixes = [
      '98', '99', '96', '97', '87', '88', '89', '90', '91', '70',
    ];
    for (int i = 0; i < 250; i++) {
      final custName = _customerNames[i % _customerNames.length];
      final prefix = phonePrefixes[random.nextInt(phonePrefixes.length)];
      final phone = '$prefix${10000000 + random.nextInt(89999999)}';
      final diffDays = now.difference(startDate).inDays;
      final randomDays = random.nextInt(diffDays > 0 ? diffDays : 1);
      final created = startDate.add(
        Duration(days: randomDays, minutes: random.nextInt(1440)),
      );
      list.add(
        CustomersTableCompanion.insert(
          hashId: Value(_seedId(token)),
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

  // Real employee names for a cafe setting
  static const List<String> _employeeNames = [
    'Rajesh Pawar', 'Sunita Kulkarni', 'Mahesh Shinde', 'Rekha Bhosale', 'Sunil Patil',
    'Geeta Jadhav', 'Prakash Salvi', 'Kavita Mane', 'Santosh Kadam', 'Priya Lokhande',
    'Nitin More', 'Pooja Shirke', 'Ramesh Nalawade', 'Sujata Londhe', 'Vijay Godse',
    'Aarti Khot', 'Dinesh Gaikwad', 'Rohini Limaye', 'Umesh Bhosale', 'Sunanda Wagh',
  ];

  static Future<int> _generateEmployees(
    CoozyDatabase db,
    Faker faker,
    Random random,
    String token,
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
      final empName = _employeeNames[i % _employeeNames.length];
      final prefix = '9${8 + random.nextInt(2)}';
      final phone = '$prefix${10000000 + random.nextInt(89999999)}';
      final pos = positions[i % positions.length];
      final diffDays = now.difference(startDate).inDays;
      final randomDays = random.nextInt(diffDays > 0 ? diffDays : 1);
      final joining = startDate.add(
        Duration(days: randomDays, minutes: random.nextInt(1440)),
      );
      final firstPart = empName.split(' ').first.toLowerCase();
      final email = '$firstPart.${i + 1}@coozycafe.in';
      final salary = 18000.0 + random.nextInt(40000);

      list.add(
        EmployeesTableCompanion.insert(
          hashId: Value(_seedId(token)),
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
          addressLine1: Value('${10 + i}, Cafe Lane'),
          addressLine2: const Value('Sector 12, Pune'),
          idProof: const Value('Aadhaar Card'),
          idProofNumber: Value('${200000000000 + i}'),
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
        await _getSeedToken(),
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
        await _getSeedToken(),
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

  // 20 real-world cafe table names matching Coozy The Cafe floor layout
  static const List<Map<String, Object>> _diningTables = [
    {'label': 'Window View - T1',   'no': 'T-01', 'chairs': 2, 'color': '4280391411'},
    {'label': 'Window View - T2',   'no': 'T-02', 'chairs': 2, 'color': '4280391411'},
    {'label': 'Cozy Corner - T3',   'no': 'T-03', 'chairs': 4, 'color': '4294198070'},
    {'label': 'Cozy Corner - T4',   'no': 'T-04', 'chairs': 4, 'color': '4294198070'},
    {'label': 'Garden View - T5',   'no': 'T-05', 'chairs': 2, 'color': '4282623326'},
    {'label': 'Garden View - T6',   'no': 'T-06', 'chairs': 2, 'color': '4282623326'},
    {'label': 'Main Hall - T7',     'no': 'T-07', 'chairs': 6, 'color': '4283215696'},
    {'label': 'Main Hall - T8',     'no': 'T-08', 'chairs': 6, 'color': '4283215696'},
    {'label': 'Patio - T9',         'no': 'T-09', 'chairs': 4, 'color': '4291559540'},
    {'label': 'Patio - T10',        'no': 'T-10', 'chairs': 4, 'color': '4291559540'},
    {'label': 'Family Booth - T11', 'no': 'T-11', 'chairs': 8, 'color': '4285952026'},
    {'label': 'Family Booth - T12', 'no': 'T-12', 'chairs': 8, 'color': '4285952026'},
    {'label': 'High Top - T13',     'no': 'T-13', 'chairs': 2, 'color': '4278217175'},
    {'label': 'High Top - T14',     'no': 'T-14', 'chairs': 2, 'color': '4278217175'},
    {'label': 'Lounge Area - T15',  'no': 'T-15', 'chairs': 4, 'color': '4294940672'},
    {'label': 'Lounge Area - T16',  'no': 'T-16', 'chairs': 4, 'color': '4294940672'},
    {'label': 'Terrace - T17',      'no': 'T-17', 'chairs': 6, 'color': '4278228616'},
    {'label': 'Terrace - T18',      'no': 'T-18', 'chairs': 6, 'color': '4278228616'},
    {'label': 'VIP Suite - T19',    'no': 'T-19', 'chairs': 10, 'color': '4292030255'},
    {'label': 'Outdoor - T20',      'no': 'T-20', 'chairs': 4, 'color': '4281728810'},
  ];

  static Future<int> _generateDiningTables(
    CoozyDatabase db,
    String token,
  ) async {
    int inserted = 0;
    for (int i = 0; i < _diningTables.length; i++) {
      final t = _diningTables[i];
      await db
          .into(db.tableInfoTable)
          .insert(
            TableInfoTableCompanion.insert(
              hashId: Value(_seedId(token)),
              tableLabel: Value(t['label'] as String),
              tableNo: Value(t['no'] as String),
              colorValue: Value(t['color'] as String),
              sortOrderIndex: Value(i + 1),
              nosOfChairs: Value(t['chairs'] as int),
              isActive: const Value(true),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  // Real Coozy The Cafe menu categories
  static const List<Map<String, Object>> _menuCategories = [
    {'name': 'Combos & Specials',      'pos': 1},
    {'name': 'Coffee',                 'pos': 2},
    {'name': 'Tea & Cold Beverages',   'pos': 3},
    {'name': 'Shakes & Hot Chocolate', 'pos': 4},
    {'name': 'Burgers & Sandwiches',   'pos': 5},
    {'name': 'Fries & Sides',          'pos': 6},
    {'name': 'Pizza & Pasta',          'pos': 7},
    {'name': 'Noodles & Maggi',        'pos': 8},
    {'name': 'Rice Bowls & Mains',     'pos': 9},
  ];

  static Future<int> _generateCategories(
    CoozyDatabase db,
    String token,
    DateTime startDate,
  ) async {
    int inserted = 0;
    for (final cat in _menuCategories) {
      await db
          .into(db.categoriesTable)
          .insert(
            CategoriesTableCompanion.insert(
              hashId: Value(_seedId(token)),
              name: Value(cat['name'] as String),
              isActive: const Value(true),
              position: Value(cat['pos'] as int),
              createdDate: Value(startDate.toIso8601String()),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  // Real Coozy subcategories mapped to parent category names
  static const Map<String, List<String>> _subcategoryMap = {
    'Combos & Specials': ['Value Combos', 'Signature Specials'],
    'Coffee': ['Hot Coffee', 'Cold Coffee & Frappes'],
    'Tea & Cold Beverages': ['Ice Teas', 'Canned & Bottled'],
    'Shakes & Hot Chocolate': ['Shakes', 'Hot Chocolate'],
    'Burgers & Sandwiches': ['Burgers', 'Sandwiches & Croissant'],
    'Fries & Sides': ['Fries', 'Nachos & Sides'],
    'Pizza & Pasta': ['Pizza', 'Pasta'],
    'Noodles & Maggi': ['Maggi', 'Ramen'],
    'Rice Bowls & Mains': ['Rice Bowls', 'Punjabi & Oats'],
  };

  static Future<int> _generateSubcategories(
    CoozyDatabase db,
    String token,
    DateTime startDate,
  ) async {
    var categories = await db.select(db.categoriesTable).get();
    if (categories.isEmpty) {
      await _generateCategories(db, token, startDate);
      categories = await db.select(db.categoriesTable).get();
    }

    int inserted = 0;
    for (final cat in categories) {
      final subs = _subcategoryMap[cat.name] ?? ['General'];
      for (int s = 0; s < subs.length; s++) {
        await db
            .into(db.subcategoriesTable)
            .insert(
              SubcategoriesTableCompanion.insert(
                hashId: Value(_seedId(token)),
                name: Value(subs[s]),
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

  // Real Coozy The Cafe menu items: {name, catName, subName, foodType, isSimple,
  // sellingPrice, costPrice, variations:[{name, selling, cost}], durationMins}
  static List<Map<String, dynamic>> get _menuItems => [
    // --- Combos & Specials ---
    {
      'cat': 'Combos & Specials', 'sub': 'Value Combos', 'type': 'Veg', 'simple': true,
      'name': 'Veg Burger + Salted Fries', 'sell': 99.0, 'cost': 52.0, 'dur': 15,
      'desc': 'Classic veg burger paired with crispy salted fries – our most loved value combo.',
    },
    {
      'cat': 'Combos & Specials', 'sub': 'Value Combos', 'type': 'Veg', 'simple': true,
      'name': '2 Veg Cheese Burger', 'sell': 120.0, 'cost': 63.0, 'dur': 15,
      'desc': 'Two cheesy veg burgers – perfect for sharing or a hearty snack.',
    },
    {
      'cat': 'Combos & Specials', 'sub': 'Value Combos', 'type': 'Veg', 'simple': true,
      'name': 'Any Wrap + Any Burger', 'sell': 150.0, 'cost': 78.0, 'dur': 15,
      'desc': 'Mix & match your favourite wrap with any burger from our menu.',
    },
    {
      'cat': 'Combos & Specials', 'sub': 'Signature Specials', 'type': 'Veg', 'simple': true,
      'name': 'Rice Bowl (Dal Makhani + Steam Rice)', 'sell': 200.0, 'cost': 105.0, 'dur': 20,
      'desc': 'Creamy Dal Makhani served alongside fluffy steamed rice.',
    },
    {
      'cat': 'Combos & Specials', 'sub': 'Signature Specials', 'type': 'Veg', 'simple': true,
      'name': 'Burnt Garlic Rice + Aloo Tikki Wrap', 'sell': 250.0, 'cost': 130.0, 'dur': 20,
      'desc': 'Aromatic burnt garlic rice bundled with a spiced aloo tikki wrap.',
    },
    {
      'cat': 'Combos & Specials', 'sub': 'Signature Specials', 'type': 'Veg', 'simple': true,
      'name': 'Margherita Pizza + Strawberry Shake + Tandoori Paneer Wrap', 'sell': 250.0, 'cost': 130.0, 'dur': 25,
      'desc': 'A crowd-pleasing trio: classic pizza, fruity shake and a grilled paneer wrap.',
    },
    {
      'cat': 'Combos & Specials', 'sub': 'Signature Specials', 'type': 'Veg', 'simple': true,
      'name': 'Schezwan Fry Rice + Tandoori Paneer Pizza', 'sell': 300.0, 'cost': 156.0, 'dur': 25,
      'desc': 'Indo-Chinese schezwan rice paired with our signature tandoori paneer pizza.',
    },
    {
      'cat': 'Combos & Specials', 'sub': 'Signature Specials', 'type': 'Veg', 'simple': true,
      'name': 'Italian Rice + Farmhouse Pizza', 'sell': 300.0, 'cost': 156.0, 'dur': 25,
      'desc': 'Herb-infused Italian rice served alongside a loaded farmhouse pizza.',
    },

    // --- Coffee ---
    {
      'cat': 'Coffee', 'sub': 'Hot Coffee', 'type': 'Veg', 'simple': true,
      'name': 'Espresso', 'sell': 70.0, 'cost': 30.0, 'dur': 5,
      'desc': 'A bold single-shot espresso brewed to perfection.',
    },
    {
      'cat': 'Coffee', 'sub': 'Hot Coffee', 'type': 'Veg', 'simple': true,
      'name': 'Americano', 'sell': 80.0, 'cost': 34.0, 'dur': 5,
      'desc': 'Espresso diluted with hot water for a smooth, robust cup.',
    },
    {
      'cat': 'Coffee', 'sub': 'Hot Coffee', 'type': 'Veg', 'simple': true,
      'name': 'Flat White', 'sell': 130.0, 'cost': 56.0, 'dur': 7,
      'desc': 'Velvety microfoam milk poured over a double ristretto.',
    },
    {
      'cat': 'Coffee', 'sub': 'Hot Coffee', 'type': 'Veg', 'simple': true,
      'name': 'Latte', 'sell': 130.0, 'cost': 56.0, 'dur': 7,
      'desc': 'Smooth espresso blended with steamed milk and a light foam.',
    },
    {
      'cat': 'Coffee', 'sub': 'Hot Coffee', 'type': 'Veg', 'simple': true,
      'name': 'Cappuccino', 'sell': 150.0, 'cost': 65.0, 'dur': 7,
      'desc': 'Equal parts espresso, steamed milk, and thick milk foam.',
    },
    {
      'cat': 'Coffee', 'sub': 'Hot Coffee', 'type': 'Veg', 'simple': true,
      'name': 'Caramel Coffee', 'sell': 150.0, 'cost': 65.0, 'dur': 8,
      'desc': 'Rich espresso topped with steamed milk and caramel drizzle.',
    },
    {
      'cat': 'Coffee', 'sub': 'Hot Coffee', 'type': 'Veg', 'simple': true,
      'name': 'Vietnamese Coffee', 'sell': 150.0, 'cost': 65.0, 'dur': 10,
      'desc': 'Drip-brewed dark roast over sweetened condensed milk.',
    },
    {
      'cat': 'Coffee', 'sub': 'Cold Coffee & Frappes', 'type': 'Veg', 'simple': true,
      'name': 'Cold Coffee', 'sell': 100.0, 'cost': 43.0, 'dur': 7,
      'desc': 'Blended chilled coffee with milk served over ice.',
    },
    {
      'cat': 'Coffee', 'sub': 'Cold Coffee & Frappes', 'type': 'Veg', 'simple': true,
      'name': 'Caramel Biscoff Frappe', 'sell': 170.0, 'cost': 74.0, 'dur': 8,
      'desc': 'Blended iced coffee with caramel syrup and biscoff cookie crumble.',
    },
    {
      'cat': 'Coffee', 'sub': 'Cold Coffee & Frappes', 'type': 'Veg', 'simple': true,
      'name': 'Redbull Espresso', 'sell': 220.0, 'cost': 95.0, 'dur': 5,
      'desc': 'Double espresso poured over a chilled can of Redbull – the ultimate energy boost.',
    },

    // --- Tea & Cold Beverages ---
    {
      'cat': 'Tea & Cold Beverages', 'sub': 'Ice Teas', 'type': 'Veg', 'simple': true,
      'name': 'Lemon Ice Tea', 'sell': 100.0, 'cost': 42.0, 'dur': 5,
      'desc': 'Refreshing chilled tea with a zesty lemon twist.',
    },
    {
      'cat': 'Tea & Cold Beverages', 'sub': 'Ice Teas', 'type': 'Veg', 'simple': true,
      'name': 'Peach Ice Tea', 'sell': 120.0, 'cost': 52.0, 'dur': 5,
      'desc': 'Sweet iced tea infused with real peach flavour.',
    },
    {
      'cat': 'Tea & Cold Beverages', 'sub': 'Ice Teas', 'type': 'Veg', 'simple': true,
      'name': 'Watermelon Ice Tea', 'sell': 120.0, 'cost': 52.0, 'dur': 5,
      'desc': 'Summer-special iced tea blended with fresh watermelon.',
    },
    {
      'cat': 'Tea & Cold Beverages', 'sub': 'Ice Teas', 'type': 'Veg', 'simple': true,
      'name': 'Fresh Tea', 'sell': 30.0, 'cost': 10.0, 'dur': 5,
      'desc': 'Freshly brewed hot tea made with quality tea leaves.',
    },
    {
      'cat': 'Tea & Cold Beverages', 'sub': 'Canned & Bottled', 'type': 'Veg', 'simple': false,
      'name': 'Cold Drink', 'sell': 50.0, 'cost': 30.0, 'dur': 2,
      'desc': 'Chilled carbonated soft drink.',
      'variations': [
        {'name': 'Pepsi',   'sell': 50.0, 'cost': 30.0},
        {'name': 'Coke',    'sell': 50.0, 'cost': 30.0},
        {'name': 'Sprite',  'sell': 50.0, 'cost': 30.0},
      ],
    },
    {
      'cat': 'Tea & Cold Beverages', 'sub': 'Canned & Bottled', 'type': 'Veg', 'simple': true,
      'name': 'Redbull', 'sell': 135.0, 'cost': 90.0, 'dur': 2,
      'desc': 'Original Redbull energy drink.',
    },
    {
      'cat': 'Tea & Cold Beverages', 'sub': 'Canned & Bottled', 'type': 'Veg', 'simple': true,
      'name': 'Tonic Water', 'sell': 70.0, 'cost': 45.0, 'dur': 2,
      'desc': 'Sparkling tonic water – a café favourite.',
    },
    {
      'cat': 'Tea & Cold Beverages', 'sub': 'Canned & Bottled', 'type': 'Veg', 'simple': true,
      'name': 'Bottled Water', 'sell': 20.0, 'cost': 10.0, 'dur': 1,
      'desc': 'Chilled packaged drinking water.',
    },

    // --- Shakes & Hot Chocolate ---
    {
      'cat': 'Shakes & Hot Chocolate', 'sub': 'Shakes', 'type': 'Veg', 'simple': true,
      'name': 'Chocolate Shake', 'sell': 100.0, 'cost': 43.0, 'dur': 7,
      'desc': 'Thick and creamy chocolate milkshake.',
    },
    {
      'cat': 'Shakes & Hot Chocolate', 'sub': 'Shakes', 'type': 'Veg', 'simple': false,
      'name': 'Special Shake', 'sell': 120.0, 'cost': 52.0, 'dur': 7,
      'desc': 'Pick your favourite: Kitkat, Oreo or Caramel shake.',
      'variations': [
        {'name': 'Kitkat',   'sell': 120.0, 'cost': 52.0},
        {'name': 'Oreo',     'sell': 120.0, 'cost': 52.0},
        {'name': 'Caramel',  'sell': 120.0, 'cost': 52.0},
      ],
    },
    {
      'cat': 'Shakes & Hot Chocolate', 'sub': 'Shakes', 'type': 'Veg', 'simple': true,
      'name': 'Nutella Brownie Shake', 'sell': 200.0, 'cost': 87.0, 'dur': 10,
      'desc': 'Indulgent shake blended with Nutella and chunks of fudgy brownie.',
    },
    {
      'cat': 'Shakes & Hot Chocolate', 'sub': 'Shakes', 'type': 'Veg', 'simple': true,
      'name': 'Biscoff Shake', 'sell': 200.0, 'cost': 87.0, 'dur': 10,
      'desc': 'Smooth shake made with creamy Biscoff spread and milk.',
    },
    {
      'cat': 'Shakes & Hot Chocolate', 'sub': 'Hot Chocolate', 'type': 'Veg', 'simple': false,
      'name': 'Hot Chocolate', 'sell': 80.0, 'cost': 35.0, 'dur': 8,
      'desc': 'Comforting rich hot chocolate made with premium cocoa.',
      'variations': [
        {'name': '150 ml', 'sell': 60.0,  'cost': 26.0},
        {'name': '300 ml', 'sell': 100.0, 'cost': 43.0},
      ],
    },
    {
      'cat': 'Shakes & Hot Chocolate', 'sub': 'Hot Chocolate', 'type': 'Veg', 'simple': true,
      'name': 'Belgian Dark Chocolate', 'sell': 120.0, 'cost': 52.0, 'dur': 8,
      'desc': 'Intense dark hot chocolate made with authentic Belgian cacao.',
    },
    {
      'cat': 'Shakes & Hot Chocolate', 'sub': 'Hot Chocolate', 'type': 'Veg', 'simple': true,
      'name': 'Chunky Biscoff Hot Chocolate', 'sell': 120.0, 'cost': 52.0, 'dur': 8,
      'desc': 'Hot chocolate swirled with Biscoff spread and crunchy cookie pieces.',
    },

    // --- Burgers & Sandwiches ---
    {
      'cat': 'Burgers & Sandwiches', 'sub': 'Burgers', 'type': 'Veg', 'simple': false,
      'name': 'Veg Burger', 'sell': 70.0, 'cost': 30.0, 'dur': 12,
      'desc': 'Classic veg patty burger available plain or with extra cheese.',
      'variations': [
        {'name': 'Regular',     'sell': 60.0, 'cost': 26.0},
        {'name': 'With Cheese', 'sell': 80.0, 'cost': 35.0},
      ],
    },
    {
      'cat': 'Burgers & Sandwiches', 'sub': 'Burgers', 'type': 'Veg', 'simple': false,
      'name': 'Chili Garlic Burger', 'sell': 80.0, 'cost': 35.0, 'dur': 12,
      'desc': 'Spiced burger with chili garlic sauce – a fiery favourite.',
      'variations': [
        {'name': 'Regular',     'sell': 70.0, 'cost': 30.0},
        {'name': 'With Cheese', 'sell': 90.0, 'cost': 39.0},
      ],
    },
    {
      'cat': 'Burgers & Sandwiches', 'sub': 'Burgers', 'type': 'Veg', 'simple': false,
      'name': 'Double Patty Burger', 'sell': 100.0, 'cost': 43.0, 'dur': 15,
      'desc': 'Double the patty, double the joy – our heartiest burger.',
      'variations': [
        {'name': 'Regular',     'sell': 90.0,  'cost': 39.0},
        {'name': 'With Cheese', 'sell': 110.0, 'cost': 48.0},
      ],
    },
    {
      'cat': 'Burgers & Sandwiches', 'sub': 'Sandwiches & Croissant', 'type': 'Veg', 'simple': true,
      'name': 'Bread Butter Chutney', 'sell': 40.0, 'cost': 15.0, 'dur': 5,
      'desc': 'Simple toasted bread served with butter and chutney.',
    },
    {
      'cat': 'Burgers & Sandwiches', 'sub': 'Sandwiches & Croissant', 'type': 'Veg', 'simple': true,
      'name': 'Coozy Veg Sandwich', 'sell': 50.0, 'cost': 22.0, 'dur': 8,
      'desc': 'Fresh garden veggie sandwich toasted to golden perfection.',
    },
    {
      'cat': 'Burgers & Sandwiches', 'sub': 'Sandwiches & Croissant', 'type': 'Veg', 'simple': true,
      'name': 'Cozy 4 Cheese Grill', 'sell': 120.0, 'cost': 52.0, 'dur': 10,
      'desc': 'Four-cheese grilled sandwich – oozy and irresistible.',
    },
    {
      'cat': 'Burgers & Sandwiches', 'sub': 'Sandwiches & Croissant', 'type': 'Veg', 'simple': true,
      'name': 'Tandoori Paneer Sandwich', 'sell': 150.0, 'cost': 65.0, 'dur': 12,
      'desc': 'Marinated paneer with tandoori spices, grilled in a sandwich.',
    },
    {
      'cat': 'Burgers & Sandwiches', 'sub': 'Sandwiches & Croissant', 'type': 'Veg', 'simple': true,
      'name': 'Croissant Sandwich', 'sell': 200.0, 'cost': 87.0, 'dur': 10,
      'desc': 'Buttery, flaky croissant stuffed with creamy veggie filling.',
    },

    // --- Fries & Sides ---
    {
      'cat': 'Fries & Sides', 'sub': 'Fries', 'type': 'Veg', 'simple': false,
      'name': 'Simply Salted Fries', 'sell': 110.0, 'cost': 47.0, 'dur': 10,
      'desc': 'Golden crispy fries seasoned with sea salt.',
      'variations': [
        {'name': 'Regular', 'sell': 80.0,  'cost': 34.0},
        {'name': 'Large',   'sell': 140.0, 'cost': 60.0},
      ],
    },
    {
      'cat': 'Fries & Sides', 'sub': 'Fries', 'type': 'Veg', 'simple': false,
      'name': 'Peri-Peri Fries', 'sell': 135.0, 'cost': 58.0, 'dur': 10,
      'desc': 'Hot and spicy peri-peri seasoned fries.',
      'variations': [
        {'name': 'Regular', 'sell': 100.0, 'cost': 43.0},
        {'name': 'Large',   'sell': 170.0, 'cost': 73.0},
      ],
    },
    {
      'cat': 'Fries & Sides', 'sub': 'Fries', 'type': 'Veg', 'simple': true,
      'name': 'Cheese Overload Loaded Fries', 'sell': 170.0, 'cost': 73.0, 'dur': 12,
      'desc': 'Fries smothered in a rich cheese sauce with jalapeno.',
    },
    {
      'cat': 'Fries & Sides', 'sub': 'Fries', 'type': 'Veg', 'simple': true,
      'name': 'Mexican Mess Fries', 'sell': 170.0, 'cost': 73.0, 'dur': 12,
      'desc': 'Loaded fries with salsa, sour cream and Mexican spices.',
    },
    {
      'cat': 'Fries & Sides', 'sub': 'Nachos & Sides', 'type': 'Veg', 'simple': false,
      'name': 'Nachos', 'sell': 130.0, 'cost': 56.0, 'dur': 10,
      'desc': 'Crispy nachos served with dips.',
      'variations': [
        {'name': 'Mexican Nachos', 'sell': 130.0, 'cost': 56.0},
        {'name': 'Cheese Nachos',  'sell': 130.0, 'cost': 56.0},
      ],
    },
    {
      'cat': 'Fries & Sides', 'sub': 'Nachos & Sides', 'type': 'Veg', 'simple': true,
      'name': 'Sabudana Vada', 'sell': 80.0, 'cost': 34.0, 'dur': 12,
      'desc': 'Crispy sago fritters served with green chutney.',
    },

    // --- Pizza & Pasta ---
    {
      'cat': 'Pizza & Pasta', 'sub': 'Pizza', 'type': 'Veg', 'simple': true,
      'name': 'Margherita Pizza', 'sell': 150.0, 'cost': 65.0, 'dur': 20,
      'desc': 'Classic Margherita with tomato base, mozzarella and fresh basil.',
    },
    {
      'cat': 'Pizza & Pasta', 'sub': 'Pizza', 'type': 'Veg', 'simple': true,
      'name': 'Sweet Corn Pizza', 'sell': 160.0, 'cost': 70.0, 'dur': 20,
      'desc': 'Crispy pizza loaded with sweet corn and gooey cheese.',
    },
    {
      'cat': 'Pizza & Pasta', 'sub': 'Pizza', 'type': 'Veg', 'simple': true,
      'name': 'Farmhouse Pizza', 'sell': 180.0, 'cost': 78.0, 'dur': 20,
      'desc': 'Veggie-loaded pizza with capsicum, onion, tomato and olives.',
    },
    {
      'cat': 'Pizza & Pasta', 'sub': 'Pizza', 'type': 'Veg', 'simple': true,
      'name': 'Tandoori Paneer Pizza', 'sell': 200.0, 'cost': 87.0, 'dur': 22,
      'desc': 'Pizza topped with tandoori spiced paneer tikka and mint chutney drizzle.',
    },
    {
      'cat': 'Pizza & Pasta', 'sub': 'Pasta', 'type': 'Veg', 'simple': false,
      'name': 'Alfredo White Sauce Pasta', 'sell': 180.0, 'cost': 78.0, 'dur': 18,
      'desc': 'Creamy white sauce pasta with herbs and parmesan.',
      'variations': [
        {'name': 'Regular',     'sell': 170.0, 'cost': 73.0},
        {'name': 'With Cheese', 'sell': 190.0, 'cost': 82.0},
      ],
    },
    {
      'cat': 'Pizza & Pasta', 'sub': 'Pasta', 'type': 'Veg', 'simple': false,
      'name': 'Arrabbiata Red Sauce Pasta', 'sell': 180.0, 'cost': 78.0, 'dur': 18,
      'desc': 'Spicy tomato arrabbiata pasta with fresh herbs.',
      'variations': [
        {'name': 'Regular',     'sell': 170.0, 'cost': 73.0},
        {'name': 'With Cheese', 'sell': 190.0, 'cost': 82.0},
      ],
    },
    {
      'cat': 'Pizza & Pasta', 'sub': 'Pasta', 'type': 'Veg', 'simple': true,
      'name': '4 Cheese Pasta', 'sell': 200.0, 'cost': 87.0, 'dur': 20,
      'desc': 'Indulgent four-cheese pasta sauce on al dente penne.',
    },

    // --- Noodles & Maggi ---
    {
      'cat': 'Noodles & Maggi', 'sub': 'Maggi', 'type': 'Veg', 'simple': true,
      'name': 'Maggi Original', 'sell': 40.0, 'cost': 15.0, 'dur': 8,
      'desc': 'Nostalgic original Maggi noodles cooked with our secret masala.',
    },
    {
      'cat': 'Noodles & Maggi', 'sub': 'Maggi', 'type': 'Veg', 'simple': true,
      'name': 'Double Masala Maggi', 'sell': 50.0, 'cost': 20.0, 'dur': 8,
      'desc': 'Double the masala goodness in your Maggi.',
    },
    {
      'cat': 'Noodles & Maggi', 'sub': 'Maggi', 'type': 'Veg', 'simple': true,
      'name': 'Vegie Cheese Maggi', 'sell': 90.0, 'cost': 38.0, 'dur': 10,
      'desc': 'Veggie-loaded Maggi topped with melted cheese.',
    },
    {
      'cat': 'Noodles & Maggi', 'sub': 'Ramen', 'type': 'Veg', 'simple': true,
      'name': 'Spicy Ramen with Cheese', 'sell': 170.0, 'cost': 73.0, 'dur': 15,
      'desc': 'Korean-style spicy ramen broth topped with a cheesy cloud.',
    },
    {
      'cat': 'Noodles & Maggi', 'sub': 'Ramen', 'type': 'Veg', 'simple': true,
      'name': 'Veg Kimchi Ramen', 'sell': 170.0, 'cost': 73.0, 'dur': 15,
      'desc': 'Tangy kimchi-infused ramen with tofu and spring onions.',
    },

    // --- Rice Bowls & Mains ---
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Rice Bowls', 'type': 'Veg', 'simple': true,
      'name': 'Steam Rice', 'sell': 120.0, 'cost': 52.0, 'dur': 15,
      'desc': 'Perfectly cooked long-grain basmati steamed rice.',
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Rice Bowls', 'type': 'Veg', 'simple': true,
      'name': 'American Corn Fry Rice', 'sell': 150.0, 'cost': 65.0, 'dur': 18,
      'desc': 'Stir-fried rice tossed with sweet corn, peppers and soy sauce.',
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Rice Bowls', 'type': 'Veg', 'simple': true,
      'name': 'Burnt Garlic Rice', 'sell': 200.0, 'cost': 87.0, 'dur': 18,
      'desc': 'Fragrant rice wok-tossed with crispy burnt garlic and veggies.',
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Rice Bowls', 'type': 'Veg', 'simple': true,
      'name': 'Schezwan Rice', 'sell': 200.0, 'cost': 87.0, 'dur': 18,
      'desc': 'Spicy Indo-Chinese fried rice with schezwan sauce.',
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Rice Bowls', 'type': 'Veg', 'simple': true,
      'name': 'Tawa Biryani', 'sell': 200.0, 'cost': 87.0, 'dur': 20,
      'desc': 'Aromatic spiced rice layered with vegetables, cooked on a tawa.',
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Punjabi & Oats', 'type': 'Veg', 'simple': true,
      'name': 'Dal Makhani', 'sell': 200.0, 'cost': 87.0, 'dur': 20,
      'desc': 'Slow-cooked black lentils in a rich tomato-butter gravy.',
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Punjabi & Oats', 'type': 'Veg', 'simple': false,
      'name': 'Aloo Paratha', 'sell': 90.0, 'cost': 38.0, 'dur': 15,
      'desc': 'Stuffed spiced potato flatbread served with pickle and yogurt.',
      'variations': [
        {'name': 'With Oil',    'sell': 80.0,  'cost': 34.0},
        {'name': 'With Butter', 'sell': 100.0, 'cost': 43.0},
      ],
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Punjabi & Oats', 'type': 'Veg', 'simple': false,
      'name': 'Paneer Paratha', 'sell': 110.0, 'cost': 47.0, 'dur': 15,
      'desc': 'Paneer-stuffed flatbread cooked on tawa, served with chutney.',
      'variations': [
        {'name': 'With Oil',    'sell': 100.0, 'cost': 43.0},
        {'name': 'With Butter', 'sell': 120.0, 'cost': 52.0},
      ],
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Punjabi & Oats', 'type': 'Veg', 'simple': true,
      'name': 'Exotic Veggie Bowl', 'sell': 180.0, 'cost': 78.0, 'dur': 20,
      'desc': 'A nutritious bowl of seasonal vegetables, grains and dressings.',
    },
    {
      'cat': 'Rice Bowls & Mains', 'sub': 'Punjabi & Oats', 'type': 'Veg', 'simple': true,
      'name': 'Coozy Special Cheese Masala Oats', 'sell': 100.0, 'cost': 43.0, 'dur': 12,
      'desc': 'Savoury oats cooked with masala spices and topped with melted cheese.',
    },
  ];

  static Future<int> _generateMenuItems(
    CoozyDatabase db,
    Random random,
    String token,
    DateTime startDate,
    DateTime Function() getRandomDate,
  ) async {
    var categories = await db.select(db.categoriesTable).get();
    if (categories.isEmpty) {
      await _generateCategories(db, token, startDate);
      categories = await db.select(db.categoriesTable).get();
    }

    var subcategories = await db.select(db.subcategoriesTable).get();
    if (subcategories.isEmpty) {
      await _generateSubcategories(db, token, startDate);
      subcategories = await db.select(db.subcategoriesTable).get();
    }

    final catMap = {for (final c in categories) c.name: c.id};
    final subMap = {for (final s in subcategories) '${s.categoryId}__${s.name}': s.id};

    int inserted = 0;
    int sortIdx = 0;

    for (final item in _menuItems) {
      final catName = item['cat'] as String;
      final subName = item['sub'] as String;
      final catId = catMap[catName];
      final subId = subMap['${catId}__$subName'];

      final isSimple = item['simple'] as bool;
      final sell = (item['sell'] as double);
      final cost = (item['cost'] as double);
      sortIdx++;

      final itemId = await db
          .into(db.menuItemsTable)
          .insert(
            MenuItemsTableCompanion.insert(
              hashId: Value(_seedId(token)),
              name: item['name'] as String,
              description: item['desc'] as String,
              foodType: Value(item['type'] as String),
              creationDate: Value(startDate.toIso8601String()),
              duration: Value(item['dur'] as int),
              categoryId: Value(catId),
              subcategoryId: Value(subId),
              isTodayAvailable: const Value(true),
              isSimpleVariation: Value(isSimple),
              costPrice: Value(cost),
              sellingPrice: Value(sell),
              stockQuantity: const Value(150),
              quantity: const Value('1'),
              purchaseUnit: const Value('portion'),
              sortOrderIndex: Value(sortIdx),
            ),
          );
      inserted++;

      if (isSimple) {
        await db
            .into(db.menuItemVariationsTable)
            .insert(
              MenuItemVariationsTableCompanion.insert(
                hashId: Value(_seedId(token)),
                name: const Value(null),
                menuItemId: Value(itemId),
                quantity: const Value(1),
                purchaseUnit: const Value('portion'),
                isTodayAvailable: const Value(true),
                costPrice: Value(cost),
                sellingPrice: Value(sell),
                stockQuantity: const Value(150),
                sortOrderIndex: const Value(1),
                creationDate: Value(startDate.toIso8601String()),
              ),
            );
        inserted++;
      } else {
        final rawVariations = item['variations'] as List<Map<String, dynamic>>?;
        final variations = rawVariations ?? [];
        for (int v = 0; v < variations.length; v++) {
          final vari = variations[v];
          await db
              .into(db.menuItemVariationsTable)
              .insert(
                MenuItemVariationsTableCompanion.insert(
                  hashId: Value(_seedId(token)),
                  name: Value(vari['name'] as String),
                  menuItemId: Value(itemId),
                  quantity: const Value(1),
                  purchaseUnit: const Value('portion'),
                  isTodayAvailable: const Value(true),
                  costPrice: Value((vari['cost'] as num).toDouble()),
                  sellingPrice: Value((vari['sell'] as num).toDouble()),
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
    // Real Coozy The Cafe recipes – no prefix in the name
    final recipes = [
      {
        'original': 'Espresso Cappuccino Blend',
        'translated': 'Espresso Cappuccino Blend',
        'ingredients': 'Espresso beans, whole milk, sugar',
        'translated_ingredients': 'Espresso, Steamed Milk, Sugar',
        'cuisine': 'Italian',
        'diet': 'Vegetarian',
        'course': 'Beverage',
        'prepMins': 2,
        'cookMins': 5,
        'servings': 1,
      },
      {
        'original': 'Caramel Biscoff Frappe',
        'translated': 'Caramel Biscoff Frappe',
        'ingredients': 'Espresso, milk, ice, caramel syrup, Biscoff cookies',
        'translated_ingredients': 'Espresso, Milk, Ice, Caramel Syrup, Biscoff',
        'cuisine': 'Continental',
        'diet': 'Vegetarian',
        'course': 'Beverage',
        'prepMins': 5,
        'cookMins': 3,
        'servings': 1,
      },
      {
        'original': 'Tandoori Paneer Pizza',
        'translated': 'Tandoori Paneer Pizza',
        'ingredients': 'Pizza dough, paneer, tandoori marinade, mozzarella, capsicum, onion',
        'translated_ingredients': 'Pizza Dough, Paneer, Tandoori Spices, Mozzarella',
        'cuisine': 'Fusion',
        'diet': 'Vegetarian',
        'course': 'Main Course',
        'prepMins': 15,
        'cookMins': 12,
        'servings': 2,
      },
      {
        'original': 'Nutella Brownie Shake',
        'translated': 'Nutella Brownie Shake',
        'ingredients': 'Milk, Nutella, brownie pieces, vanilla ice cream',
        'translated_ingredients': 'Milk, Nutella, Brownie, Ice Cream',
        'cuisine': 'Continental',
        'diet': 'Vegetarian',
        'course': 'Dessert',
        'prepMins': 5,
        'cookMins': 2,
        'servings': 1,
      },
      {
        'original': 'Spicy Ramen with Cheese',
        'translated': 'Spicy Ramen with Cheese',
        'ingredients': 'Ramen noodles, gochujang paste, vegetable broth, cheese, spring onion',
        'translated_ingredients': 'Ramen, Gochujang, Vegetable Broth, Cheese',
        'cuisine': 'Korean-Fusion',
        'diet': 'Vegetarian',
        'course': 'Main Course',
        'prepMins': 10,
        'cookMins': 15,
        'servings': 1,
      },
      {
        'original': 'Cheese Overload Loaded Fries',
        'translated': 'Cheese Overload Loaded Fries',
        'ingredients': 'Potato fries, cheddar sauce, jalapenos, herbs',
        'translated_ingredients': 'Fries, Cheddar Sauce, Jalapenos, Herbs',
        'cuisine': 'American',
        'diet': 'Vegetarian',
        'course': 'Starter',
        'prepMins': 5,
        'cookMins': 10,
        'servings': 1,
      },
      {
        'original': 'Dal Makhani',
        'translated': 'Dal Makhani',
        'ingredients': 'Black lentils, rajma, butter, cream, tomato, spices',
        'translated_ingredients': 'Black Lentils, Rajma, Butter, Cream, Tomatoes',
        'cuisine': 'Punjabi',
        'diet': 'Vegetarian',
        'course': 'Main Course',
        'prepMins': 15,
        'cookMins': 45,
        'servings': 2,
      },
      {
        'original': 'Coozy 4 Cheese Grill Sandwich',
        'translated': 'Coozy 4 Cheese Grill Sandwich',
        'ingredients': 'Bread, cheddar, mozzarella, gouda, cream cheese, butter',
        'translated_ingredients': 'Bread, Cheddar, Mozzarella, Gouda, Cream Cheese',
        'cuisine': 'Continental',
        'diet': 'Vegetarian',
        'course': 'Snack',
        'prepMins': 5,
        'cookMins': 8,
        'servings': 1,
      },
    ];

    int inserted = 0;
    for (final r in recipes) {
      final prepMins = r['prepMins'] as int;
      final cookMins = r['cookMins'] as int;
      await db
          .into(db.recipesTable)
          .insert(
            RecipesTableCompanion.insert(
              recipeOriginalName: Value(r['original'] as String),
              translatedRecipeName: Value(r['translated'] as String),
              recipeOriginalIngredients: Value(r['ingredients'] as String),
              recipeTranslatedIngredientList: Value(r['translated_ingredients'] as String),
              recipePreparationTimeInMins: Value(prepMins),
              recipeCookingTimeInMins: Value(cookMins),
              recipeTotalTimeInMins: Value(prepMins + cookMins),
              recipeServings: Value(r['servings'] as int),
              recipeCuisine: Value(r['cuisine'] as String),
              recipeCourse: Value(r['course'] as String),
              recipeDiet: Value(r['diet'] as String),
              isBookmark: const Value(false),
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
    String token,
    DateTime startDate,
  ) async {
    final inventoryItems = [
      {'name': 'Espresso Beans',       'unit': 'kg',  'stock': 20.0},
      {'name': 'Whole Milk',           'unit': 'ltr', 'stock': 50.0},
      {'name': 'Refined Flour (Maida)','unit': 'kg',  'stock': 30.0},
      {'name': 'White Sugar',          'unit': 'kg',  'stock': 25.0},
      {'name': 'Cheddar Cheese',       'unit': 'kg',  'stock': 10.0},
      {'name': 'Mozzarella Cheese',    'unit': 'kg',  'stock': 8.0},
      {'name': 'Fresh Tomatoes',       'unit': 'kg',  'stock': 15.0},
      {'name': 'Refined Cooking Oil',  'unit': 'ltr', 'stock': 20.0},
      {'name': 'Butter (Amul)',        'unit': 'kg',  'stock': 5.0},
      {'name': 'Mixed Spice Blend',    'unit': 'kg',  'stock': 3.0},
      {'name': 'Pizza Base',           'unit': 'pcs', 'stock': 60.0},
      {'name': 'Biscoff Spread',       'unit': 'kg',  'stock': 4.0},
      {'name': 'Nutella',              'unit': 'kg',  'stock': 3.0},
      {'name': 'Potato (Fresh)',       'unit': 'kg',  'stock': 40.0},
      {'name': 'Paneer',               'unit': 'kg',  'stock': 12.0},
      {'name': 'Caramel Syrup',        'unit': 'ltr', 'stock': 5.0},
      {'name': 'Ramen Noodles',        'unit': 'pcs', 'stock': 80.0},
      {'name': 'Maggi Noodles',        'unit': 'pcs', 'stock': 150.0},
      {'name': 'Vanilla Ice Cream',    'unit': 'ltr', 'stock': 10.0},
      {'name': 'Black Lentils (Urad)', 'unit': 'kg',  'stock': 20.0},
    ];

    int inserted = 0;
    for (final inv in inventoryItems) {
      await db
          .into(db.inventoryTable)
          .insert(
            InventoryTableCompanion.insert(
              hashId: Value(_seedId(token)),
              name: Value(inv['name'] as String),
              shortDescription: Value('${inv['name']} – standard café stock item.'),
              purchaseUnit: Value(inv['unit'] as String),
              currentStock: Value(inv['stock'] as double),
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
    String token,
    DateTime now,
    DateTime startDate,
    DateTime Function() getRandomDate,
  ) async {
    var inventory = await db.select(db.inventoryTable).get();
    if (inventory.isEmpty) {
      await _generateInventory(db, Faker(), random, token, startDate);
      inventory = await db.select(db.inventoryTable).get();
    }

    // Realistic price ranges per unit for each inventory item
    final unitPrices = <String, double>{
      'kg': 80.0,
      'ltr': 60.0,
      'pcs': 12.0,
    };

    int inserted = 0;
    for (int p = 0; p < 100; p++) {
      final inv = inventory[random.nextInt(inventory.length)];
      final pDate = getRandomDate();
      final qty = 10.0 + random.nextInt(40);
      final basePrice = unitPrices[inv.purchaseUnit] ?? 50.0;
      final unitPrice = basePrice + random.nextInt(50);

      await db
          .into(db.purchaseTable)
          .insert(
            PurchaseTableCompanion.insert(
              hashId: Value(_seedId(token)),
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
    String token,
    DateTime now,
  ) async {
    var customers = await db.select(db.customersTable).get();
    if (customers.isEmpty) {
      await _generateCustomers(
        db,
        faker,
        random,
        token,
        now,
        now.subtract(const Duration(days: 100)),
      );
      customers = await db.select(db.customersTable).get();
    }

    var tables = await db.select(db.tableInfoTable).get();
    if (tables.isEmpty) {
      await _generateDiningTables(db, token);
      tables = await db.select(db.tableInfoTable).get();
    }

    var menuItems = await db.select(db.menuItemsTable).get();
    if (menuItems.isEmpty) {
      await _generateMenuItems(
        db,
        random,
        token,
        now.subtract(const Duration(days: 100)),
        () => now,
      );
      menuItems = await db.select(db.menuItemsTable).get();
    }

    int inserted = 0;
    final todayStart = DateTime(now.year, now.month, now.day);

    String generateRandomPreOrders(Random random, List<dynamic> items) {
      if (items.isEmpty || random.nextDouble() > 0.6) return '';
      final count = 1 + random.nextInt(3);
      final List<Map<String, dynamic>> selected = [];
      for (int i = 0; i < count; i++) {
        final item = items[random.nextInt(items.length)];
        selected.add({
          'id': item.id,
          'item_name': item.name ?? 'Cafe Item',
          'quantity': 1 + random.nextInt(3),
          'price': item.sellingPrice ?? 5.0,
        });
      }
      return 'PRE_ORDERED_ITEMS:${jsonEncode(selected)}';
    }

    final reservationNotes = [
      'Birthday celebration, please arrange decoration.',
      'Anniversary dinner – couple seating preferred.',
      'Business meeting, need a quiet corner table.',
      'Family outing with 2 kids – high chair required.',
      'Allergic to nuts, please inform the kitchen.',
      'Vegetarian guests only – no non-veg items.',
      'Pre-ordered items as listed below.',
      'Guest of honour is Dr. Sharma – VIP treatment.',
      'Regular customer – prefers window seat.',
      'Coming after office, might be 15 minutes late.',
    ];

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
      final baseNotes = reservationNotes[random.nextInt(reservationNotes.length)];
      final finalNotes = preOrdersStr.isNotEmpty
          ? '$baseNotes\n$preOrdersStr'
          : baseNotes;

      await db
          .into(db.reservationsTable)
          .insert(
            ReservationsTableCompanion.insert(
              hashId: Value(_seedId(token)),
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

    // 2. Upcoming Reservations: 200 records spanning next day to 2 weeks
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
      final baseNotes = reservationNotes[random.nextInt(reservationNotes.length)];
      final finalNotes = preOrdersStr.isNotEmpty
          ? '$baseNotes\n$preOrdersStr'
          : baseNotes;

      await db
          .into(db.reservationsTable)
          .insert(
            ReservationsTableCompanion.insert(
              hashId: Value(_seedId(token)),
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
    String token,
    DateTime now,
    DateTime Function() getRandomDate,
  ) async {
    var customers = await db.select(db.customersTable).get();
    if (customers.isEmpty) {
      await _generateCustomers(
        db,
        faker,
        random,
        token,
        now,
        now.subtract(const Duration(days: 100)),
      );
      customers = await db.select(db.customersTable).get();
    }

    var tables = await db.select(db.tableInfoTable).get();
    if (tables.isEmpty) {
      await _generateDiningTables(db, token);
      tables = await db.select(db.tableInfoTable).get();
    }

    var menuItems = await db.select(db.menuItemsTable).get();
    if (menuItems.isEmpty) {
      await _generateMenuItems(
        db,
        random,
        token,
        now.subtract(const Duration(days: 100)),
        getRandomDate,
      );
      menuItems = await db.select(db.menuItemsTable).get();
    }

    int inserted = 0;

    // Realistic order item remarks
    final activeRemarks = [
      'Less sugar, extra hot',
      'Make it spicy',
      'No onions in burger',
      'Extra cheese requested',
      'Serve beverages first',
      'Separate sauce on side',
      'Jain preparation',
      'No garlic and onion',
      'Extra crispy fries',
      'Less oil, please',
    ];

    final activeItemStatuses = ['preparing', 'pending', 'ready', 'served'];

    // 1. Create 3 Active Dine-In Orders for 3 distinct tables
    final activeTablesCount = min(3, tables.length);
    for (int tIndex = 0; tIndex < activeTablesCount; tIndex++) {
      final cust = customers[random.nextInt(customers.length)];
      final table = tables[tIndex];
      final nowIso = DateTime.now().toIso8601String();

      final orderId = await db
          .into(db.ordersTable)
          .insert(
            OrdersTableCompanion.insert(
              hashId: Value(_seedId(token)),
              tableInfoId: Value(table.id),
              tableNameText: Value(
                table.tableLabel ?? 'Table ${table.tableNo}',
              ),
              creationDate: Value(nowIso),
              isCanceled: const Value(false),
              isDeleted: const Value(false),
              status: const Value('inProgress'),
              orderType: const Value('Dine-In'),
              paymentMethodName: const Value('Cash'),
              customerId: Value(cust.id),
              customerName: Value(cust.name ?? 'Customer'),
              phoneNumber: Value(cust.phoneNumber ?? '+91 0000000000'),
              isoCode: const Value('IN'),
            ),
          );
      inserted++;

      // Add 2 to 4 items per active order
      final itemBatchCount = 2 + random.nextInt(3);
      final chosenItems = (List.of(
        menuItems,
      )..shuffle(random)).take(itemBatchCount);
      for (final item in chosenItems) {
        final qty = 1 + random.nextInt(2);
        final sPrice = item.sellingPrice ?? 120.0;
        final cPrice = sPrice * 0.55;
        final itemStatus =
            activeItemStatuses[random.nextInt(activeItemStatuses.length)];
        final remark = random.nextBool()
            ? activeRemarks[random.nextInt(activeRemarks.length)]
            : null;

        await db
            .into(db.orderItemsTable)
            .insert(
              OrderItemsTableCompanion.insert(
                orderId: Value(orderId),
                itemId: Value(item.id),
                menuItemId: Value(item.id),
                quantity: Value(qty),
                sellingPrice: Value(sPrice),
                costPrice: Value(cPrice),
                status: Value(itemStatus),
                isMenuItem: const Value(true),
                remarks: Value(remark),
                creationDate: Value(nowIso),
              ),
            );
        inserted++;
      }
    }

    // 2. Generate 147 Historical Completed Orders
    final orderTypes = ['Dine-In', 'Takeaway', 'Delivery'];
    final paymentMethods = ['Cash', 'UPI', 'Credit Card', 'Debit Card'];
    for (int o = 0; o < 147; o++) {
      final cust = customers[random.nextInt(customers.length)];
      final table = tables[random.nextInt(tables.length)];
      final oDate = getRandomDate();
      final chosenType = orderTypes[random.nextInt(orderTypes.length)];
      final chosenPayment = paymentMethods[random.nextInt(paymentMethods.length)];

      final orderId = await db
          .into(db.ordersTable)
          .insert(
            OrdersTableCompanion.insert(
              hashId: Value(_seedId(token)),
              tableInfoId: Value(table.id),
              tableNameText: Value(
                table.tableLabel ?? 'Table ${table.tableNo}',
              ),
              creationDate: Value(oDate.toIso8601String()),
              isCanceled: const Value(false),
              isDeleted: const Value(false),
              status: const Value('completed'),
              orderType: Value(chosenType),
              paymentMethodName: Value(chosenPayment),
              customerId: Value(cust.id),
              customerName: Value(cust.name ?? 'Customer'),
              phoneNumber: Value(cust.phoneNumber ?? '+91 9876543210'),
              isoCode: const Value('IN'),
            ),
          );
      inserted++;

      final itemBatchCount = 1 + random.nextInt(3);
      final chosenItems = (List.of(
        menuItems,
      )..shuffle(random)).take(itemBatchCount);
      for (final item in chosenItems) {
        final qty = 1 + random.nextInt(2);
        final sPrice = item.sellingPrice ?? 120.0;
        final cPrice = sPrice * 0.55;

        await db
            .into(db.orderItemsTable)
            .insert(
              OrderItemsTableCompanion.insert(
                orderId: Value(orderId),
                itemId: Value(item.id),
                menuItemId: Value(item.id),
                quantity: Value(qty),
                sellingPrice: Value(sPrice),
                costPrice: Value(cPrice),
                status: const Value('served'),
                isMenuItem: const Value(true),
                creationDate: Value(oDate.toIso8601String()),
              ),
            );
        inserted++;
      }
    }
    return inserted;
  }

  static Future<int> _generateInvoices(
    CoozyDatabase db,
    Faker faker,
    Random random,
    String token,
    DateTime now,
    DateTime Function() getRandomDate,
  ) async {
    var orders = await (db.select(
      db.ordersTable,
    )..where((t) => t.status.equals('completed'))).get();

    if (orders.isEmpty) {
      await _generateOrders(db, faker, random, token, now, getRandomDate);
      orders = await (db.select(
        db.ordersTable,
      )..where((t) => t.status.equals('completed'))).get();
    }

    final paymentMethods = ['UPI', 'Cash', 'Credit Card', 'Debit Card'];
    int inserted = 0;

    for (final order in orders.take(100)) {
      final orderItems = await (db.select(
        db.orderItemsTable,
      )..where((t) => t.orderId.equals(order.id))).get();

      double subtotal = 0.0;
      final invoiceItemCompanions = <InvoiceItemsTableCompanion>[];

      if (orderItems.isNotEmpty) {
        for (final item in orderItems) {
          final itemTotal = (item.sellingPrice ?? 100.0) * (item.quantity ?? 1);
          subtotal += itemTotal;
          // Resolve the actual menu item name
          final menuItem = await (db.select(db.menuItemsTable)
                ..where((t) => t.id.equals(item.menuItemId ?? item.itemId ?? 0)))
              .getSingleOrNull();
          invoiceItemCompanions.add(
            InvoiceItemsTableCompanion.insert(
              itemName: Value(menuItem?.name ?? 'Menu Item'),
              quantity: Value(item.quantity ?? 1),
              sellingPrice: Value(item.sellingPrice ?? 100.0),
              totalPrice: Value(itemTotal),
              createdDate: Value(order.creationDate ?? now.toIso8601String()),
            ),
          );
        }
      } else {
        subtotal = 250.0 + random.nextInt(500);
        invoiceItemCompanions.add(
          InvoiceItemsTableCompanion.insert(
            itemName: const Value('Coozy Special'),
            quantity: const Value(2),
            sellingPrice: Value(subtotal / 2),
            totalPrice: Value(subtotal),
            createdDate: Value(order.creationDate ?? now.toIso8601String()),
          ),
        );
      }

      // Round to 2 decimal places
      subtotal = double.parse(subtotal.toStringAsFixed(2));
      final tax = double.parse((subtotal * 0.05).toStringAsFixed(2));
      final total = double.parse((subtotal + tax).toStringAsFixed(2));
      final payMethod = order.paymentMethodName ??
          paymentMethods[random.nextInt(paymentMethods.length)];

      // Cash received (round up to nearest 10 for cash payments)
      double cashReceived = total;
      if (payMethod == 'Cash') {
        cashReceived = (total / 10).ceil() * 10.0;
      }
      // change = cashReceived - total (kept for reference; not stored separately)

      final invoiceId = await db
          .into(db.invoicesTable)
          .insert(
            InvoicesTableCompanion.insert(
              orderId: Value(order.id),
              hashId: Value(_seedId(token)),
              taxPercentage: const Value(5.0),
              totalCost: Value(subtotal),
              taxCost: Value(tax),
              taxableAmount: Value(subtotal),
              netPaymentAmount: Value(total),
              recordAmountPaid: Value(cashReceived),
              createdDate: Value(order.creationDate ?? now.toIso8601String()),
              customerId: Value(order.customerId),
              customerName: Value(order.customerName ?? 'Customer'),
              phoneNumber: Value(order.phoneNumber ?? '+91 9876543210'),
              paymentMethodName: Value(payMethod),
            ),
          );
      inserted++;

      for (final itemComp in invoiceItemCompanions) {
        await db
            .into(db.invoiceItemsTable)
            .insert(itemComp.copyWith(invoiceId: Value(invoiceId)));
        inserted++;
      }

      await db
          .into(db.paymentTransactionsTable)
          .insert(
            PaymentTransactionsTableCompanion.insert(
              invoiceId: Value(invoiceId),
              amount: Value(total),
              paymentMethodName: Value(payMethod),
              transactionReference: Value(
                'TXN${const Uuid().v4().substring(0, 8).toUpperCase()}',
              ),
              paymentStatus: const Value('Success'),
              createdDate: Value(order.creationDate ?? now.toIso8601String()),
            ),
          );
      inserted++;
    }
    return inserted;
  }

  /// Removes all seed records.
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

  /// Removes specific seed records associated with stage keys.
  static Future<void> removeDatasetData(
    CoozyDatabase db,
    List<String> rawStageKeys, {
    FakeDataProgressCallback? onProgress,
  }) async {
    final token = await _getSeedToken();
    final tokenPattern = '$token%';

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
        'Cleaning up $key records...',
        stepIndex,
        totalSteps,
      );
      if (key == 'invoices') {
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'orders') {
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM orders WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'reservations') {
        await db.customStatement(
          "DELETE FROM reservations WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'purchases') {
        await db.customStatement(
          "DELETE FROM purchase WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'recipes') {
        // Recipes are deleted by matching their names from our seed list
        for (final r in [
          'Espresso Cappuccino Blend',
          'Caramel Biscoff Frappe',
          'Tandoori Paneer Pizza',
          'Nutella Brownie Shake',
          'Spicy Ramen with Cheese',
          'Cheese Overload Loaded Fries',
          'Dal Makhani',
          'Coozy 4 Cheese Grill Sandwich',
        ]) {
          await db.customStatement(
            "DELETE FROM recipes WHERE recipe_original_name = '${r.replaceAll("'", "''")}';",
          );
        }
      } else if (key == 'inventory') {
        await db.customStatement(
          "DELETE FROM purchase WHERE inventory_id IN (SELECT id FROM inventory WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM inventory WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'menu_items') {
        await db.customStatement(
          "DELETE FROM order_items WHERE menu_item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM menu_item_variations WHERE menu_item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM menu_item_reviews WHERE item_id IN (SELECT id FROM menu_items WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM menu_items WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'subcategories') {
        await db.customStatement(
          "DELETE FROM menu_item_variations WHERE menu_item_id IN (SELECT id FROM menu_items WHERE subcategory_id IN (SELECT id FROM menu_subcategories WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM menu_item_reviews WHERE item_id IN (SELECT id FROM menu_items WHERE subcategory_id IN (SELECT id FROM menu_subcategories WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM menu_items WHERE subcategory_id IN (SELECT id FROM menu_subcategories WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM menu_subcategories WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'categories') {
        await db.customStatement(
          "DELETE FROM menu_item_variations WHERE menu_item_id IN (SELECT id FROM menu_items WHERE category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM menu_item_reviews WHERE item_id IN (SELECT id FROM menu_items WHERE category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM menu_items WHERE category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM menu_subcategories WHERE category_id IN (SELECT id FROM menu_categories WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM menu_categories WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'attendance') {
        await db.customStatement(
          "DELETE FROM attendance WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$tokenPattern');",
        );
      } else if (key == 'leaves') {
        await db.customStatement(
          "DELETE FROM leaves WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$tokenPattern');",
        );
      } else if (key == 'employees') {
        await db.customStatement(
          "DELETE FROM attendance WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM leaves WHERE employee_id IN (SELECT id FROM employees WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM employees WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'customers') {
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM orders WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM reservations WHERE customer_id IN (SELECT id FROM customers WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM customers WHERE hash_id LIKE '$tokenPattern';",
        );
      } else if (key == 'table_info') {
        await db.customStatement(
          "DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$tokenPattern')));",
        );
        await db.customStatement(
          "DELETE FROM payment_transactions WHERE invoice_id IN (SELECT id FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$tokenPattern')));",
        );
        await db.customStatement(
          "DELETE FROM invoices WHERE order_id IN (SELECT id FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$tokenPattern'));",
        );
        await db.customStatement(
          "DELETE FROM orders WHERE table_info_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM reservations WHERE table_id IN (SELECT id FROM table_info WHERE hash_id LIKE '$tokenPattern');",
        );
        await db.customStatement(
          "DELETE FROM table_info WHERE hash_id LIKE '$tokenPattern';",
        );
      }
    }
  }

  /// Returns current seed record counts per dataset key.
  static Future<Map<String, int>> getDatasetCounts(CoozyDatabase db) async {
    final token = await _getSeedToken();
    final tokenPattern = '$token%';
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
      "SELECT COUNT(*) as c FROM customers WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['employees'] = await queryCount(
      "SELECT COUNT(*) as c FROM employees WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['attendance'] = await queryCount(
      "SELECT COUNT(*) as c FROM attendance WHERE creation_date IS NOT NULL",
    );
    counts['leaves'] = await queryCount(
      "SELECT COUNT(*) as c FROM leaves WHERE creation_date IS NOT NULL",
    );
    counts['table_info'] = await queryCount(
      "SELECT COUNT(*) as c FROM table_info WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['categories'] = await queryCount(
      "SELECT COUNT(*) as c FROM menu_categories WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['subcategories'] = await queryCount(
      "SELECT COUNT(*) as c FROM menu_subcategories WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['menu_items'] = await queryCount(
      "SELECT COUNT(*) as c FROM menu_items WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['recipes'] = await queryCount(
      "SELECT COUNT(*) as c FROM recipes WHERE recipe_original_name IN (${[
        'Espresso Cappuccino Blend',
        'Caramel Biscoff Frappe',
        'Tandoori Paneer Pizza',
        'Nutella Brownie Shake',
        'Spicy Ramen with Cheese',
        'Cheese Overload Loaded Fries',
        'Dal Makhani',
        'Coozy 4 Cheese Grill Sandwich',
      ].map((n) => "'${n.replaceAll("'", "''")}'").join(',')})",
    );
    counts['inventory'] = await queryCount(
      "SELECT COUNT(*) as c FROM inventory WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['purchases'] = await queryCount(
      "SELECT COUNT(*) as c FROM purchase WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['reservations'] = await queryCount(
      "SELECT COUNT(*) as c FROM reservations WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['orders'] = await queryCount(
      "SELECT COUNT(*) as c FROM orders WHERE hash_id LIKE '$tokenPattern'",
    );
    counts['invoices'] = await queryCount(
      "SELECT COUNT(*) as c FROM invoices WHERE hash_id LIKE '$tokenPattern'",
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

  /// Shows a quick module-level seed data toggle dialog.
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
                      'Sample $title Data',
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
                        ? 'Sample $title data is currently ACTIVE in database.'
                        : 'Sample $title data is currently INACTIVE.',
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
                                    content: Text('Sample $title data removed.'),
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
                                      'Generated $count sample $title records!',
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
