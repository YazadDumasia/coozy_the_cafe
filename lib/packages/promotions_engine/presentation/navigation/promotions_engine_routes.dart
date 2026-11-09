import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

import '../bloc/combo_bloc.dart';
import '../pages/combo_list_page/combo_list_page.dart';
import '../../domain/usecases/combo_usecases.dart';

class PromotionsEngineRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.combosScreenRoute,
      name: AppRouteName.combosList,
      builder: (context, state) => BlocProvider<ComboBloc>(
        create: (context) => GetIt.instance<ComboBloc>(),
        child: ComboListPage(
          searchUseCase: GetIt.instance<SearchMenuItemsForComboUseCase>(),
          countUseCase: GetIt.instance<GetMenuItemsCountForComboUseCase>(),
        ),
      ),
    ),
  ];
}
