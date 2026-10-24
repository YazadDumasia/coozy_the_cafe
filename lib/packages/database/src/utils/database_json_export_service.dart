import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

/// Service for exporting and importing the entire Coozy The Cafe database
/// to and from portable JSON format.
class DatabaseJsonExportService {
  final CoozyDatabase db;

  DatabaseJsonExportService(this.db);

  /// Exports all core cafe tables into a single formatted JSON map.
  Future<Map<String, dynamic>> exportAllTablesToJson({
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.05, 'Starting JSON export...');

    final exportData = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'appName': 'Coozy The Cafe',
    };

    onProgress?.call(0.10, 'Exporting Tables & Categories...');
    final tableInfo = await db.select(db.tableInfoTable).get();
    exportData['table_info'] = tableInfo.map((e) => e.toJson()).toList();

    final categories = await db.select(db.categoriesTable).get();
    exportData['categories'] = categories.map((e) => e.toJson()).toList();

    final subcategories = await db.select(db.subcategoriesTable).get();
    exportData['subcategories'] = subcategories.map((e) => e.toJson()).toList();

    onProgress?.call(0.25, 'Exporting Menu Items & Variations...');
    final menuItems = await db.select(db.menuItemsTable).get();
    exportData['menu_items'] = menuItems.map((e) => e.toJson()).toList();

    final menuItemVariations = await db.select(db.menuItemVariationsTable).get();
    exportData['menu_item_variations'] =
        menuItemVariations.map((e) => e.toJson()).toList();

    onProgress?.call(0.40, 'Exporting Inventory & Purchases...');
    final inventory = await db.select(db.inventoryTable).get();
    exportData['inventory'] = inventory.map((e) => e.toJson()).toList();

    final purchases = await db.select(db.purchaseTable).get();
    exportData['purchases'] = purchases.map((e) => e.toJson()).toList();

    final stockAdjustments =
        await db.select(db.inventoryStockAdjustmentsTable).get();
    exportData['inventory_stock_adjustments'] =
        stockAdjustments.map((e) => e.toJson()).toList();

    onProgress?.call(0.55, 'Exporting Customers & Loyalty...');
    final customers = await db.select(db.customersTable).get();
    exportData['customers'] = customers.map((e) => e.toJson()).toList();

    final customerLoyalty = await db.select(db.customerLoyaltyTable).get();
    exportData['customer_loyalty'] =
        customerLoyalty.map((e) => e.toJson()).toList();

    final loyaltyTransactions =
        await db.select(db.loyaltyTransactionsTable).get();
    exportData['loyalty_transactions'] =
        loyaltyTransactions.map((e) => e.toJson()).toList();

    onProgress?.call(0.70, 'Exporting Orders & Invoices...');
    final orders = await db.select(db.ordersTable).get();
    exportData['orders'] = orders.map((e) => e.toJson()).toList();

    final orderItems = await db.select(db.orderItemsTable).get();
    exportData['order_items'] = orderItems.map((e) => e.toJson()).toList();

    final invoices = await db.select(db.invoicesTable).get();
    exportData['invoices'] = invoices.map((e) => e.toJson()).toList();

    final invoiceItems = await db.select(db.invoiceItemsTable).get();
    exportData['invoice_items'] = invoiceItems.map((e) => e.toJson()).toList();

    final paymentModes = await db.select(db.paymentModesTable).get();
    exportData['payment_modes'] = paymentModes.map((e) => e.toJson()).toList();

    onProgress?.call(0.85, 'Exporting Taxes, Discounts & Charges...');
    final taxes = await db.select(db.taxesTable).get();
    exportData['taxes'] = taxes.map((e) => e.toJson()).toList();

    final discounts = await db.select(db.discountsTable).get();
    exportData['discounts'] = discounts.map((e) => e.toJson()).toList();

    final extraCharges = await db.select(db.extraChargesTable).get();
    exportData['extra_charges'] = extraCharges.map((e) => e.toJson()).toList();

    final paymentMethods = await db.select(db.paymentMethodsTable).get();
    exportData['payment_methods'] =
        paymentMethods.map((e) => e.toJson()).toList();

    onProgress?.call(0.92, 'Exporting Expenditures & Staff...');
    final expenditureCats =
        await db.select(db.expenditureCategoriesTable).get();
    exportData['expenditure_categories'] =
        expenditureCats.map((e) => e.toJson()).toList();

    final expenditures = await db.select(db.expendituresTable).get();
    exportData['expenditures'] = expenditures.map((e) => e.toJson()).toList();

    final employees = await db.select(db.employeesTable).get();
    exportData['employees'] = employees.map((e) => e.toJson()).toList();

    final reservations = await db.select(db.reservationsTable).get();
    exportData['reservations'] = reservations.map((e) => e.toJson()).toList();

