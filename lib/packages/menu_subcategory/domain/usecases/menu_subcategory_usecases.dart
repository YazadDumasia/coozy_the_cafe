import '../entities/menu_subcategory.dart';
import '../repositories/menu_subcategory_repository.dart';

class GetMenuSubcategoriesUseCase {
  final MenuSubcategoryRepository repository;
  GetMenuSubcategoriesUseCase(this.repository);
  Future<List<MenuSubcategory>> call() => repository.getSubcategories();
}

class GetMenuSubcategoriesByCategoryUseCase {
  final MenuSubcategoryRepository repository;
  GetMenuSubcategoriesByCategoryUseCase(this.repository);
  Future<List<MenuSubcategory>> call(int categoryId) =>
      repository.getSubcategoriesByCategoryId(categoryId);
}

class AddMenuSubcategoryUseCase {
  final MenuSubcategoryRepository repository;
  AddMenuSubcategoryUseCase(this.repository);
  Future<int> call(MenuSubcategory subcategory) =>
      repository.addSubcategory(subcategory);
}

class UpdateMenuSubcategoryUseCase {
  final MenuSubcategoryRepository repository;
  UpdateMenuSubcategoryUseCase(this.repository);
  Future<bool> call(MenuSubcategory subcategory) =>
      repository.updateSubcategory(subcategory);
}

class DeleteMenuSubcategoryUseCase {
  final MenuSubcategoryRepository repository;
  DeleteMenuSubcategoryUseCase(this.repository);
  Future<bool> call(int id) => repository.deleteSubcategory(id);
}

class UpdateMenuSubcategoryPositionsUseCase {
  final MenuSubcategoryRepository repository;
  UpdateMenuSubcategoryPositionsUseCase(this.repository);
  Future<void> call(List<MenuSubcategory> subcategories) =>
      repository.updateSubcategoryPositions(subcategories);
}
