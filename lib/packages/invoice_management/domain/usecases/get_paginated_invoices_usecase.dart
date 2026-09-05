import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../entities/invoice_management_entity.dart';
import '../repositories/invoice_management_repository.dart';

class GetPaginatedInvoicesParams {
  final int limit;
  final int pageNo;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const GetPaginatedInvoicesParams({
    required this.limit,
    required this.pageNo,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });
}

class GetPaginatedInvoicesUseCase {
  final InvoiceManagementRepository repository;

  GetPaginatedInvoicesUseCase(this.repository);

  Future<Either<Failure, PaginatedInvoicesEntity>> call(
    GetPaginatedInvoicesParams params,
  ) {
    return repository.getPaginatedInvoices(
      limit: params.limit,
      pageNo: params.pageNo,
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
    );
  }
}
