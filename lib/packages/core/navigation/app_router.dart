import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/navigation/auth_routes.dart';
import '../../home_page/presentation/navigation/home_routes.dart';
import '../../shared/coozy_shared.dart' as shared;
import '../../table_info/presentation/navigation/table_routes.dart';
import '../../menu_category/presentation/navigation/menu_category_routes.dart';
import '../../menu_item/presentation/navigation/menu_item_routes.dart';
import '../../inventory/presentation/navigation/inventory_routes.dart';
import '../../purchase/presentation/navigation/purchase_routes.dart';
import '../../customer/presentation/navigation/customer_routes.dart';
import '../../recipes/presentation/navigation/recipes_routes.dart';
import '../../staff_management/presentation/navigation/staff_routes.dart';
import 'app_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutePath.splashRoute,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      ...AuthRoutes.routes,
      ...HomeRoutes.routes,
      ...TableRoutes.routes,
      ...MenuCategoryRoutes.routes,
      ...MenuItemRoutes.routes,
      ...InventoryRoutes.routes,
      ...PurchaseRoutes.routes,
      ...CustomerRoutes.routes,
      ...RecipesRoutes.routes,
      ...StaffRoutes.routes,
    ],
    errorBuilder: (context, state) => Scaffold(
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
