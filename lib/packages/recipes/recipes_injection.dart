import 'package:get_it/get_it.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/repositories/recipes_repository.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/usecases/recipes_usecases.dart';
import 'package:coozy_the_cafe/packages/recipes/data/datasources/recipes_local_data_source.dart';
import 'package:coozy_the_cafe/packages/recipes/data/repositories/recipes_repository_impl.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_full_list_cubit.dart';
import 'package:coozy_the_cafe/packages/recipes/presentation/bloc/recipes_bookmark_list_cubit.dart';

void registerRecipesDependencies(GetIt sl) {
  // Blocs / Cubits
  sl.registerFactory(
    () => RecipesFullListCubit(
      initializeRecipesUseCase: sl(),
      getRecipesUseCase: sl(),
      updateRecipeUseCase: sl(),
      deleteRecipeUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => RecipesBookmarkListCubit(
      getBookmarkedRecipesUseCase: sl(),
      updateRecipeUseCase: sl(),
      deleteRecipeUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => InitializeRecipesUseCase(sl()));
  sl.registerLazySingleton(() => GetRecipesUseCase(sl()));
  sl.registerLazySingleton(() => GetBookmarkedRecipesUseCase(sl()));
  sl.registerLazySingleton(() => AddRecipeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRecipeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRecipeUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RecipesRepository>(
    () => RecipesRepositoryImpl(localDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<RecipesLocalDataSource>(
    () => RecipesLocalDataSourceImpl(database: sl()),
  );
}
