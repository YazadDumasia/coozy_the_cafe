import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../core/navigation/app_routes.dart';
import '../pages/purchase_list/purchase_list_screen.dart';
import '../pages/add_purchase/add_purchase_screen.dart';
import '../bloc/purchase_list_bloc.dart';
import '../bloc/item_purchase_bloc.dart';
import '../../../inventory/domain/entities/inventory_item.dart';

class PurchaseRoutes {
  static final List<GoRoute> routes = [
    GoRoute(
      path: AppRoutePath.purchaseListScreenRoute,
      name: AppRouteName.purchaseList,
      builder: (context, state) {
        return BlocProvider<PurchaseListBloc>(
          create: (context) =>
              GetIt.instance<PurchaseListBloc>()
                ..add(const LoadPurchases(isRefresh: true)),
          child: const PurchaseListScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.addPurchaseScreenRoute,
      name: AppRouteName.addPurchase,
      builder: (context, state) {
        final item = state.extra as InventoryItem;
        return BlocProvider<ItemPurchaseBloc>(
          create: (context) => GetIt.instance<ItemPurchaseBloc>(),
          child: AddPurchaseScreen(item: item),
        );
      },
    ),
  ];
}
