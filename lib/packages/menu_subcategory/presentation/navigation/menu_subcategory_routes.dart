import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';

import '../bloc/menu_subcategory_bloc.dart';
import '../bloc/menu_subcategory_event.dart';
import '../pages/menu_subcategory_full_list_screen.dart';

class MenuSubCategoryRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.menuSubCategoryFullListRoute,
      builder: (context, state) => BlocProvider<MenuSubcategoryBloc>(
        create: (context) => GetIt.instance<MenuSubcategoryBloc>()..add(LoadMenuSubcategories()),
        child: const MenuSubcategoryFullListScreen(),
      ),
    ),
  ];
}
