import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

abstract class InvoiceManagementRemoteDataSource {
  Future<List<Invoice>> getPaginatedInvoices({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  });

  Future<int> getInvoicesCount({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  });

  Future<Invoice?> getInvoiceById(int invoiceId);

  Future<Invoice?> getInvoiceByHashId(String hashId);

  Future<Invoice?> getInvoiceByOrderId(int orderId);

  Future<Invoice?> getInvoiceByOrderHashId(String orderHashId);

  Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(int invoiceId);

  Future<List<PaymentTransaction>> getPaymentTransactionsByInvoiceId(int invoiceId);

  Future<bool> updateInvoice(
    int id,
    InvoicesTableCompanion invoice, {
    List<InvoiceItemsTableCompanion>? items,
  });

  Future<int> deleteInvoice(int id);

  Future<List<PaymentMode>> getPaymentModes();

  Future<Order?> getOrderById(int orderId);
}

class InvoiceManagementRemoteDataSourceImpl
    implements InvoiceManagementRemoteDataSource {
  final InvoicesDao invoicesDao;

  InvoiceManagementRemoteDataSourceImpl(this.invoicesDao);

  @override
  Future<List<Invoice>> getPaginatedInvoices({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    if (startDate != null && endDate != null) {
      final startIso = startDate.toIso8601String();
      final endIso = endDate.toIso8601String();
      final offset = (pageNo - 1) * limit;
      return invoicesDao.getInvoicesByDateRange(
        startIso,
        endIso,
        limit: limit,
        offset: offset,
      );
    } else {
      return invoicesDao.getInvoicesPaginated(
        limit: limit,
        pageNo: pageNo,
        search: searchQuery,
      );
    }
  }

  @override
  Future<int> getInvoicesCount({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) async {
    if (startDate != null && endDate != null) {
      return invoicesDao.getInvoicesCountByDateRange(
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      );
    } else {
      return invoicesDao.getInvoicesCount(search: searchQuery);
    }
  }

  @override
  Future<Invoice?> getInvoiceById(int invoiceId) {
    return invoicesDao.getInvoiceById(invoiceId);
  }

  @override
  Future<Invoice?> getInvoiceByHashId(String hashId) {
    return invoicesDao.getInvoiceByHashId(hashId);
  }

  @override
  Future<Invoice?> getInvoiceByOrderId(int orderId) {
    return invoicesDao.getInvoiceByOrderId(orderId);
  }

  @override
  Future<Invoice?> getInvoiceByOrderHashId(String orderHashId) {
    return invoicesDao.getInvoiceByOrderHashId(orderHashId);
  }

  @override
  Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(int invoiceId) {
    return invoicesDao.getInvoiceItemsByInvoiceId(invoiceId);
  }

  @override
  Future<List<PaymentTransaction>> getPaymentTransactionsByInvoiceId(
    int invoiceId,
  ) {
    return invoicesDao.getPaymentTransactionsByInvoiceId(invoiceId);
  }

  @override
  Future<bool> updateInvoice(
    int id,
    InvoicesTableCompanion invoice, {
    List<InvoiceItemsTableCompanion>? items,
  }) {
    return invoicesDao.updateInvoice(id, invoice, items: items);
  }

  @override
  Future<int> deleteInvoice(int id) {
    return invoicesDao.deleteInvoice(id);
  }

  @override
  Future<List<PaymentMode>> getPaymentModes() {
    return invoicesDao.getPaymentModes();
  }

  @override
  Future<Order?> getOrderById(int orderId) async {
    final orderWithItems = await invoicesDao.attachedDatabase.ordersDao.getOrderInfo(orderId);
    return orderWithItems?.order;
  }
}
