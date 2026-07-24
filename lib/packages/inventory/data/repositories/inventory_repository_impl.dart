import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_data_source.dart';
import '../models/inventory_item_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;

  InventoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    final items = await localDataSource.getInventoryItems();
    return items;
  }

  @override
  Future<List<InventoryItem>> getInventoryItemsPaged(
    int limit,
    int offset,
    String? search,
  ) async {
    final items = await localDataSource.getInventoryItemsPaged(
      limit,
      offset,
      search,
    );
    return items;
  }

  @override
  Future<InventoryItem?> getInventoryItemById(int id) async {
    return await localDataSource.getInventoryItemById(id);
  }

  @override
  Future<int> addInventoryItem(InventoryItem item) async {
    final model = InventoryItemModel.fromEntity(item);
    return await localDataSource.insertInventoryItem(model);
  }

  @override
  Future<bool> updateInventoryItem(InventoryItem item) async {
    final model = InventoryItemModel.fromEntity(item);
    return await localDataSource.updateInventoryItem(model);
  }

  @override
  Future<bool> deleteInventoryItem(int id) async {
    return await localDataSource.deleteInventoryItem(id);
  }
}
