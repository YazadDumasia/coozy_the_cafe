import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../cubit/home_cubit.dart';
import '../pages/home_screen.dart';

class HomeRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.homeRoute,
      builder: (context, state) => BlocProvider<HomeCubit>(
        create: (context) => GetIt.instance<HomeCubit>()..fetchHomeData(),
        child: const HomeScreen(),
      ),
    ),
  ];
}
