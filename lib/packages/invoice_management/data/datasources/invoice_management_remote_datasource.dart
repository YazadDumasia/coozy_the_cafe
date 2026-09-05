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

  Future<List<InvoiceItem>> getInvoiceItemsByInvoiceId(int invoiceId);

  Future<List<PaymentTransaction>> getPaymentTransactionsByInvoiceId(int invoiceId);

  Future<bool> updateInvoice(int id, InvoicesTableCompanion invoice);

  Future<int> deleteInvoice(int id);

  Future<List<PaymentMode>> getPaymentModes();
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
  Future<bool> updateInvoice(int id, InvoicesTableCompanion invoice) {
    return invoicesDao.updateInvoice(id, invoice);
  }

  @override
  Future<int> deleteInvoice(int id) {
    return invoicesDao.deleteInvoice(id);
  }

  @override
  Future<List<PaymentMode>> getPaymentModes() {
    return invoicesDao.getPaymentModes();
  }
}
