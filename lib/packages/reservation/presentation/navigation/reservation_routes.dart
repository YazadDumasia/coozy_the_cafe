import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/di/injection_container.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import '../bloc/current_reservation_cubit.dart';
import '../bloc/upcoming_reservation_bloc.dart';
import '../bloc/reservation_action_cubit.dart';
import '../pages/main_reservation_screen.dart';

class ReservationRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: AppRoutePath.reservationListScreenRoute,
      name: AppRouteName.reservationList,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider<CurrentReservationCubit>(
            create: (_) => sl<CurrentReservationCubit>(),
          ),
          BlocProvider<UpcomingReservationBloc>(
            create: (_) => sl<UpcomingReservationBloc>(),
          ),
          BlocProvider<ReservationActionCubit>(
            create: (_) => sl<ReservationActionCubit>(),
          ),
        ],
        child: const MainReservationScreen(),
      ),
    ),
  ];
}
