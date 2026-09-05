import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../repositories/invoice_management_repository.dart';

class DeleteInvoiceUseCase {
  final InvoiceManagementRepository repository;

  DeleteInvoiceUseCase(this.repository);

  Future<Either<Failure, bool>> call(int invoiceId) {
    return repository.deleteInvoice(invoiceId);
  }
}
