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
