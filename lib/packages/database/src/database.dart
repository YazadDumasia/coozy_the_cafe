import 'dart:io';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:synchronized/synchronized.dart' as sync;
import 'constants/db_constants.dart' as db_constants;

import 'tables.dart';
import 'connection.dart';
import 'database_dao/categories_dao.dart';
import 'database_dao/customers_dao.dart';
import 'database_dao/staff_management_dao.dart';
import 'database_dao/inventory_dao.dart';
import 'database_dao/expenditure_dao.dart';
import 'database_dao/invoices_dao.dart';
import 'database_dao/kitchen_orders_dao.dart';
import 'database_dao/menu_items_dao.dart';
import 'database_dao/orders_dao.dart';
import 'database_dao/recipes_dao.dart';
import 'database_dao/reports_dao.dart';
import 'database_dao/reservations_dao.dart';
import 'database_dao/user_logins_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    TableInfoTable,
    CategoriesTable,
    SubcategoriesTable,
    MenuItemsTable,
    MenuItemVariationsTable,
    MenuItemReviewsTable,
    InventoryTable,
    InventoryStockAdjustmentsTable,
    PurchaseTable,
    CustomersTable,
    OrdersTable,
    OrderItemsTable,
    InvoicesTable,
    InvoiceItemsTable,
    PaymentModesTable,
    PaymentTransactionsTable,
    RecipesTable,
    EmployeesTable,
    AttendanceTable,
    LeavesTable,
    ReservationsTable,
    RolesTable,
    UserLoginsTable,
    PermissionsTable,
    RolePermissionsTable,
    TaxesTable,
    DiscountsTable,
    ExtraChargesTable,
    PaymentMethodsTable,
    ExpenditureCategoriesTable,
    ExpendituresTable,
  ],
  daos: [
    CategoriesDao,
    CustomersDao,
    StaffManagementDao,
    InventoryDao,
    InvoicesDao,
    KitchenOrdersDao,
    MenuItemsDao,
    OrdersDao,
    RecipesDao,
    ReportsDao,
    ReservationsDao,
    UserLoginsDao,
    ExpenditureDao,
  ],
)
class CoozyDatabase extends _$CoozyDatabase {
  CoozyDatabase() : super(openConnection('coozy_the_cafe.db'));

