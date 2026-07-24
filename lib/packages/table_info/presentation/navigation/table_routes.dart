import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../cubit/table_cubit.dart';
import '../pages/table_screen.dart';

class TableRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.tableInfoScreenRoute,
      builder: (context, state) => BlocProvider<TableCubit>(
        create: (context) => GetIt.instance<TableCubit>()..loadTables(),
        child: const TableScreen(),
      ),
    ),
  ];
}
