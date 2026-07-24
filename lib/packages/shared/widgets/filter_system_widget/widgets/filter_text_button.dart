/*
build and display the FilterTextButton widget.
It returns an instance of the TextButton widget with its
onPressed function calling the onTap function passed to 
this widget. The child of the TextButton is an instance of 
the Text widget where it gets its properties assigned. 
However, if they are not assigned, the widget will be assigned 
the defaults, such as an empty string for the text property. 
Lastly, the style of the text is defined with various parameters
that determine its appearance.
*/

import 'package:flutter/material.dart';

class FilterTextButton extends StatelessWidget {
  const FilterTextButton({
    super.key,
    this.text,
    this.style,
    this.buttonStyle,
    this.onTap,
    this.isSecondary = false,
    this.txtColor,
    this.fontWeight,
    this.fontSize,
    this.isElevatedButton = false,
  });
  final String? text;
  final TextStyle? style;
  final ButtonStyle? buttonStyle;
  final Function()? onTap;
  final bool isSecondary;
  final Color? txtColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool isElevatedButton;

  @override
  Widget build(BuildContext context) {
    return isElevatedButton
        ? ElevatedButton(
            onPressed: onTap,
            style: buttonStyle,
            child: Text(
              text ?? '',
              style:
                  style ??
                  (isSecondary
                      ? Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: txtColor ?? Theme.of(context).primaryColor,
                          fontWeight: fontWeight,
                          fontSize: fontSize,
                          decoration: TextDecoration.underline,
                        )
                      : Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: txtColor ?? Theme.of(context).primaryColor,
                          fontWeight: fontWeight,
                          fontSize: fontSize,
                        )),
            ),
          )
        : TextButton(
            onPressed: onTap,
            style: buttonStyle,
            child: Text(
              text ?? '',
              style:
                  style ??
                  (isSecondary
                      ? Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: txtColor ?? Theme.of(context).primaryColor,
                          fontWeight: fontWeight,
                          fontSize: fontSize,
                          decoration: TextDecoration.underline,
                        )
                      : Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: txtColor ?? Theme.of(context).primaryColor,
                          fontWeight: fontWeight,
                          fontSize: fontSize,
                        )),
            ),
          );
  }
}
