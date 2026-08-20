import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'app_localization.dart';
import 'app_theme_extension.dart';

extension MilkyBackgroundEffect on Widget {
  /// Wraps the widget in a customizable frosted glass / milky blur effect.
  ///
  /// Dynamically adapts to Light and Dark themes when [color] is not explicitly provided.
  Widget inMilkyBackgroundEffect({
    Size? size,
    double? width,
    double? height,
    BorderRadiusGeometry borderRadius = const BorderRadius.all(
      Radius.circular(10.0),
    ),
    double blur = 10.0,
    double? sigmaX,
    double? sigmaY,
    Color? color,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Clip clipBehavior = Clip.antiAlias,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        final effectiveColor =
            color ??
            (isDark
                ? theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                )
                : Colors.grey.shade200.withValues(alpha: 0.5));

        final effectiveSigmaX = sigmaX ?? blur;
        final effectiveSigmaY = sigmaY ?? blur;

        return Container(
          margin: margin,
          child: ClipRRect(
            borderRadius: borderRadius,
            clipBehavior: clipBehavior,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: effectiveSigmaX,
                sigmaY: effectiveSigmaY,
              ),
              child: Container(
                width: size?.width ?? width,
                height: size?.height ?? height,
                padding: padding,
                decoration: BoxDecoration(
                  color: effectiveColor,
                  borderRadius: borderRadius,
                  border: border,
                  boxShadow: boxShadow,
                ),
                child: this,
              ),
            ),
          ),
        );
      },
    );
  }
}

extension MartialInkwellExt on Widget {
  Widget inMartialInkwell({BorderRadius? radius}) {
    return Builder(
      builder: (context) {
        BorderRadius? actualRadius = radius;
        final ext = Theme.of(context).extension<AppThemeExtension>();
        actualRadius ??= ext?.inkWellRadius ?? BorderRadius.circular(5.0);

        return Material(
          type: MaterialType.transparency,
          borderRadius: actualRadius,
          clipBehavior: Clip.antiAlias,
          child: this,
        );
      },
    );
  }
}

extension ExpandedRowExt on Widget {
  Widget inExpandedRow({
    MainAxisSize mainAxisSize = MainAxisSize.min,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    return Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: [Expanded(child: this)],
    );
  }
}

extension ExpandedColumnExt on Widget {
  Widget inExpandedColumn({
    MainAxisSize mainAxisSize = MainAxisSize.min,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: [Expanded(child: this)],
    );
  }
}

extension PaddingExt on Widget {
  /// Adds padding to all sides
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Adds symmetric horizontal and vertical padding
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Adds padding to specific sides
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );
}

extension ResponsiveContext on BuildContext {
  /// The full screen width (swaps automatically on rotation)
  double get width => MediaQuery.sizeOf(this).width;

  /// The full screen height (swaps automatically on rotation)
  double get height => MediaQuery.sizeOf(this).height;

  /// The width MINUS the safe area (notches, etc.)
  /// Useful for ensuring content doesn't get cut off in landscape
  double get safeWidth => width - MediaQuery.paddingOf(this).horizontal;

  /// The height MINUS the safe area (status bar, home indicator)
  double get safeHeight => height - MediaQuery.paddingOf(this).vertical;

  /// Quick check for landscape orientation
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// Translates the given [key] using the AppLocalizations.
  String? tr(String key, {Map<String, String>? params, String? track}) {
    return AppLocalizations.of(
      this,
    )?.translate(key, params: params, track: track);
  }
}

extension StringLocalizationExt on String {
  /// Translates the string key using the AppLocalizations from the given [context].
  String tr(
    BuildContext context, {
    Map<String, String>? params,
    String? track,
  }) {
    return AppLocalizations.of(
          context,
        )?.translate(this, params: params, track: track) ??
        this;
  }
}
