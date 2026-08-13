import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';

import '../bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';
import '../bloc/add_menu_sub_categories_bloc/add_menu_categories_cubit.dart';
import '../bloc/edit_menu_category_bloc/edit_menu_category_bloc.dart';

import '../pages/menu_category_full_list_screen.dart';
import '../pages/add_menu_category_screen/add_new_menu_category_screen.dart';
import '../pages/edit_menu_category/edit_menu_category_screen.dart';

import '../../domain/entities/menu_category.dart';

class MenuCategoryRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.menuCategoryFullListRoute,
      name: AppRouteName.menuCategoryList,
      builder: (context, state) => BlocProvider<MenuCategoryFullListCubit>(
        create: (context) =>
            GetIt.instance<MenuCategoryFullListCubit>()..loadData(),
        child: const MenuCategoryFullListScreen(),
      ),
      routes: [
        GoRoute(
          path: AppRoutePath.addNewMenuCategoryScreenRoute,
          name: AppRouteName.menuCategoryAdd,
          builder: (context, state) => BlocProvider<AddMenuCategoryCubit>(
            create: (context) => GetIt.instance<AddMenuCategoryCubit>(),
            child: const AddNewMenuCategoryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.updateMenuCategoryScreenRoute,
          name: AppRouteName.menuCategoryUpdate,
          builder: (context, state) => BlocProvider<EditMenuCategoryBloc>(
            create: (context) {
              return GetIt.instance<EditMenuCategoryBloc>();
            },
            child: EditMenuCategoryScreen(
              category: state.extra as MenuCategory?,
            ),
          ),
        ),
      ],
    ),
  ];
}
