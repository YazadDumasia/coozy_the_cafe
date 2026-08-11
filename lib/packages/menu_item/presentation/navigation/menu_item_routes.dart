import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../bloc/menu_item_bloc.dart';
import '../bloc/menu_item_event.dart';
import 'package:coozy_the_cafe/packages/menu_category/presentation/bloc/menu_category_full_list_cubit/menu_category_full_list_cubit.dart';

import '../../../menu_subcategory/presentation/bloc/menu_subcategory_bloc.dart';
import '../../../menu_subcategory/presentation/bloc/menu_subcategory_event.dart';
import '../pages/menu_item_list_screen.dart';
import '../pages/add_edit_menu_item_screen.dart';
import '../../domain/entities/menu_item.dart';

T? _tryRead<T extends StateStreamableSource<Object?>>(BuildContext context) {
  try {
    return context.read<T>();
  } catch (_) {
    return null;
  }
}

class MenuItemRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.menuItemFullListScreenRoute,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider<MenuItemBloc>(
            create: (context) =>
                GetIt.instance<MenuItemBloc>()..add(LoadMenuItems()),
          ),
          BlocProvider<MenuCategoryFullListCubit>(
            create: (context) =>
                GetIt.instance<MenuCategoryFullListCubit>()..loadData(),
          ),
          BlocProvider<MenuSubcategoryBloc>(
            create: (context) =>
                GetIt.instance<MenuSubcategoryBloc>()
                  ..add(LoadMenuSubcategories()),
          ),
        ],
        child: const MenuItemListScreen(),
      ),
      routes: [
        GoRoute(
          path: AppRoutePath.addNewMenuItemScreenRoute,
          builder: (context, state) {
            final parentMenuItemBloc = _tryRead<MenuItemBloc>(context);
            final parentCategoryCubit = _tryRead<MenuCategoryFullListCubit>(
              context,
            );
            final parentSubcategoryBloc = _tryRead<MenuSubcategoryBloc>(
              context,
            );

            return MultiBlocProvider(
              providers: [
                if (parentMenuItemBloc != null)
                  BlocProvider<MenuItemBloc>.value(value: parentMenuItemBloc)
                else
                  BlocProvider<MenuItemBloc>(
                    create: (_) =>
                        GetIt.instance<MenuItemBloc>()..add(LoadMenuItems()),
                  ),

                if (parentCategoryCubit != null)
                  BlocProvider<MenuCategoryFullListCubit>.value(
                    value: parentCategoryCubit..loadData(),
                  )
                else
                  BlocProvider<MenuCategoryFullListCubit>(
                    create: (_) =>
                        GetIt.instance<MenuCategoryFullListCubit>()..loadData(),
                  ),

                if (parentSubcategoryBloc != null)
                  BlocProvider<MenuSubcategoryBloc>.value(
                    value: parentSubcategoryBloc,
                  )
                else
                  BlocProvider<MenuSubcategoryBloc>(
                    create: (_) =>
                        GetIt.instance<MenuSubcategoryBloc>()
                          ..add(LoadMenuSubcategories()),
                  ),
              ],
              child: const AddEditMenuItemScreen(),
            );
          },
        ),
        GoRoute(
          path: AppRoutePath.updateMenuItemScreenRoute,
          builder: (context, state) {
            final item = state.extra as MenuItem?;
            final parentMenuItemBloc = _tryRead<MenuItemBloc>(context);
            final parentCategoryCubit = _tryRead<MenuCategoryFullListCubit>(
              context,
            );
            final parentSubcategoryBloc = _tryRead<MenuSubcategoryBloc>(
              context,
            );

            return MultiBlocProvider(
              providers: [
                if (parentMenuItemBloc != null)
                  BlocProvider<MenuItemBloc>.value(value: parentMenuItemBloc)
                else
                  BlocProvider<MenuItemBloc>(
                    create: (_) =>
                        GetIt.instance<MenuItemBloc>()..add(LoadMenuItems()),
                  ),

                if (parentCategoryCubit != null)
                  BlocProvider<MenuCategoryFullListCubit>.value(
                    value: parentCategoryCubit..loadData(),
                  )
                else
                  BlocProvider<MenuCategoryFullListCubit>(
                    create: (_) =>
                        GetIt.instance<MenuCategoryFullListCubit>()..loadData(),
                  ),

                if (parentSubcategoryBloc != null)
                  BlocProvider<MenuSubcategoryBloc>.value(
                    value: parentSubcategoryBloc,
                  )
                else
                  BlocProvider<MenuSubcategoryBloc>(
                    create: (_) =>
                        GetIt.instance<MenuSubcategoryBloc>()
                          ..add(LoadMenuSubcategories()),
                  ),
              ],
              child: AddEditMenuItemScreen(item: item),
            );
          },
        ),
      ],
    ),
  ];
}
