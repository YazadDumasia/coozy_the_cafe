import '../../domain/entities/menu_item.dart';
import '../../domain/repositories/menu_item_repository.dart';
import '../datasources/menu_item_local_data_source.dart';
import '../models/menu_item_model.dart';

class MenuItemRepositoryImpl implements MenuItemRepository {
  final MenuItemLocalDataSource localDataSource;

  MenuItemRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MenuItem>> getMenuItems() async {
    final items = await localDataSource.getMenuItems();
    return items;
  }

  @override
  Future<List<MenuItem>> getMenuItemsByCategory(int categoryId) async {
    final items = await localDataSource.getMenuItemsByCategory(categoryId);
    return items;
  }

  @override
  Future<List<MenuItem>> getMenuItemsBySubcategory(int subcategoryId) async {
    final items = await localDataSource.getMenuItemsBySubcategory(
      subcategoryId,
    );
    return items;
  }

  @override
  Future<MenuItem?> getMenuItemById(int id) async {
    final item = await localDataSource.getMenuItemById(id);
    return item;
  }

  @override
  Future<int> addMenuItem(MenuItem item) async {
    final model = MenuItemModel.fromEntity(item);
    return await localDataSource.insertMenuItem(model);
  }

  @override
  Future<bool> updateMenuItem(MenuItem item) async {
    final model = MenuItemModel.fromEntity(item);
    return await localDataSource.updateMenuItem(model);
  }

  @override
  Future<bool> deleteMenuItem(int id) async {
    return await localDataSource.deleteMenuItem(id);
  }
}
