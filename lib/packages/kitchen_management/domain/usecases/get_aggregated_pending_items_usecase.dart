import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../entities/kitchen_aggregated_item_entity.dart';
import '../repositories/kitchen_repository.dart';

class GetAggregatedPendingItemsUseCase {
  final KitchenRepository repository;

  GetAggregatedPendingItemsUseCase(this.repository);

  Future<Either<Failure, List<KitchenAggregatedItemEntity>>> call() {
    return repository.getAggregatedPendingItems();
  }
}
