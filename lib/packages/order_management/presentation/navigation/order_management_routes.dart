import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../bloc/order_management_bloc.dart';
import '../pages/order_list/order_list_screen.dart';
import '../pages/order_info/order_info_screen.dart';
import '../../domain/entities/order_management_entity.dart';

class OrderManagementRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: AppRoutePath.orderListScreenRoute,
      name: AppRouteName.orders,
      builder: (context, state) => BlocProvider<OrderManagementBloc>(
        create: (_) => sl<OrderManagementBloc>()
          ..add(const LoadOrdersEvent(isRefresh: true)),
        child: const OrderListScreen(),
      ),
      routes: [
        GoRoute(
          path: AppRoutePath.orderInfoScreenRoute,
          name: 'order-info',
          builder: (context, state) {

            final idStr = state.pathParameters['id'];
            final orderId = int.tryParse(idStr ?? '') ?? 0;
            final extraOrder = state.extra is OrderManagementEntity
                ? state.extra as OrderManagementEntity
                : null;
            return BlocProvider<OrderManagementBloc>(
              create: (_) => sl<OrderManagementBloc>(),
              child: OrderInfoScreen(
                orderId: orderId,
                initialOrder: extraOrder,
              ),
            );
          },
        ),
      ],
    ),
  ];
}
