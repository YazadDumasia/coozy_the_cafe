import '../entities/menu_item.dart';
import '../repositories/menu_item_repository.dart';

class GetMenuItemsUseCase {
  final MenuItemRepository repository;
  GetMenuItemsUseCase(this.repository);

  Future<List<MenuItem>> call() async {
    return await repository.getMenuItems();
  }
}

class GetMenuItemsByCategoryUseCase {
  final MenuItemRepository repository;
  GetMenuItemsByCategoryUseCase(this.repository);

  Future<List<MenuItem>> call(int categoryId) async {
    return await repository.getMenuItemsByCategory(categoryId);
  }
}

class GetMenuItemsBySubcategoryUseCase {
  final MenuItemRepository repository;
  GetMenuItemsBySubcategoryUseCase(this.repository);

  Future<List<MenuItem>> call(int subcategoryId) async {
    return await repository.getMenuItemsBySubcategory(subcategoryId);
  }
}

class AddMenuItemUseCase {
  final MenuItemRepository repository;
  AddMenuItemUseCase(this.repository);

  Future<int> call(MenuItem item) async {
    return await repository.addMenuItem(item);
  }
}

class UpdateMenuItemUseCase {
  final MenuItemRepository repository;
  UpdateMenuItemUseCase(this.repository);

  Future<bool> call(MenuItem item) async {
    return await repository.updateMenuItem(item);
  }
}

class DeleteMenuItemUseCase {
  final MenuItemRepository repository;
  DeleteMenuItemUseCase(this.repository);

  Future<bool> call(int id) async {
    return await repository.deleteMenuItem(id);
  }
}
