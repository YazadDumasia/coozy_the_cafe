import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart';

import '../pages/stock_alerts_page/stock_alerts_page.dart';

class InventoryIntelligenceRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.stockAlertsScreenRoute,
      name: AppRouteName.stockAlerts,
      builder: (context, state) => const StockAlertsPage(),
    ),
  ];
}
