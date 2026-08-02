import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'data/datasources/menu_subcategory_local_data_source.dart';
import 'data/repositories/menu_subcategory_repository_impl.dart';
import 'domain/repositories/menu_subcategory_repository.dart';
import 'domain/usecases/menu_subcategory_usecases.dart';
import 'presentation/bloc/menu_subcategory_bloc.dart';
import 'presentation/bloc/add_menu_subcategory_cubit/add_new_menu_subcategory_cubit.dart';

void registerMenuSubcategoryDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<MenuSubcategoryLocalDataSource>(
    () => MenuSubcategoryLocalDataSourceImpl(database: sl<CoozyDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<MenuSubcategoryRepository>(
    () => MenuSubcategoryRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMenuSubcategoriesUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuSubcategoriesByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => AddMenuSubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMenuSubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMenuSubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMenuSubcategoryPositionsUseCase(sl()));

  // Cubits & Blocs
  sl.registerFactory(
    () => MenuSubcategoryBloc(
      getSubcategoriesUseCase: sl(),
      getSubcategoriesByCategoryUseCase: sl(),
      addSubcategoryUseCase: sl(),
      updateSubcategoryUseCase: sl(),
      deleteSubcategoryUseCase: sl(),
      updateSubcategoryPositionsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AddNewMenuSubcategoryCubit(
      addMenuSubcategoryUseCase: sl(),
      getSubcategoriesByCategoryUseCase: sl(),
      addMenuCategoryUseCase: sl(),
    ),
  );
}
