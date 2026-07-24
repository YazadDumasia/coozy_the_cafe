import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'data/datasources/menu_category_local_data_source.dart';
import 'data/repositories/menu_category_repository_impl.dart';
import 'domain/repositories/menu_category_repository.dart';
import 'domain/usecases/menu_category_usecases.dart';
import 'presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import 'presentation/bloc/add_menu_sub_categories_bloc/add_menu_categories_cubit.dart';
import 'presentation/bloc/edit_menu_category_bloc/edit_menu_category_bloc.dart';

void registerMenuCategoryDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<MenuCategoryLocalDataSource>(
    () => MenuCategoryLocalDataSourceImpl(database: sl<CoozyDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<MenuCategoryRepository>(
    () => MenuCategoryRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMenuCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddMenuCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMenuCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMenuCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMenuCategoryPositionsUseCase(sl()));

  // Blocs / Cubits
  sl.registerLazySingleton(
    () => MenuCategoryFullListCubit(
      getCategoriesUseCase: sl(),
      getSubcategoriesUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
      deleteSubcategoryUseCase: sl(),
      updateSubcategoryUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AddMenuCategoryCubit(
      addMenuCategoryUseCase: sl(),
      addMenuSubcategoryUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => EditMenuCategoryBloc(
      updateMenuCategoryUseCase: sl(),
      getMenuSubcategoriesByCategoryUseCase: sl(),
      addMenuSubcategoryUseCase: sl(),
      deleteMenuSubcategoryUseCase: sl(),
    ),
  );
}
