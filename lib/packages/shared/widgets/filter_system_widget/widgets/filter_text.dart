///Custom text button
library;

import 'package:flutter/material.dart';

class FilterText extends StatelessWidget {
  const FilterText({
    super.key,
    this.title,
    this.style,
    this.txtAlign,
    this.fontSize,
    this.fontWeight,
    this.fontColor,
    this.fontStyle,
    this.letterSpacing,
    this.fontFamilyLevel,
    this.overflow,
    this.maxLine,
    this.decoration,
  });

  final String? title;
  final TextStyle? style;
  final TextAlign? txtAlign;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? fontColor;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final int? fontFamilyLevel;
  final TextOverflow? overflow;
  final int? maxLine;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Text(
      title ?? '',
      textAlign: txtAlign ?? TextAlign.start,
      style:
          style ??
          theme.textTheme.titleMedium?.copyWith(
            fontSize: fontSize ?? 17,
            fontWeight: fontWeight ?? FontWeight.w600,
            fontStyle: fontStyle ?? FontStyle.normal,
            letterSpacing: letterSpacing,
            decoration: decoration,
            color: fontColor,
          ),
      overflow: overflow,
      maxLines: maxLine,
    );
  }
}
