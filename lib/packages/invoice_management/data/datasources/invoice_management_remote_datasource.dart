import 'package:coozy_the_cafe/packages/database/coozy_database.dart';

abstract class InvoiceManagementRemoteDataSource {
  Future<List<Invoice>> getPaginatedInvoices({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    List<String>? paymentMethods,
  });

  Future<int> getInvoicesCount({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    List<String>? paymentMethods,
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
    List<String>? paymentMethods,
  }) async {
    return invoicesDao.getInvoicesWithFilters(
      limit: limit,
      pageNo: pageNo,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      paymentMethods: paymentMethods,
    );
  }

  @override
  Future<int> getInvoicesCount({
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    List<String>? paymentMethods,
  }) async {
    return invoicesDao.getInvoicesCountWithFilters(
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      paymentMethods: paymentMethods,
    );
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
