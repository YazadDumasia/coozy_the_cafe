import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/invoice_management_entity.dart';
import '../repositories/invoice_management_repository.dart';

class GetInvoiceDetailsByOrderHashIdUseCase {
  final InvoiceManagementRepository repository;

  GetInvoiceDetailsByOrderHashIdUseCase(this.repository);

  Future<Either<Failure, InvoiceDetailsEntity>> call(String orderHashId) {
    return repository.getInvoiceDetailsByOrderHashId(orderHashId);
  }
}
