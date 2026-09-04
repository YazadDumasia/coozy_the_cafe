import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/navigation/auth_routes.dart';
import '../../home_page/presentation/navigation/home_routes.dart';
import '../../shared/coozy_shared.dart' as shared;
import '../../table_management/presentation/navigation/table_routes.dart';
import '../../menu_category/presentation/navigation/menu_category_routes.dart';
import '../../menu_subcategory/presentation/navigation/menu_subcategory_routes.dart';
import '../../menu_item/presentation/navigation/menu_item_routes.dart';
import '../../inventory/presentation/navigation/inventory_routes.dart';
import '../../purchase/presentation/navigation/purchase_routes.dart';
import '../../customer/presentation/navigation/customer_routes.dart';
import '../../recipes/presentation/navigation/recipes_routes.dart';
import '../../reservation/presentation/navigation/reservation_routes.dart';
import '../../staff_management/presentation/navigation/staff_routes.dart';
import '../../settings/presentation/navigation/settings_routes.dart';
import '../../waiter_order_placement/presentation/navigation/waiter_order_placement_routes.dart';
import '../../kitchen_management/presentation/navigation/kitchen_routes.dart';
import '../../checkout/presentation/navigation/checkout_routes.dart';
import '../../order_management/presentation/navigation/order_management_routes.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppWebTitleObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateTitle(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _updateTitle(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _updateTitle(previousRoute);
  }

  void _updateTitle(Route<dynamic> route) {
    final routeName = route.settings.name;
    final title = AppRouteName.getTitleForRouteName(routeName);
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(label: title, primaryColor: 0xFF000000),
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutePath.splashRoute,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    observers: [AppWebTitleObserver()],
    routes: [
      ...AuthRoutes.routes,
      ...HomeRoutes.routes,
      ...TableRoutes.routes,
      ...MenuCategoryRoutes.routes,
      ...MenuSubCategoryRoutes.routes,
      ...MenuItemRoutes.routes,
      ...InventoryRoutes.routes,
      ...PurchaseRoutes.routes,
      ...CustomerRoutes.routes,
      ...RecipesRoutes.routes,
      ...ReservationRoutes.routes,
      ...StaffRoutes.routes,
      ...SettingsRoutes.routes,
      ...WaiterOrderPlacementRoutes.routes,
      ...KitchenRoutes.routes,
      ...CheckoutRoutes.routes,
      ...OrderManagementRoutes.routes,
    ],



    errorBuilder: (context, state) => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.commonPageNotFound,
                track: shared.TrackConstants.commonTrack,
              ) ??
              'Page Not Found',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No route defined for ${state.uri.path}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => router.go(AppRoutePath.splashRoute),
              child: Text('Go to Splash'),
            ),
          ],
        ),
      ),
    ),
  );
}
