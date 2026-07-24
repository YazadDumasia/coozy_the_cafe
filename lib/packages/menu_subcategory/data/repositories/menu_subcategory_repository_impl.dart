import '../../domain/entities/menu_subcategory.dart';
import '../../domain/repositories/menu_subcategory_repository.dart';
import '../datasources/menu_subcategory_local_data_source.dart';
import '../models/menu_subcategory_model.dart';

class MenuSubcategoryRepositoryImpl implements MenuSubcategoryRepository {
  final MenuSubcategoryLocalDataSource localDataSource;

  MenuSubcategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MenuSubcategory>> getSubcategories() async {
    return await localDataSource.getSubcategories();
  }

  @override
  Future<List<MenuSubcategory>> getSubcategoriesByCategoryId(
    int categoryId,
  ) async {
    return await localDataSource.getSubcategoriesByCategoryId(categoryId);
  }

  @override
  Future<int> addSubcategory(MenuSubcategory subcategory) async {
    final model = MenuSubcategoryModel.fromEntity(subcategory);
    return await localDataSource.insertSubcategory(model);
  }

  @override
  Future<bool> updateSubcategory(MenuSubcategory subcategory) async {
    final model = MenuSubcategoryModel.fromEntity(subcategory);
    return await localDataSource.updateSubcategory(model);
  }

  @override
  Future<bool> deleteSubcategory(int id) async {
    return await localDataSource.deleteSubcategory(id);
  }

  @override
  Future<void> updateSubcategoryPositions(
    List<MenuSubcategory> subcategories,
  ) async {
    final models = subcategories
        .map((s) => MenuSubcategoryModel.fromEntity(s))
        .toList();
    await localDataSource.updatePositions(models);
  }
}
