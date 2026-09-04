import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../pages/currency_exchange/currency_exchange_screen.dart';
import '../pages/settings/settings_screen.dart';

class SettingsRoutes {
  static List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutePath.settingsScreenRoute,
          name: AppRouteName.settings,
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'currency-exchange',
              name: AppRouteName.currencyExchange,
              builder: (context, state) => const CurrencyExchangeScreen(),
            ),
          ],
        ),
      ];
}
