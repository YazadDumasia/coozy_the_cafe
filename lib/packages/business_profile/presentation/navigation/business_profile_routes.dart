import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import '../pages/business_profile/business_profile_screen.dart';

class BusinessProfileRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: AppRoutePath.businessProfileScreenRoute,
      name: AppRouteName.businessProfile,
      builder: (context, state) => const BusinessProfileScreen(),
    ),
  ];
}
