import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:coozy_the_cafe/packages/core/error/failures.dart';
import 'package:coozy_the_cafe/packages/order_management/order_management.dart';

class FakeOrderManagementRepository implements OrderManagementRepository {
  @override
  Future<Either<Failure, PaginatedOrdersResult>> getPaginatedOrders({
    required int limit,
    required int pageNo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? status,
  }) async {
    return const Right(
      PaginatedOrdersResult(
        orders: [
          OrderManagementEntity(
            id: 1,
            hashId: 'hash_123',
            status: 'completed',
            totalAmount: 45.5,
          ),
        ],
        totalCount: 1,
      ),
    );
  }

  @override
  Future<Either<Failure, OrderManagementEntity?>> getOrderInfo(int orderId) async {
    return const Right(
      OrderManagementEntity(
        id: 1,
        hashId: 'hash_123',
        status: 'completed',
        totalAmount: 45.5,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    return const Right(null);
  }
}

void main() {
  late GetPaginatedOrdersUseCase useCase;
  late FakeOrderManagementRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeOrderManagementRepository();
    useCase = GetPaginatedOrdersUseCase(fakeRepository);
  });

  test('should return PaginatedOrdersResult from the repository', () async {
    final result = await useCase(
      const GetPaginatedOrdersParams(
        limit: 10,
        pageNo: 1,
      ),
    );

    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not fail'),
      (paginated) {
        expect(paginated.orders.length, 1);
        expect(paginated.orders.first.id, 1);
        expect(paginated.totalCount, 1);
      },
    );
  });
}
