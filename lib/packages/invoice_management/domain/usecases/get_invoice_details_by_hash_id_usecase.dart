import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/invoice_management_entity.dart';
import '../repositories/invoice_management_repository.dart';

class GetInvoiceDetailsByHashIdUseCase {
  final InvoiceManagementRepository repository;

  GetInvoiceDetailsByHashIdUseCase(this.repository);

  Future<Either<Failure, InvoiceDetailsEntity>> call(String hashId) {
    return repository.getInvoiceDetailsByHashId(hashId);
  }
}