    final recipes = await db.select(db.recipesTable).get();
    exportData['recipes'] = recipes.map((e) => e.toJson()).toList();

    onProgress?.call(1.0, 'Export complete!');
    return exportData;
  }

  /// Writes exported JSON to a local timestamped file (or prepares string on web) and returns its path.
  Future<String> exportToFile({
    void Function(double progress, String status)? onProgress,
  }) async {
    final data = await exportAllTablesToJson(onProgress: onProgress);
    onProgress?.call(0.95, 'Writing JSON export file...');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'coozy_backup_data_$timestamp.json';

    if (kIsWeb) {
      onProgress?.call(1.0, 'File created: $filename');
      return filename;
    }

    final tempDir = await path_provider.getTemporaryDirectory();
    final filePath = p.join(tempDir.path, filename);

    final file = File(filePath);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    onProgress?.call(1.0, 'File created: ${p.basename(filePath)}');
    return filePath;
  }

  /// Imports and restores database records from exported JSON map.
  Future<int> importFromJsonString(
    String jsonString, {
    void Function(double progress, String status)? onProgress,
  }) async {
    onProgress?.call(0.05, 'Parsing JSON backup...');
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON backup file format');
    }

    int totalImported = 0;

    await db.transaction(() async {
      // 1. Table Info
      if (decoded['table_info'] is List) {
        onProgress?.call(0.10, 'Importing Table Info...');
        for (final item in (decoded['table_info'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.tableInfoTable).insertOnConflictUpdate(
                  TableInfoTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    tableLabel: drift.Value(item['tableLabel'] as String?),
                    tableNo: drift.Value(item['tableNo'] as String?),
                    colorValue: drift.Value(item['colorValue'] as String?),
                    sortOrderIndex:
                        drift.Value(item['sortOrderIndex'] as int?),
                    nosOfChairs: drift.Value(item['nosOfChairs'] as int?),
                    isActive: drift.Value(item['isActive'] as bool?),
                  ),
                );
            totalImported++;
          }
        }
      }

      // 2. Categories & Subcategories
      if (decoded['categories'] is List) {
        onProgress?.call(0.20, 'Importing Categories...');
        for (final item in (decoded['categories'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.categoriesTable).insertOnConflictUpdate(
                  CategoriesTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    name: drift.Value(item['name'] as String?),
                    isActive: drift.Value(item['isActive'] as bool?),
                    position: drift.Value(item['position'] as int?),
                    createdDate: drift.Value(item['createdDate'] as String?),
                  ),
                );
            totalImported++;
          }
        }
      }

      if (decoded['subcategories'] is List) {
        onProgress?.call(0.25, 'Importing Subcategories...');
        for (final item in (decoded['subcategories'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.subcategoriesTable).insertOnConflictUpdate(
                  SubcategoriesTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    name: drift.Value(item['name'] as String?),
                    createdDate: drift.Value(item['createdDate'] as String?),
                    categoryId: drift.Value(item['categoryId'] as int?),
                    isActive: drift.Value(item['isActive'] as bool?),
                    position: drift.Value(item['position'] as int?),
                  ),
                );
            totalImported++;
          }
        }
      }

      // 3. Menu Items & Variations
      if (decoded['menu_items'] is List) {
        onProgress?.call(0.35, 'Importing Menu Items...');
        for (final item in (decoded['menu_items'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.menuItemsTable).insertOnConflictUpdate(
                  MenuItemsTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    name: drift.Value(item['name'] as String? ?? 'Item'),
                    description: drift.Value(item['description'] as String? ?? ''),
                    foodType: drift.Value(item['foodType'] as String?),
                    creationDate: drift.Value(item['creationDate'] as String?),
                    modificationDate:
                        drift.Value(item['modificationDate'] as String?),
                    duration: drift.Value(item['duration'] as int?),
                    categoryId: drift.Value(item['categoryId'] as int?),
                    subcategoryId: drift.Value(item['subcategoryId'] as int?),
                    isTodayAvailable:
                        drift.Value(item['isTodayAvailable'] as bool?),
                    isSimpleVariation:
                        drift.Value(item['isSimpleVariation'] as bool?),
                    costPrice: drift.Value(
                      (item['costPrice'] as num?)?.toDouble(),
                    ),
                    sellingPrice: drift.Value(
                      (item['sellingPrice'] as num?)?.toDouble(),
                    ),
                    stockQuantity: drift.Value(
                      (item['stockQuantity'] as num?)?.toDouble(),
                    ),
                    quantity: drift.Value(item['quantity'] as String?),
                    purchaseUnit: drift.Value(item['purchaseUnit'] as String?),
                    sortOrderIndex:
                        drift.Value(item['sortOrderIndex'] as int?),
                  ),
                );
            totalImported++;
          }
        }
      }

      if (decoded['menu_item_variations'] is List) {
        onProgress?.call(0.40, 'Importing Menu Item Variations...');
        for (final item in (decoded['menu_item_variations'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.menuItemVariationsTable).insertOnConflictUpdate(
                  MenuItemVariationsTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    name: drift.Value(item['name'] as String?),
                    menuItemId: drift.Value(item['menuItemId'] as int?),
                    quantity: drift.Value(item['quantity'] as int?),
                    purchaseUnit: drift.Value(item['purchaseUnit'] as String?),
                    isTodayAvailable:
                        drift.Value(item['isTodayAvailable'] as bool?),
                    costPrice: drift.Value(
                      (item['costPrice'] as num?)?.toDouble(),
                    ),
                    sellingPrice: drift.Value(
                      (item['sellingPrice'] as num?)?.toDouble(),
                    ),
                    stockQuantity: drift.Value(item['stockQuantity'] as int?),
                    sortOrderIndex:
                        drift.Value(item['sortOrderIndex'] as int?),
                    creationDate: drift.Value(item['creationDate'] as String?),
                    modificationDate:
                        drift.Value(item['modificationDate'] as String?),
                  ),
                );
            totalImported++;
          }
        }
      }

      // 4. Inventory
      if (decoded['inventory'] is List) {
        onProgress?.call(0.50, 'Importing Inventory...');
        for (final item in (decoded['inventory'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.inventoryTable).insertOnConflictUpdate(
                  InventoryTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    name: drift.Value(item['name'] as String?),
                    shortDescription:
                        drift.Value(item['shortDescription'] as String?),
                    purchaseUnit: drift.Value(item['purchaseUnit'] as String?),
                    currentStock: drift.Value(
                      (item['currentStock'] as num?)?.toDouble(),
                    ),
                    isEnabled: drift.Value(item['isEnabled'] as bool? ?? true),
                    createdDate: drift.Value(item['createdDate'] as String?),
                    modifiedDate: drift.Value(item['modifiedDate'] as String?),
                  ),
                );
            totalImported++;
          }
        }
      }

      // 5. Customers & Loyalty
      if (decoded['customers'] is List) {
        onProgress?.call(0.60, 'Importing Customers...');
        for (final item in (decoded['customers'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.customersTable).insertOnConflictUpdate(
                  CustomersTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    name: drift.Value(item['name'] as String?),
                    phoneNumber: drift.Value(item['phoneNumber'] as String?),
                    isoCode: drift.Value(item['isoCode'] as String?),
                    createdDate: drift.Value(item['createdDate'] as String?),
                  ),
                );
            totalImported++;
          }
        }
      }

      // 6. Taxes & Discounts
      if (decoded['taxes'] is List) {
        onProgress?.call(0.70, 'Importing Taxes...');
        for (final item in (decoded['taxes'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.taxesTable).insertOnConflictUpdate(
                  TaxesTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    name: drift.Value(item['name'] as String? ?? 'Tax'),
                    ratePercent: drift.Value(
                      (item['ratePercent'] as num?)?.toDouble() ?? 0.0,
                    ),
                    isDefaultAdd:
                        drift.Value(item['isDefaultAdd'] as bool? ?? false),
                  ),
                );
            totalImported++;
          }
        }
      }

      if (decoded['discounts'] is List) {
        onProgress?.call(0.80, 'Importing Discounts...');
        for (final item in (decoded['discounts'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.discountsTable).insertOnConflictUpdate(
                  DiscountsTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    name: drift.Value(item['name'] as String? ?? 'Discount'),
                    value: drift.Value(
                      (item['value'] as num?)?.toDouble() ?? 0.0,
                    ),
                    isPercentage:
                        drift.Value(item['isPercentage'] as bool? ?? false),
                    isDefaultAdd:
                        drift.Value(item['isDefaultAdd'] as bool? ?? false),
                  ),
                );
            totalImported++;
          }
        }
      }

      // 7. Payment Modes
      if (decoded['payment_modes'] is List) {
        onProgress?.call(0.90, 'Importing Payment Modes...');
        for (final item in (decoded['payment_modes'] as List)) {
          if (item is Map<String, dynamic>) {
            await db.into(db.paymentModesTable).insertOnConflictUpdate(
                  PaymentModesTableCompanion(
                    id: item['id'] != null
                        ? drift.Value(item['id'] as int)
                        : const drift.Value.absent(),
                    hashId: item['hashId'] != null
                        ? drift.Value(item['hashId'] as String)
                        : const drift.Value.absent(),
                    paymentMethodName: drift.Value(
                      item['paymentMethodName'] as String? ?? 'Cash',
                    ),
                  ),
                );
            totalImported++;
          }
        }
      }
    });

    core.PlatformUtils.debugLog(
      DatabaseJsonExportService,
      'JSON Backup import completed with $totalImported records restored.',
    );
    onProgress?.call(1.0, 'Import finished: $totalImported items processed.');
    return totalImported;
  }
}
