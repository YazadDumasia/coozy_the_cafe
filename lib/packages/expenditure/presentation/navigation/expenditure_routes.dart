import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import '../../expenditure.dart';

class ExpenditureRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.expenditureListScreenRoute,
      name: AppRouteName.expenditureList,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: BlocProvider<CashFlowBloc>(
          create: (_) => sl<CashFlowBloc>(),
          child: const CashFlowScreen(),
        ),
      ),
    ),
  ];
}