  CoozyDatabase.withQueryExecutor(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_invoice_pagination ON invoices (created_date DESC, id DESC);',
      );
      try {
        await customStatement(
          'ALTER TABLE invoices ADD COLUMN is_deleted INTEGER DEFAULT 0;',
        );
      } catch (_) {
        // Column may already exist
      }
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_reservations_pagination ON reservations (reservation_date_time DESC, id DESC);',
      );
      await customStatement('''
        CREATE TABLE IF NOT EXISTS inventory_stock_adjustments (
          created_by INTEGER,
          updated_by INTEGER,
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          hash_id TEXT NOT NULL UNIQUE,
          inventory_id INTEGER REFERENCES inventory (id),
          inventory_name TEXT,
          adjustment_type TEXT,
          adjusted_qty REAL,
          previous_stock REAL,
          new_stock REAL,
          reason TEXT,
          created_date TEXT
        );
      ''');
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_stock_adjustment_inventoryId ON inventory_stock_adjustments (inventory_id);',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_stock_adjustment_date ON inventory_stock_adjustments (created_date);',
      );
      await customStatement('''
        CREATE TABLE IF NOT EXISTS expenditure_categories (
          created_by INTEGER,
          updated_by INTEGER,
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          hash_id TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          icon_code_point INTEGER,
          icon_font_family TEXT,
          color_hex TEXT,
          is_custom INTEGER NOT NULL DEFAULT 0,
          is_enabled INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL
        );
      ''');
      await customStatement('''
        CREATE TABLE IF NOT EXISTS expenditures (
          created_by INTEGER,
          updated_by INTEGER,
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          hash_id TEXT NOT NULL UNIQUE,
          type TEXT NOT NULL,
          category_id INTEGER REFERENCES expenditure_categories (id) ON DELETE SET NULL,
          category_name TEXT NOT NULL,
          amount REAL NOT NULL,
          party_name TEXT,
          date TEXT NOT NULL,
          payment_method TEXT,
          notes TEXT,
          reference_type TEXT,
          reference_id INTEGER,
          is_deleted INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          modified_at TEXT NOT NULL
        );
      ''');
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_expenditures_date ON expenditures (date DESC, id DESC);',
      );
      await batch((batch) {
        for (final p in db_constants.DbConstants.allPermissions) {
          batch.insert(
            permissionsTable,
            PermissionsTableCompanion(
              name: Value(p),
              description: Value('Allows access to $p features'),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
      // Seed initial default categories if table is empty
      final catCount = await select(expenditureCategoriesTable).get();
      if (catCount.isEmpty) {
        final defaultExpenses = [
          'Tax',
          'Fuel',
          'Food',
          'Bill',
          'Transportation',
          'Insurance',
          'Salary',
          'Rent',
          'Repairs',
          'Commissions',
          'Advertising',
          'Fee',
          'Interest',
          'Loan',
          'Supplies',
          'Transfer',
          'Contract',
          'Miscellaneous',
          'Disposable',
          'Bread',
          'Vegetables',
          'Milk',
          'Cold Drinks',
          'Sauce',
        ];
        final defaultIncomes = [
          'Profit',
          'Salary',
          'Awards',
          'Rental',
          'Sale',
          'Refund',
          'Lottery',
          'Dividend',
          'Investment',
          'Interest',
          'Commission',
          'Fee',
          'Loan',
          'Miscellaneous',
        ];
        await batch((batch) {
          for (final exp in defaultExpenses) {
            batch.insert(
              expenditureCategoriesTable,
              ExpenditureCategoriesTableCompanion.insert(
                name: exp,
                type: 'EXPENSE',
                isCustom: const Value(false),
                isEnabled: const Value(true),
              ),
            );
          }
          for (final inc in defaultIncomes) {
            batch.insert(
              expenditureCategoriesTable,
              ExpenditureCategoriesTableCompanion.insert(
                name: inc,
                type: 'INCOME',
                isCustom: const Value(false),
                isEnabled: const Value(true),
              ),
            );
          }
        });
      }
    },
    onUpgrade: (m, from, to) async {},
  );

  static const String secretKey = 'CoozyTheCafe';
  final sync.Lock _dbLock = sync.Lock();

  Future<String> getDbPath() async {
    final dbDir = await path_provider.getApplicationDocumentsDirectory();
    return path.join(dbDir.path, 'coozy_the_cafe.db');
  }

  Future<void> wipeDatabase() async {
    await _dbLock.synchronized(() async {
      await close();
      final path = await getDbPath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    });
  }

  Future<String> backupDatabase({
    bool encryptBackup = true,
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Requesting permissions...');
    await _requestPermissions();
    final sourcePath = await getDbPath();
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) throw Exception('Database file not found');

    onProgress?.call(0.05, 'Closing database...');
    await _dbLock.synchronized(() async {
      await close();
    });

    onProgress?.call(0.1, 'Creating backup...');
    final backupDir = await _getBackupDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final backupFile = File(
      path.join(
        backupDir.path,
        '${db_constants.DbConstants.fullBackupPrefix}_$ts.db',
      ),
    );

    final totalBytes = await sourceFile.length();
    int copied = 0;
    final sink = backupFile.openWrite();
    await for (final chunk in sourceFile.openRead()) {
      sink.add(chunk);
      copied += chunk.length;
      onProgress?.call(0.1 + (copied / totalBytes) * 0.4, 'Copying...');
    }
    await sink.close();

    String finalPath = backupFile.path;
    if (encryptBackup) {
      final enc = await _encryptFile(backupFile, onProgress: onProgress);
      await backupFile.delete();
      finalPath = enc.path;
    }

    onProgress?.call(0.95, 'Reopening database...');
    // The database is lazily opened again on next request.
    onProgress?.call(1.0, 'Backup complete!');
    return finalPath;
  }

  Future<void> restoreDatabase(
    String backupFilePath, {
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Requesting permissions...');
    await _requestPermissions();
    final backupFile = File(backupFilePath);
    if (!await backupFile.exists()) throw Exception('Backup not found');

    await _dbLock.synchronized(() async {
      await close();
    });

    File sourceFile;
    if (backupFilePath.endsWith('.enc')) {
      sourceFile = await _decryptFile(backupFile, onProgress: onProgress);
    } else {
      sourceFile = backupFile;
    }

    onProgress?.call(0.5, 'Restoring...');
    final targetPath = await getDbPath();
    final targetFile = File(targetPath);
    final totalBytes = await sourceFile.length();
    int copied = 0;
    final sink = targetFile.openWrite();
    await for (final chunk in sourceFile.openRead()) {
      sink.add(chunk);
      copied += chunk.length;
      onProgress?.call(0.5 + (copied / totalBytes) * 0.45, 'Restoring...');
    }
    await sink.close();

    if (backupFilePath.endsWith('.enc') &&
        sourceFile.path.endsWith('.decrypted')) {
      await sourceFile.delete();
    }

    onProgress?.call(0.95, 'Reopening database...');
    // Will be reopened lazily.
    onProgress?.call(1.0, 'Restore complete!');
  }

  Future<File> _encryptFile(
    File inputFile, {
    void Function(double, String)? onProgress,
  }) async {
    onProgress?.call(0.55, 'Encrypting...');
    final key = encrypt.Key.fromUtf8(secretKey.padRight(32, '0'));
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final inputBytes = await inputFile.readAsBytes();
    final encrypted = encrypter.encryptBytes(inputBytes, iv: iv);
    final encryptedFile = File('${inputFile.path}.enc');
    await encryptedFile.writeAsBytes(encrypted.bytes);
    final ivFile = File('${inputFile.path}.iv');
    await ivFile.writeAsString(iv.base64);
    // platform_utils.PlatformUtils.debugLog(
    //   CoozyDatabase,
    //   'Encryption IV saved: ${iv.base64}',
    // );
    return encryptedFile;
  }

  Future<File> _decryptFile(
    File encryptedFile, {
    void Function(double, String)? onProgress,
  }) async {
    onProgress?.call(0.05, 'Decrypting...');
    final key = encrypt.Key.fromUtf8(secretKey.padRight(32, '0'));
    final ivPath = encryptedFile.path.replaceAll('.enc', '.iv');
    final ivFile = File(ivPath);
    if (!await ivFile.exists()) throw Exception('IV file not found: $ivPath');
    final iv = encrypt.IV.fromBase64(await ivFile.readAsString());
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final encryptedBytes = await encryptedFile.readAsBytes();
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(encryptedBytes),
      iv: iv,
    );
    final decryptedFile = File('${encryptedFile.path}.decrypted');
    await decryptedFile.writeAsBytes(decrypted);
    return decryptedFile;
  }

  Future<Directory> _getBackupDirectory() async {
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) return dir;
      return await path_provider.getExternalStorageDirectory() ??
          await path_provider.getApplicationDocumentsDirectory();
    }
    return await path_provider.getApplicationDocumentsDirectory();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await permission_handler.Permission.storage.request();
      if (await permission_handler.Permission.storage.isDenied) {
        await permission_handler.Permission.manageExternalStorage.request();
      }
    }
  }
}
