import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/database/src/database.dart';
import 'data/datasources/menu_item_local_data_source.dart';
import 'data/repositories/menu_item_repository_impl.dart';
import 'domain/repositories/menu_item_repository.dart';
import 'domain/usecases/menu_item_usecases.dart';
import 'presentation/bloc/menu_item_bloc.dart';

void registerMenuItemDependencies(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<MenuItemLocalDataSource>(
    () => MenuItemLocalDataSourceImpl(database: sl<CoozyDatabase>()),
  );

  // Repositories
  sl.registerLazySingleton<MenuItemRepository>(
    () => MenuItemRepositoryImpl(localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMenuItemsUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuItemsByCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuItemsBySubcategoryUseCase(sl()));
  sl.registerLazySingleton(() => AddMenuItemUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMenuItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMenuItemUseCase(sl()));

  // Bloc
  sl.registerLazySingleton(
    () => MenuItemBloc(
      getMenuItemsUseCase: sl(),
      getMenuItemsByCategoryUseCase: sl(),
      getMenuItemsBySubcategoryUseCase: sl(),
      addMenuItemUseCase: sl(),
      updateMenuItemUseCase: sl(),
      deleteMenuItemUseCase: sl(),
    ),
  );
}
