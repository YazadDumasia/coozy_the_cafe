import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart' as spinkit;
import 'package:lottie/lottie.dart' as lottie;

import '../../gen/assets.gen.dart' as asts;

class DialogUtils {
  static Future<void> showAutoDismissDialog({
    required BuildContext context,
    required String descriptions,
    String? title,
    Widget? titleIcon,
    Duration showDuration = const Duration(seconds: 3),
  }) async {
    final dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: Stack(
        children: <Widget>[
          Positioned(
            left: 20,
            top: 0,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 47,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
            margin: EdgeInsets.only(top: 45),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                width: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title != null && title.isNotEmpty) ...[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ).inExpandedRow(),
                  SizedBox(height: 10),
                ],
                Text(
                  descriptions,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : null,
                    fontWeight: FontWeight.w700,
                  ),
                ).inExpandedRow(),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 2,
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: titleIcon ?? Container(),
              ),
            ),
          ),
        ],
      ),
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(showDuration, () {
          // if (context.mounted && Navigator.canPop(context)) {
          //   Navigator.pop(context);
          // }
          if (context.mounted && context.canPop()) {
            context.pop();
          }
        });
        return dialog;
      },
    );
  }

  static Future<void> customAutoDismissAlertAppThemeDialog({
    required Type? classObject,
    required BuildContext? context,
    required String? descriptions,
    Duration? showForHowDuration,
    Widget? titleIcon,
    String? title,
    bool? barrierDismissible,
  }) async {
    final AlertDialog dialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 20,
              top: 0,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Theme.of(context!).colorScheme.primary,
                radius: 47,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 20,
                top: 65,
                right: 20,
                bottom: 20,
              ),
              margin: EdgeInsets.only(top: 45),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(
                  width: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: title?.isNotEmpty ?? false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: 10,
                        top: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              title ?? '',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: (descriptions == null || descriptions.isEmpty)
                        ? false
                        : true,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 5,
                        right: 5,
                        bottom: 0,
                        top: (title?.isNotEmpty ?? false) ? 0 : 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              descriptions ?? '',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.white
                                        : null,
                                    fontWeight: FontWeight.w700,
                                  ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: 2,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(45)),
                  child: titleIcon ?? Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Timer? counter;

    counter = Timer(showForHowDuration ?? const Duration(seconds: 3), () {
      counter?.cancel();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });

    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible ?? false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop && counter!.isActive) {
              counter.cancel();
            }
          },
          child: dialog,
        );
      },
    );
  }

  static Future<void> showTransparentLoader(BuildContext context) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder:
          (
            BuildContext buildContext,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: lottie.Lottie.asset(
                      asts.Assets.lottie.loading,
                      fit: BoxFit.scaleDown,
                      width: MediaQuery.of(context).size.width * .65,
                      height: MediaQuery.of(context).size.height * .5,
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  static void showSimpleLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: .center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  spinkit.SpinKitFadingCircle(
                    color: Theme.of(context).colorScheme.primary,
                    size: 50,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void showTimeoutDialog(
    BuildContext context,
    VoidCallback onStayConnected,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.timer_off_outlined, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text(
              'Session Timeout',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Your session is about to expire due to inactivity. Would you like to stay connected?',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : null,
            fontWeight: FontWeight.w700,
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Logout', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onStayConnected();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Stay Connected'),
          ),
        ],
      ),
    );
  }

  static Future<void> showTimedDialog({
    required BuildContext context,
    required Widget dialog,
    Duration duration = const Duration(seconds: 3),
    bool barrierDismissible = false,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        Future.delayed(duration, () {
          // if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
          //   Navigator.pop(dialogContext);
          // }
          if (dialogContext.mounted && dialogContext.canPop()) {
            dialogContext.pop();
          }
        });

        return dialog;
      },
    );
  }

  static Future<void> showLoadingDialog(
    BuildContext context, {
    double? progress,
    String? message,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing dialog on outside tap
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(10),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CupertinoActivityIndicator(
                        animating: true,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Theme.of(context).primaryColor,
                        radius: 15,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          message ??
                              (context.tr(
                                    LocaleKeys.commonPleaseWait,
                                    track: TrackConstants.utilsTrack,
                                  ) ??
                                  "Please wait..."),
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (progress != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<T?> showConfirmationDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    Widget? titleIcon,
    String? cancelText,
    String? confirmText,
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) async {
    return await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 20,
                  top: 0,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 47,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 65,
                    right: 20,
                    bottom: 20,
                  ),
                  margin: EdgeInsets.only(top: 45),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      width: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title.isNotEmpty && title != '') ...[
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 10),
                      ],

                      Text(
                        content,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : null,
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (cancelText != null || onCancel != null)
                            TextButton(
                              onPressed: () {
                                if (onCancel != null) {
                                  onCancel();
                                } else {
                                  // Navigator.pop(dialogContext);
                                  if (dialogContext.mounted &&
                                      dialogContext.canPop()) {
                                    dialogContext.pop();
                                  }
                                }
                              },
                              child: Text(
                                cancelText ?? 'Cancel',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.white
                                          : null,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          if (confirmText != null || onConfirm != null)
                            TextButton(
                              onPressed: () {
                                if (onConfirm != null) {
                                  onConfirm();
                                } else {
                                  // Navigator.pop(dialogContext);
                                  if (dialogContext.mounted &&
                                      dialogContext.canPop()) {
                                    dialogContext.pop();
                                  }
                                }
                              },
                              child: Text(
                                confirmText ?? 'Okay',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.white
                                          : null,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 2,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child:
                          titleIcon ??
                          Icon(
                            Icons.info_outline,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<T?> customPopUpDialogMessage<T>({
    Object? classObject,
    required BuildContext context,
    Widget? titleIcon,
    required String title,
    required String descriptions,
    Widget? actions,
    bool barrierDismissible = true,
  }) async {
    return await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 20,
                  top: 0,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    radius: 47,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: 20,
                    top: 65,
                    right: 20,
                    bottom: 20,
                  ),
                  margin: EdgeInsets.only(top: 45),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      width: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (title.isNotEmpty && title != '') ...[
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 10),
                      ],
                      Text(
                        descriptions,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : null,
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 20),
                      ?actions,
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 2,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child:
                          titleIcon ??
                          Icon(
                            Icons.info_outline,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
