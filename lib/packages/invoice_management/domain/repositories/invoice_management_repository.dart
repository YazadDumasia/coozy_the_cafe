import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../entities/invoice_management_entity.dart';

abstract class InvoiceManagementRepository {
  Future<Either<Failure, PaginatedInvoicesEntity>> getPaginatedInvoices({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  });

  Future<Either<Failure, InvoiceDetailsEntity>> getInvoiceDetails(int invoiceId);

  Future<Either<Failure, bool>> updateInvoice({
    required InvoiceEntity invoice,
    required List<InvoiceItemEntity> items,
  });

  Future<Either<Failure, bool>> deleteInvoice(int invoiceId);

  Future<Either<Failure, List<PaymentMode>>> getPaymentModes();
}
