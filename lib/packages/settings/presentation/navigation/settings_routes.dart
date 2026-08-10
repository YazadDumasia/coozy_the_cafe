import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../pages/settings_screen.dart';

class SettingsRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.settingsScreenRoute,
      builder: (context, state) => const SettingsScreen(),
    ),
  ];
}
