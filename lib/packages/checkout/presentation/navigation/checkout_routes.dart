import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../bloc/checkout_bloc.dart';
import '../pages/checkout/checkout_screen.dart';

class CheckoutRoutes {
  static const String checkoutRoute = '/checkout';

  static final List<RouteBase> routes = [
    GoRoute(
      path: checkoutRoute,
      name: 'checkout',
      builder: (context, state) {
        String orderId = '';
        if (state.extra is String) {
          orderId = state.extra as String;
        } else if (state.extra is int) {
          orderId = (state.extra as int).toString();
        } else if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          orderId = map['orderId']?.toString() ?? '';
        } else if (state.uri.queryParameters.containsKey('orderId')) {
          orderId = state.uri.queryParameters['orderId'] ?? '';
        }

        return BlocProvider<CheckoutBloc>(
          create: (_) => sl<CheckoutBloc>(),
          child: CheckoutScreen(orderId: orderId),
        );
      },
    ),
  ];
}
