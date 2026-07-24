import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

extension NavigationExtensions on BuildContext {
  void navigateToHome() => go(AppRoutePath.homeRoute);

  void navigateToLogin({bool isFirstTime = false}) {
    go(AppRoutePath.loginRoute, extra: isFirstTime);
  }

  void navigateToBusinessOnboarding() =>
      go(AppRoutePath.businessOnboardingRoute);

  void goBack() => pop();
}
