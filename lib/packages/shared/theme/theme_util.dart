import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  final TextTheme baseTextTheme = Theme.of(context).textTheme;

  TextTheme getFontTheme(String fontString) {
    if (GoogleFonts.asMap().containsKey(fontString)) {
      return GoogleFonts.getTextTheme(fontString, baseTextTheme);
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
