import 'package:coozy_the_cafe/packages/waiter_order_placement/presentation/navigation/waiter_order_placement_routes.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../pages/table_picker/table_picker_screen.dart';
import '../pages/table_screen/table_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../cubit/table_cubit.dart';

class TableRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.tableInfoScreenRoute,
      name: AppRouteName.tableInfoList,
      builder: (context, state) => BlocProvider<TableCubit>(
        create: (context) => GetIt.instance<TableCubit>()..loadTables(),
        child: const TableScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutePath.tablePickerScreenRoute,
      name: AppRouteName.tablePicker,
      builder: (context, state) => TablePickerScreen(
        onTableSelected: (table) {
          context.push(
            WaiterOrderPlacementRoutes.menuItemPickerRoute,
            extra: table,
          );
        },
      ),
    ),
  ];
}
