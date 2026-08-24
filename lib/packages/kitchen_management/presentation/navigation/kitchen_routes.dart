import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/kitchen_bloc.dart';
import '../pages/kitchen_screen/kitchen_screen.dart';

class KitchenRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: AppRoutePath.kitchenScreenRoute,
      name: AppRouteName.kitchen,
      builder: (context, state) => BlocProvider<KitchenBloc>(
        create: (_) => sl<KitchenBloc>()..add(const LoadKitchenOrdersEvent()),
        child: const KitchenScreen(),
      ),
    ),
  ];
}
