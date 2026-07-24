import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../pages/inventory_list_screen.dart';
import '../pages/add_edit_inventory_screen.dart';
import '../pages/inventory_picker_page.dart';
import '../bloc/inventory_picker_bloc.dart';
import '../bloc/inventory_picker_event.dart';
import '../../domain/entities/inventory_item.dart';

class InventoryRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.inventoryListScreenRoute,
      builder: (context, state) => BlocProvider<InventoryBloc>(
        create: (context) =>
            GetIt.instance<InventoryBloc>()..add(LoadInventoryItems()),
        child: const InventoryListScreen(),
      ),
      routes: [
        GoRoute(
          path: AppRoutePath.addNewInventoryScreenRoute,
          builder: (context, state) => BlocProvider<InventoryBloc>.value(
            value: GetIt.instance<InventoryBloc>(),
            child: const AddEditInventoryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutePath.updateInventoryScreenRoute,
          builder: (context, state) {
            final item = state.extra as InventoryItem?;
            return BlocProvider<InventoryBloc>.value(
              value: GetIt.instance<InventoryBloc>(),
              child: AddEditInventoryScreen(item: item),
            );
          },
        ),
        GoRoute(
          path: AppRoutePath.inventoryPickerPageRoute,
          builder: (context, state) {
            return BlocProvider<InventoryPickerBloc>(
              create: (context) =>
                  GetIt.instance<InventoryPickerBloc>()
                    ..add(const LoadInventoryPickerItems(isRefresh: true)),
              child: const InventoryPickerPage(),
            );
          },
        ),
      ],
    ),
  ];
}
