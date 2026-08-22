import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:dartz/dartz.dart';
import '../entities/menu_catalog_data.dart';
import '../repositories/waiter_order_placement_repository.dart';

class GetActiveMenuCatalogUseCase {
  final WaiterOrderPlacementRepository repository;

  GetActiveMenuCatalogUseCase(this.repository);

  Future<Either<Failure, MenuCatalogData>> call() async {
    return await repository.getActiveMenuCatalog();
  }
}
