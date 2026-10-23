import 'package:cupertino_ui/cupertino_ui.dart' as cupertino_ui;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

cupertino.CupertinoTextThemeData fromCupertinoUiTextTheme(
  cupertino_ui.CupertinoTextThemeData c,
) {
  return cupertino.CupertinoTextThemeData(
    textStyle: c.textStyle,
    actionTextStyle: c.actionTextStyle,
    actionSmallTextStyle: c.actionSmallTextStyle,
    tabLabelTextStyle: c.tabLabelTextStyle,
    navTitleTextStyle: c.navTitleTextStyle,
    navLargeTitleTextStyle: c.navLargeTitleTextStyle,
    navActionTextStyle: c.navActionTextStyle,
    pickerTextStyle: c.pickerTextStyle,
    dateTimePickerTextStyle: c.dateTimePickerTextStyle,
  );
}

cupertino_ui.CupertinoTextThemeData toCupertinoUiTextTheme(
  cupertino.CupertinoTextThemeData c,
) {
  return cupertino_ui.CupertinoTextThemeData(
    textStyle: c.textStyle,
    actionTextStyle: c.actionTextStyle,
    actionSmallTextStyle: c.actionSmallTextStyle,
    tabLabelTextStyle: c.tabLabelTextStyle,
    navTitleTextStyle: c.navTitleTextStyle,
    navLargeTitleTextStyle: c.navLargeTitleTextStyle,
    navActionTextStyle: c.navActionTextStyle,
    pickerTextStyle: c.pickerTextStyle,
    dateTimePickerTextStyle: c.dateTimePickerTextStyle,
  );
}

TextTheme _fromMaterialUiTextTheme(material_ui.TextTheme m) {
  return TextTheme(
    displayLarge: m.displayLarge,
    displayMedium: m.displayMedium,
    displaySmall: m.displaySmall,
    headlineLarge: m.headlineLarge,
    headlineMedium: m.headlineMedium,
    headlineSmall: m.headlineSmall,
    titleLarge: m.titleLarge,
    titleMedium: m.titleMedium,
    titleSmall: m.titleSmall,
    bodyLarge: m.bodyLarge,
    bodyMedium: m.bodyMedium,
    bodySmall: m.bodySmall,
    labelLarge: m.labelLarge,
    labelMedium: m.labelMedium,
    labelSmall: m.labelSmall,
  );
}

material_ui.TextTheme _toMaterialUiTextTheme(TextTheme m) {
  return material_ui.TextTheme(
    displayLarge: m.displayLarge,
    displayMedium: m.displayMedium,
    displaySmall: m.displaySmall,
    headlineLarge: m.headlineLarge,
    headlineMedium: m.headlineMedium,
    headlineSmall: m.headlineSmall,
    titleLarge: m.titleLarge,
    titleMedium: m.titleMedium,
    titleSmall: m.titleSmall,
    bodyLarge: m.bodyLarge,
    bodyMedium: m.bodyMedium,
    bodySmall: m.bodySmall,
    labelLarge: m.labelLarge,
    labelMedium: m.labelMedium,
    labelSmall: m.labelSmall,
  );
}

TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  final TextTheme baseTextTheme = Theme.of(context).textTheme;

  TextTheme getFontTheme(String fontString) {
    if (GoogleFonts.asMap().containsKey(fontString)) {
      final material_ui.TextTheme googleTheme = GoogleFonts.getTextTheme(
        fontString,
        _toMaterialUiTextTheme(baseTextTheme),
      );
      return _fromMaterialUiTextTheme(googleTheme);
    } else {
      // Fallback for custom fonts not available on Google Fonts
      return baseTextTheme.apply(fontFamily: fontString);
    }
  }

  final TextTheme bodyTextTheme = getFontTheme(bodyFontString);
  final TextTheme displayTextTheme = getFontTheme(displayFontString);

  final TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
    displayLarge: bodyTextTheme.displayLarge,
    displayMedium: bodyTextTheme.displayMedium,
    displaySmall: bodyTextTheme.displaySmall,
    headlineLarge: bodyTextTheme.headlineLarge,
    headlineMedium: bodyTextTheme.headlineMedium,
    headlineSmall: bodyTextTheme.headlineSmall,
    titleLarge: bodyTextTheme.titleLarge,
    titleMedium: bodyTextTheme.titleMedium,
    titleSmall: bodyTextTheme.titleSmall,
  );
  return textTheme;
}

class AnimateGradientColors {
  final List<Color> primaryColors;
  final List<Color> secondaryColors;

  const AnimateGradientColors({
    required this.primaryColors,
    required this.secondaryColors,
  });

  /// Resolves theme-aware primary and secondary gradient colors for [AnimateGradient]
  /// consistent with the Coozy The Cafe warm palette in both Light and Dark modes.
  factory AnimateGradientColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const AnimateGradientColors(
        primaryColors: <Color>[
          Color(0xff1c110c),
          Color(0xff291811),
        ],
        secondaryColors: <Color>[
          Color(0xff24140d),
          Color(0xff120a06),
        ],
      );
    } else {
      return const AnimateGradientColors(
        primaryColors: <Color>[
          Color(0xffffe9e3),
          Color(0xffffdbcf),
        ],
        secondaryColors: <Color>[
          Color(0xffffd2c2),
          Color(0xfffae4dd),
        ],
      );
    }
  }

  /// Curated warm cafe particle colors adapting to theme
  static List<Color> getCafeParticlePalette(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const <Color>[
        Color(0xffff8a5c), // Primary bright coral/peach
        Color(0xfff59e0b), // Warm caramel amber
        Color(0xfffbbf24), // Amber gold
        Color(0xffffb59c), // Light peach
        Color(0xffdebfa8), // Warm latte
        Color(0xffe7bdb2), // Creamy mocha
        Color(0xffcb4a00), // Roasted cinnamon
        Color(0xffffffff), // Soft white highlight
      ];
    } else {
      return const <Color>[
        Color(0xffa43c12), // Rich espresso terracotta
        Color(0xffcb4a00), // Cinnamon
        Color(0xffd97706), // Deep amber
        Color(0xff8f4c34), // Warm mocha
        Color(0xffff8a5c), // Peach coral
        Color(0xffb45309), // Roasted caramel
      ];
    }
  }
}
