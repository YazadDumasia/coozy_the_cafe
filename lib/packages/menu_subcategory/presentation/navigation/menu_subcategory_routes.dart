import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';

import '../bloc/menu_subcategory_bloc.dart';
import '../bloc/add_menu_subcategory_cubit/add_new_menu_subcategory_cubit.dart';
import '../pages/menu_subcategory_full_list/menu_subcategory_full_list_screen.dart';
import '../pages/add_menu_subcategory_screen/add_new_menu_subcategory_screen.dart';

class MenuSubCategoryRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.menuSubCategoryFullListRoute,
      name: AppRouteName.menuSubCategoryList,
      builder: (context, state) => BlocProvider<MenuSubcategoryBloc>(
        create: (context) =>
            GetIt.instance<MenuSubcategoryBloc>()..add(LoadMenuSubcategories()),
        child: const MenuSubcategoryFullListScreen(),
      ),
      routes: [
        GoRoute(
          path: AppRoutePath.addNewMenuSubCategoryScreenRoute,
          name: AppRouteName.menuSubCategoryAdd,
          builder: (context, state) {
            final String? catIdStr = state.uri.queryParameters['categoryId'];
            final int? catId = catIdStr != null
                ? int.tryParse(catIdStr)
                : (state.extra is int ? state.extra as int : null);
            return BlocProvider<AddNewMenuSubcategoryCubit>(
              create: (context) => GetIt.instance<AddNewMenuSubcategoryCubit>(),
              child: AddNewMenuSubcategoryScreen(initialCategoryId: catId),
            );
          },
        ),
      ],
    ),
  ];
}
