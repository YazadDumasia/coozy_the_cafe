// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_dao.dart';

// ignore_for_file: type=lint
mixin _$ReportsDaoMixin on DatabaseAccessor<CoozyDatabase> {
  $TableInfoTableTable get tableInfoTable => attachedDatabase.tableInfoTable;
  $CustomersTableTable get customersTable => attachedDatabase.customersTable;
  $ReservationsTableTable get reservationsTable =>
      attachedDatabase.reservationsTable;
  $OrdersTableTable get ordersTable => attachedDatabase.ordersTable;
  $PaymentModesTableTable get paymentModesTable =>
      attachedDatabase.paymentModesTable;
  $InvoicesTableTable get invoicesTable => attachedDatabase.invoicesTable;
  $InvoiceItemsTableTable get invoiceItemsTable =>
      attachedDatabase.invoiceItemsTable;
  $PaymentTransactionsTableTable get paymentTransactionsTable =>
      attachedDatabase.paymentTransactionsTable;
  ReportsDaoManager get managers => ReportsDaoManager(this);
}

class ReportsDaoManager {
  final _$ReportsDaoMixin _db;
  ReportsDaoManager(this._db);
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
  $$PaymentModesTableTableTableManager get paymentModesTable =>
      $$PaymentModesTableTableTableManager(
        _db.attachedDatabase,
        _db.paymentModesTable,
      );
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
