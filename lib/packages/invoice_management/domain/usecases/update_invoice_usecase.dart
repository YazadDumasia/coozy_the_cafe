import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/invoice_management_entity.dart';
import '../repositories/invoice_management_repository.dart';

class UpdateInvoiceParams {
  final InvoiceEntity invoice;
  final List<InvoiceItemEntity> items;

  const UpdateInvoiceParams({
    required this.invoice,
    required this.items,
  });
}

class UpdateInvoiceUseCase {
  final InvoiceManagementRepository repository;

  UpdateInvoiceUseCase(this.repository);

  Future<Either<Failure, bool>> call(UpdateInvoiceParams params) {
    return repository.updateInvoice(
      invoice: params.invoice,
      items: params.items,
    );
  }
}
