import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/table_management/domain/entities/table_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/menu_item_picker_bloc.dart';
import '../pages/menu_item_picker/menu_item_picker_screen.dart';
import '../pages/waiter_order_placement_screen.dart';

class WaiterOrderPlacementRoutes {
  static const String waiterOrderPlacementRoute = '/waiter-order-placement';
  static const String menuItemPickerRoute = '/menu-item-picker';

  static final List<RouteBase> routes = [
    GoRoute(
      path: waiterOrderPlacementRoute,
      name: 'waiter-order-placement',
      builder: (context, state) => const WaiterOrderPlacementScreen(),
    ),
    GoRoute(
      path: menuItemPickerRoute,
      name: 'menu-item-picker',
      builder: (context, state) {
        TableEntity? table;
        int? tableId;
        String? tableName;
        int? orderId;

        if (state.extra is int) {
          orderId = state.extra as int;
        } else if (state.extra is TableEntity) {
          table = state.extra as TableEntity;
        } else if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          if (map['orderId'] is int) {
            orderId = map['orderId'] as int;
          }
          if (map['table'] is TableEntity) {
            table = map['table'] as TableEntity;
          }
          if (map['tableId'] is int) {
            tableId = map['tableId'] as int;
          }
          if (map['tableName'] is String) {
            tableName = map['tableName'] as String;
          }
        }

        return BlocProvider<MenuItemPickerBloc>(
          create: (_) => sl<MenuItemPickerBloc>()
            ..add(LoadMenuCatalogEvent(orderId: orderId)),
          child: MenuItemPickerScreen(
            table: table,
            tableId: tableId,
            tableName: tableName,
            orderId: orderId,
          ),
        );
      },
    ),
  ];
}
