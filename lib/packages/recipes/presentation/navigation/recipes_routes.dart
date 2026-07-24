import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/recipes/domain/entities/recipe.dart';
import '../bloc/recipes_full_list_cubit.dart';
import '../bloc/recipes_bookmark_list_cubit.dart';
import '../pages/recipes_list_screen.dart';
import '../pages/recipes_bookmark_list_screen.dart';
import '../pages/recipes_info_screen.dart';
import '../pages/add_edit_recipe_screen.dart';

class RecipesRoutes {
  static List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutePath.recipesListScreenRoute,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<RecipesFullListCubit>(
                create: (context) => GetIt.instance<RecipesFullListCubit>(),
              ),
              BlocProvider<RecipesBookmarkListCubit>(
                create: (context) => GetIt.instance<RecipesBookmarkListCubit>(),
              ),
            ],
            child: const RecipesListScreen(),
          ),
          routes: [
            GoRoute(
              path: AppRoutePath.recipesBookmarkListScreenRoute,
              builder: (context, state) => MultiBlocProvider(
                providers: [
                  BlocProvider<RecipesFullListCubit>(
                    create: (context) => GetIt.instance<RecipesFullListCubit>(),
                  ),
                  BlocProvider<RecipesBookmarkListCubit>(
                    create: (context) => GetIt.instance<RecipesBookmarkListCubit>(),
                  ),
                ],
                child: const RecipesBookmarkListScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutePath.recipesInfoScreenRoute,
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                final model = extra['model'] as Recipe;
                final index = extra['index'] as int?;
                return MultiBlocProvider(
                  providers: [
                    BlocProvider<RecipesFullListCubit>(
                      create: (context) => GetIt.instance<RecipesFullListCubit>(),
                    ),
                    BlocProvider<RecipesBookmarkListCubit>(
                      create: (context) => GetIt.instance<RecipesBookmarkListCubit>(),
                    ),
                  ],
                  child: RecipesInfoScreen(
                    model: model,
                    currentIndex: index,
                  ),
                );
              },
            ),
            GoRoute(
              path: AppRoutePath.recipesAddOrEditScreenRoute,
              builder: (context, state) {
                final model = state.extra as Recipe?;
                return BlocProvider<RecipesFullListCubit>(
                  create: (context) => GetIt.instance<RecipesFullListCubit>(),
                  child: AddEditRecipeScreen(recipe: model),
                );
              },
            ),
          ],
        ),
      ];
}
