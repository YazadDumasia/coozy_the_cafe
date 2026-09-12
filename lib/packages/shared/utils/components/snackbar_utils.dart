import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

/// Represents an action button displayed inside a [SnackBarUtils] notification.
class SnackBarActionItem {
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;

  const SnackBarActionItem({
    required this.label,
    required this.onPressed,
    this.textColor,
  });
}

/// A centralized utility for displaying consistent, theme-aware, floating notifications
/// across the application using [Flushbar].
class SnackBarUtils {
  static Flushbar? _activeFlushbar;

  /// Dismisses any currently visible notification immediately.
  static void hideCurrent(BuildContext context) {
    if (_activeFlushbar != null && _activeFlushbar!.isShowing()) {
      _activeFlushbar!.dismiss();
      _activeFlushbar = null;
    }
  }

  /// Displays a floating [Flushbar] with customizable styling, icon, and optional actions.
  static Future<dynamic> showSnackBar(
    BuildContext context, {
    required String message,
    String? title,
    Widget? leadingIcon,
    Color? backgroundColor,
    Color? leftBarIndicatorColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 4),
    List<SnackBarActionItem> actions = const [],
    FlushbarPosition position = FlushbarPosition.BOTTOM,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    BorderRadius? borderRadius,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBg = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFF1F2937);
    final effectiveTextColor = textColor ?? Colors.white;

    // Dismiss any active flushbar before showing a new one
    hideCurrent(context);

    late Flushbar flushbar;

    Widget? actionButtons;
    if (actions.isNotEmpty) {
      actionButtons = Row(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) {
          return TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            onPressed: () {
              flushbar.dismiss();
              action.onPressed();
            },
            child: Text(
              action.label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: action.textColor ?? Colors.amberAccent,
              ),
            ),
          );
        }).toList(),
      );
    }

    flushbar = Flushbar(
      titleText: title != null && title.isNotEmpty
          ? Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: effectiveTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: effectiveTextColor.withValues(
            alpha: title != null && title.isNotEmpty ? 0.9 : 1.0,
          ),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      icon: leadingIcon,
      shouldIconPulse: false,
      backgroundColor: backgroundColor ?? defaultBg,
      leftBarIndicatorColor: leftBarIndicatorColor,
      duration: duration,
      flushbarPosition: position,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      mainButton: actionButtons,
      isDismissible: true,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    _activeFlushbar = flushbar;
    return flushbar.show(context);
  }

  /// Shows a success notification with a green checkmark and green indicator bar.
  static Future<dynamic> showSuccess(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    List<SnackBarActionItem> actions = const [],
    FlushbarPosition position = FlushbarPosition.BOTTOM,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showSnackBar(
      context,
      title: title,
      message: message,
      duration: duration,
      position: position,
      backgroundColor: isDark ? const Color(0xFF132A1C) : const Color(0xFF1B4332),
      leftBarIndicatorColor: Colors.greenAccent,
      leadingIcon: const Icon(
        Icons.check_circle_rounded,
        color: Colors.greenAccent,
        size: 24,
      ),
      actions: actions,
    );
  }

  /// Shows an error notification with a red alert icon and red indicator bar.
  static Future<dynamic> showError(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 5),
    List<SnackBarActionItem> actions = const [],
    FlushbarPosition position = FlushbarPosition.BOTTOM,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showSnackBar(
      context,
      title: title,
      message: message,
      duration: duration,
      position: position,
      backgroundColor: isDark ? const Color(0xFF331414) : const Color(0xFF5C1D1D),
      leftBarIndicatorColor: Colors.redAccent,
      leadingIcon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.redAccent,
        size: 24,
      ),
      actions: actions,
    );
  }

  /// Shows a warning notification with an amber warning icon and amber indicator bar.
  static Future<dynamic> showWarning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
    List<SnackBarActionItem> actions = const [],
    FlushbarPosition position = FlushbarPosition.BOTTOM,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showSnackBar(
      context,
      title: title,
      message: message,
      duration: duration,
      position: position,
      backgroundColor: isDark ? const Color(0xFF382A14) : const Color(0xFF6B4E1B),
      leftBarIndicatorColor: Colors.amberAccent,
      leadingIcon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.amberAccent,
        size: 24,
      ),
      actions: actions,
    );
  }

  /// Shows an informational notification with an info icon and blue indicator bar.
  static Future<dynamic> showInfo(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    List<SnackBarActionItem> actions = const [],
    FlushbarPosition position = FlushbarPosition.BOTTOM,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showSnackBar(
      context,
      title: title,
      message: message,
      duration: duration,
      position: position,
      backgroundColor: isDark ? const Color(0xFF152238) : const Color(0xFF1E3A5F),
      leftBarIndicatorColor: Colors.lightBlueAccent,
      leadingIcon: const Icon(
        Icons.info_outline_rounded,
        color: Colors.lightBlueAccent,
        size: 24,
      ),
      actions: actions,
    );
  }

  /// Shows a rich action notification (e.g. for downloaded files, completed tasks)
  /// with a title, optional subtitle, icon, and action buttons.
  static Future<dynamic> showActionNotification(
    BuildContext context, {
    required String title,
    String? subtitle,
    Widget? leadingIcon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 6),
    required List<SnackBarActionItem> actions,
    FlushbarPosition position = FlushbarPosition.BOTTOM,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showSnackBar(
      context,
      title: title,
      message: subtitle ?? '',
      duration: duration,
      position: position,
      backgroundColor: backgroundColor ??
          (isDark ? const Color(0xFF132A1C) : const Color(0xFF1B4332)),
      leftBarIndicatorColor: Colors.greenAccent,
      leadingIcon: leadingIcon ??
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.greenAccent,
            size: 24,
          ),
      actions: actions,
    );
  }
}
