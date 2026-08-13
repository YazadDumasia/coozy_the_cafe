import 'package:go_router/go_router.dart';
import '../pages/waiter_order_placement_screen.dart';

class WaiterOrderPlacementRoutes {
  static const String waiterOrderPlacementRoute = '/waiter-order-placement';

  static final List<RouteBase> routes = [
    GoRoute(
      path: waiterOrderPlacementRoute,
      name: 'waiter-order-placement',
      builder: (context, state) => const WaiterOrderPlacementScreen(),
    ),
  ];
}
