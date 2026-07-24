import 'package:flutter/material.dart';

class CountDownTimer extends AnimatedWidget {
  CountDownTimer({super.key, this.animation, this.onPressed, this.textStyle})
    : super(listenable: animation!);
  final Animation<int>? animation;
  final GestureTapCallback? onPressed;
  final TextStyle? textStyle;

  @override
  Theme build(BuildContext context) {
    String time = '(${animation!.value})';
    if (animation!.value == 0) {
      time = '';
    }
    return Theme(
      data: Theme.of(context),
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          onTap: animation!.value == 0 ? onPressed : null,
          child: Padding(
            padding: EdgeInsets.only(left: 10, bottom: 3, top: 3, right: 10),
            child: Text(
              'Resend $time',
              style: (textStyle ?? Theme.of(context).textTheme.bodyMedium)
                  ?.copyWith(
                    decoration: animation!.value == 0
                        ? TextDecoration.underline
                        : null,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
