import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../bloc/menu_item_bloc.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';

import '../../../menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import '../pages/menu_item_list/menu_item_list_screen.dart';
import '../pages/add_edit_menu_item/add_edit_menu_item_screen.dart';
import '../pages/menu_item_detail/menu_item_detail_screen.dart';
import '../../domain/entities/menu_item.dart';

class MenuItemRoutes {
  static List<RouteBase> get routes => [
    ShellRoute(
      builder: (context, state, child) => MultiBlocProvider(
        providers: [
          BlocProvider<MenuItemBloc>(
            create: (context) =>
                GetIt.instance<MenuItemBloc>()..add(const LoadMenuItems()),
          ),
          BlocProvider<MenuCategoryFullListCubit>(
            create: (context) =>
                GetIt.instance<MenuCategoryFullListCubit>()..loadData(),
          ),
          BlocProvider<MenuSubcategoryBloc>(
            create: (context) =>
                GetIt.instance<MenuSubcategoryBloc>()
                  ..add(const LoadMenuSubcategories()),
          ),
        ],
        child: child,
      ),
      routes: [
        GoRoute(
          path: AppRoutePath.menuItemFullListScreenRoute,
          name: AppRouteName.menuItemList,
          builder: (context, state) => const MenuItemListScreen(),
          routes: [
            GoRoute(
              path: AppRoutePath.addNewMenuItemScreenRoute,
              name: AppRouteName.menuItemAdd,
              builder: (context, state) => const AddEditMenuItemScreen(),
            ),
            GoRoute(
              path: AppRoutePath.updateMenuItemScreenRoute,
              name: AppRouteName.menuItemUpdate,
              builder: (context, state) {
                final item = state.extra as MenuItem?;
                return AddEditMenuItemScreen(item: item);
              },
            ),
            GoRoute(
              path: AppRoutePath.detailMenuItemScreenRoute,
              name: AppRouteName.menuItemDetail,
              builder: (context, state) {
                final idStr = state.pathParameters['id'];
                final itemId = int.tryParse(idStr ?? '') ?? 0;
                return MenuItemDetailScreen(itemId: itemId);
              },
            ),
          ],
        ),
      ],
    ),
  ];
}
