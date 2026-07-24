import '../entities/menu_category.dart';
import '../repositories/menu_category_repository.dart';

class GetMenuCategoriesUseCase {
  final MenuCategoryRepository repository;

  GetMenuCategoriesUseCase(this.repository);

  Future<List<MenuCategory>> call() {
    return repository.getCategories();
  }
}

class AddMenuCategoryUseCase {
  final MenuCategoryRepository repository;

  AddMenuCategoryUseCase(this.repository);

  Future<int> call(MenuCategory category) {
    return repository.addCategory(category);
  }
}

class UpdateMenuCategoryUseCase {
  final MenuCategoryRepository repository;

  UpdateMenuCategoryUseCase(this.repository);

  Future<bool> call(MenuCategory category) {
    return repository.updateCategory(category);
  }
}

class DeleteMenuCategoryUseCase {
  final MenuCategoryRepository repository;

  DeleteMenuCategoryUseCase(this.repository);

  Future<bool> call(int id) {
    return repository.deleteCategory(id);
  }
}

class UpdateMenuCategoryPositionsUseCase {
  final MenuCategoryRepository repository;

  UpdateMenuCategoryPositionsUseCase(this.repository);

  Future<void> call(List<MenuCategory> categories) {
    return repository.updateCategoryPositions(categories);
  }
}
