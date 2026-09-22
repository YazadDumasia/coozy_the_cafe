import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import '../bloc/reports_cubit/reports_cubit.dart';
import '../pages/reports_main/reports_main_page.dart';

class ReportsRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.reportScreenRoute,
      name: AppRouteName.reportScreen,
      builder: (context, state) => BlocProvider<ReportsCubit>(
        create: (_) => GetIt.instance<ReportsCubit>(),
        child: const ReportsMainPage(),
      ),
    ),
  ];
}
