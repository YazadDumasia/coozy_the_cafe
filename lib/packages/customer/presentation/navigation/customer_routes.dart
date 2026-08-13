import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/di/injection_container.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import '../bloc/customer_bloc.dart';
import '../pages/customer_list/customer_list_screen.dart';

class CustomerRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: AppRoutePath.customerListScreenRoute,
      name: AppRouteName.customerList,
      builder: (context, state) => BlocProvider<CustomerBloc>(
        create: (_) => sl<CustomerBloc>(),
        child: const CustomerListScreen(),
      ),
    ),
  ];
}
