import 'package:flutter/material.dart';

class MaterialTheme {
  const MaterialTheme(this.textTheme);

  final TextTheme textTheme;

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xffa43c12),
      surfaceTint: Color(0xffa43c12),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffff9068),
      onPrimaryContainer: Color(0xff451100),
      secondary: Color(0xff8f4c34),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffb49a),
      onSecondaryContainer: Color(0xff5c2510),
      tertiary: Color(0xff8e3200),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffcb4a00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff241915),
      onSurfaceVariant: Color(0xff57423b),
      outline: Color(0xff8b7169),
      outlineVariant: Color(0xffdec0b6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3a2e29),
      inversePrimary: Color(0xffffb59c),
      primaryFixed: Color(0xffffdbcf),
      onPrimaryFixed: Color(0xff380c00),
      primaryFixedDim: Color(0xffffb59c),
      onPrimaryFixedVariant: Color(0xff822800),
      secondaryFixed: Color(0xffffdbcf),
      onSecondaryFixed: Color(0xff380c00),
      secondaryFixedDim: Color(0xffffb59c),
      onSecondaryFixedVariant: Color(0xff72351f),
      tertiaryFixed: Color(0xffffdbce),
      onTertiaryFixed: Color(0xff370e00),
      tertiaryFixedDim: Color(0xffffb598),
      onTertiaryFixedVariant: Color(0xff7e2c00),
      surfaceDim: Color(0xffebd6cf),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ec),
      surfaceContainer: Color(0xffffe9e3),
      surfaceContainerHigh: Color(0xfffae4dd),
      surfaceContainerHighest: Color(0xfff4ded7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff7b2500),
      surfaceTint: Color(0xffa43c12),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffc25227),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff6d321c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffa96248),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff782900),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffcb4a00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff241915),
      onSurfaceVariant: Color(0xff533e37),
      outline: Color(0xff715a52),
      outlineVariant: Color(0xff8f756d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3a2e29),
      inversePrimary: Color(0xffffb59c),
      primaryFixed: Color(0xffc25227),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xffa13a0f),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffa96248),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff8c4a32),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xffcb4a00),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xffa23a00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffebd6cf),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ec),
      surfaceContainer: Color(0xffffe9e3),
      surfaceContainerHigh: Color(0xfffae4dd),
      surfaceContainerHighest: Color(0xfff4ded7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff441100),
      surfaceTint: Color(0xffa43c12),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff7b2500),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff421201),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6d321c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff421300),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff782900),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff31201a),
      outline: Color(0xff533e37),
      outlineVariant: Color(0xff533e37),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3a2e29),
      inversePrimary: Color(0xffffe7e0),
      primaryFixed: Color(0xff7b2500),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff561700),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6d321c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff501c08),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff782900),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff531a00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffebd6cf),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ec),
      surfaceContainer: Color(0xffffe9e3),
      surfaceContainerHigh: Color(0xfffae4dd),
      surfaceContainerHighest: Color(0xfff4ded7),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb59c),
      surfaceTint: Color(0xffffb59c),
      onPrimary: Color(0xff5c1a00),
      primaryContainer: Color(0xfff7794a),
      onPrimaryContainer: Color(0xff240600),
      secondary: Color(0xffffdbcf),
      onSecondary: Color(0xff55200b),
      secondaryContainer: Color(0xfff9a486),
      onSecondaryContainer: Color(0xff501c08),
      tertiary: Color(0xffffb598),
      onTertiary: Color(0xff591c00),
      tertiaryContainer: Color(0xffcb4a00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1b110d),
      onSurface: Color(0xfff4ded7),
      onSurfaceVariant: Color(0xffdec0b6),
      outline: Color(0xffa68b82),
      outlineVariant: Color(0xff57423b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff4ded7),
      inversePrimary: Color(0xffa43c12),
      primaryFixed: Color(0xffffdbcf),
      onPrimaryFixed: Color(0xff380c00),
      primaryFixedDim: Color(0xffffb59c),
      onPrimaryFixedVariant: Color(0xff822800),
      secondaryFixed: Color(0xffffdbcf),
      onSecondaryFixed: Color(0xff380c00),
      secondaryFixedDim: Color(0xffffb59c),
      onSecondaryFixedVariant: Color(0xff72351f),
      tertiaryFixed: Color(0xffffdbce),
      onTertiaryFixed: Color(0xff370e00),
      tertiaryFixedDim: Color(0xffffb598),
      onTertiaryFixedVariant: Color(0xff7e2c00),
      surfaceDim: Color(0xff1b110d),
      surfaceBright: Color(0xff443632),
      surfaceContainerLowest: Color(0xff160c08),
      surfaceContainerLow: Color(0xff241915),
      surfaceContainer: Color(0xff281d19),
      surfaceContainerHigh: Color(0xff342723),
      surfaceContainerHighest: Color(0xff3f322e),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffbba4),
      surfaceTint: Color(0xffffb59c),
      onPrimary: Color(0xff300900),
      primaryContainer: Color(0xfff7794a),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffdbcf),
      onSecondary: Color(0xff4d1a06),
      secondaryContainer: Color(0xfff9a486),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffbba1),
      onTertiary: Color(0xff2e0b00),
      tertiaryContainer: Color(0xfff7600d),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1b110d),
      onSurface: Color(0xfffff9f8),
      onSurfaceVariant: Color(0xffe3c4ba),
      outline: Color(0xffb99d94),
      outlineVariant: Color(0xff987d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff4ded7),
      inversePrimary: Color(0xff842800),
      primaryFixed: Color(0xffffdbcf),
      onPrimaryFixed: Color(0xff270600),
      primaryFixedDim: Color(0xffffb59c),
      onPrimaryFixedVariant: Color(0xff661d00),
      secondaryFixed: Color(0xffffdbcf),
      onSecondaryFixed: Color(0xff270600),
      secondaryFixedDim: Color(0xffffb59c),
      onSecondaryFixedVariant: Color(0xff5d2610),
      tertiaryFixed: Color(0xffffdbce),
      onTertiaryFixed: Color(0xff260700),
      tertiaryFixedDim: Color(0xffffb598),
      onTertiaryFixedVariant: Color(0xff632000),
      surfaceDim: Color(0xff1b110d),
      surfaceBright: Color(0xff443632),
      surfaceContainerLowest: Color(0xff160c08),
      surfaceContainerLow: Color(0xff241915),
      surfaceContainer: Color(0xff281d19),
      surfaceContainerHigh: Color(0xff342723),
      surfaceContainerHighest: Color(0xff3f322e),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffff9f8),
      surfaceTint: Color(0xffffb59c),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffbba4),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffff9f8),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffbba4),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffff9f8),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffffbba1),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1b110d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfffff9f8),
      outline: Color(0xffe3c4ba),
      outlineVariant: Color(0xffe3c4ba),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff4ded7),
      inversePrimary: Color(0xff511600),
      primaryFixed: Color(0xffffe0d7),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffbba4),
      onPrimaryFixedVariant: Color(0xff300900),
      secondaryFixed: Color(0xffffe0d7),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffbba4),
      onSecondaryFixedVariant: Color(0xff2f0900),
      tertiaryFixed: Color(0xffffe0d6),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffffbba1),
      onTertiaryFixedVariant: Color(0xff2e0b00),
      surfaceDim: Color(0xff1b110d),
      surfaceBright: Color(0xff443632),
      surfaceContainerLowest: Color(0xff160c08),
      surfaceContainerLow: Color(0xff241915),
      surfaceContainer: Color(0xff281d19),
      surfaceContainerHigh: Color(0xff342723),
      surfaceContainerHighest: Color(0xff3f322e),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colorScheme.primary,
      selectionColor: colorScheme.primary.withValues(alpha: 0.7),
      selectionHandleColor: colorScheme.primary,
    ),
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      titleTextStyle: textTheme.titleMedium!.copyWith(color: Colors.white),
      backgroundColor: colorScheme.primary,
      iconTheme: const IconThemeData(color: Colors.white, size: 24.0),
      actionsIconTheme: const IconThemeData(color: Colors.white, size: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: colorScheme.onPrimary,
      unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
      indicatorColor: colorScheme.onPrimary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.normal,
      ),
      tabAlignment: TabAlignment.fill,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      visualDensity: VisualDensity.comfortable,
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: textTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      columnSpacing: 24,
      horizontalMargin: 20,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    dividerColor: colorScheme.outlineVariant,
    dividerTheme: DividerThemeData(
      thickness: 1,
      color: colorScheme.outlineVariant,
    ),
  );

  List<ExtendedColor> get extendedColors => <ExtendedColor>[];
}

class ExtendedColor {
  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });

  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
