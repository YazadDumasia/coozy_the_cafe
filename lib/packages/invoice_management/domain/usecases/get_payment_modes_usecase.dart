import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/database/coozy_database.dart';
import '../repositories/invoice_management_repository.dart';

class GetPaymentModesUseCase {
  final InvoiceManagementRepository repository;

  GetPaymentModesUseCase(this.repository);

  Future<Either<Failure, List<PaymentMode>>> call() {
    return repository.getPaymentModes();
  }
}
