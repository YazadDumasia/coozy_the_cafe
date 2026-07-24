import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final BorderRadius? inkWellRadius;

  const AppThemeExtension({this.inkWellRadius});

  @override
  ThemeExtension<AppThemeExtension> copyWith({BorderRadius? inkWellRadius}) {
    return AppThemeExtension(
      inkWellRadius: inkWellRadius ?? this.inkWellRadius,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      inkWellRadius: BorderRadius.lerp(inkWellRadius, other.inkWellRadius, t),
    );
  }
}
