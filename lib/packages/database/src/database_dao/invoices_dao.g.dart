// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoices_dao.dart';

// ignore_for_file: type=lint
mixin _$InvoicesDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $RolesTableTable get rolesTable => attachedDatabase.rolesTable;
  $UserLoginsTableTable get userLoginsTable => attachedDatabase.userLoginsTable;
  $PaymentModesTableTable get paymentModesTable =>
      attachedDatabase.paymentModesTable;
  $TableInfoTableTable get tableInfoTable => attachedDatabase.tableInfoTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $ReservationsTableTable get reservationsTable =>
      attachedDatabase.reservationsTable;
  $OrdersTableTable get ordersTable => attachedDatabase.ordersTable;
  $InvoicesTableTable get invoicesTable => attachedDatabase.invoicesTable;
  $InvoiceItemsTableTable get invoiceItemsTable =>
      attachedDatabase.invoiceItemsTable;
  $PaymentTransactionsTableTable get paymentTransactionsTable =>
      attachedDatabase.paymentTransactionsTable;
  InvoicesDaoManager get managers => InvoicesDaoManager(this);
}

class InvoicesDaoManager {
  final _$InvoicesDaoMixin _db;
  InvoicesDaoManager(this._db);
  $$RolesTableTableTableManager get rolesTable =>
      $$RolesTableTableTableManager(_db.attachedDatabase, _db.rolesTable);
  $$UserLoginsTableTableTableManager get userLoginsTable =>
      $$UserLoginsTableTableTableManager(
        _db.attachedDatabase,
        _db.userLoginsTable,
      );
  $$PaymentModesTableTableTableManager get paymentModesTable =>
      $$PaymentModesTableTableTableManager(
        _db.attachedDatabase,
        _db.paymentModesTable,
      );
  $$TableInfoTableTableTableManager get tableInfoTable =>
      $$TableInfoTableTableTableManager(
        _db.attachedDatabase,
        _db.tableInfoTable,
      );
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(
        _db.attachedDatabase,
        _db.customersTable,
      );
  $$ReservationsTableTableTableManager get reservationsTable =>
      $$ReservationsTableTableTableManager(
        _db.attachedDatabase,
        _db.reservationsTable,
      );
  $$OrdersTableTableTableManager get ordersTable =>
      $$OrdersTableTableTableManager(_db.attachedDatabase, _db.ordersTable);
  $$InvoicesTableTableTableManager get invoicesTable =>
      $$InvoicesTableTableTableManager(_db.attachedDatabase, _db.invoicesTable);
  $$InvoiceItemsTableTableTableManager get invoiceItemsTable =>
      $$InvoiceItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.invoiceItemsTable,
      );
  $$PaymentTransactionsTableTableTableManager get paymentTransactionsTable =>
      $$PaymentTransactionsTableTableTableManager(
        _db.attachedDatabase,
        _db.paymentTransactionsTable,
      );
}
