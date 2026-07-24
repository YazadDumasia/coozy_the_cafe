import '../../domain/entities/menu_category.dart';
import '../../domain/repositories/menu_category_repository.dart';
import '../datasources/menu_category_local_data_source.dart';
import '../models/menu_category_model.dart';

class MenuCategoryRepositoryImpl implements MenuCategoryRepository {
  final MenuCategoryLocalDataSource localDataSource;

  MenuCategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MenuCategory>> getCategories() async {
    return await localDataSource.getCategories();
  }

  @override
  Future<int> addCategory(MenuCategory category) async {
    final model = MenuCategoryModel.fromEntity(category);
    return await localDataSource.insertCategory(model);
  }

  @override
  Future<bool> updateCategory(MenuCategory category) async {
    final model = MenuCategoryModel.fromEntity(category);
    return await localDataSource.updateCategory(model);
  }

  @override
  Future<bool> deleteCategory(int id) async {
    return await localDataSource.deleteCategory(id);
  }

  @override
  Future<void> updateCategoryPositions(List<MenuCategory> categories) async {
    final models = categories
        .map((c) => MenuCategoryModel.fromEntity(c))
        .toList();
    await localDataSource.updatePositions(models);
  }
}
