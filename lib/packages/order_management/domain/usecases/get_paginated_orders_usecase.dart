import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:coozy_the_cafe/packages/core/error/failures.dart';
import 'package:coozy_the_cafe/packages/core/usecases/usecase.dart';
import '../repositories/order_management_repository.dart';

class GetPaginatedOrdersParams extends Equatable {
  final int limit;
  final int pageNo;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final String? status;

  const GetPaginatedOrdersParams({
    required this.limit,
    required this.pageNo,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.status,
  });

  @override
  List<Object?> get props => [
        limit,
        pageNo,
        startDate,
        endDate,
        searchQuery,
        status,
      ];
}

class GetPaginatedOrdersUseCase
    implements UseCase<PaginatedOrdersResult, GetPaginatedOrdersParams> {
  final OrderManagementRepository repository;

  GetPaginatedOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedOrdersResult>> call(
    GetPaginatedOrdersParams params,
  ) {
    return repository.getPaginatedOrders(
      limit: params.limit,
      pageNo: params.pageNo,
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
      status: params.status,
    );
  }
}
