// ignore_for_file: library_private_types_in_public_api
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;

class DateTimeField extends FormField<DateTime> {
  DateTimeField({
    required this.format,
    required this.onShowPicker,
    super.key,
    super.onSaved,
    super.validator,
    super.initialValue,
    super.autovalidateMode,
    super.enabled,
    this.resetIcon = const Icon(Icons.close),
    this.onChanged,
    this.controller,
    this.focusNode,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    this.readOnly = true,
    bool? showCursor,
    bool obscureText = false,
    bool autocorrect = true,
    MaxLengthEnforcement maxLengthEnforcement = MaxLengthEnforcement.enforced,
    int maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    VoidCallback? onEditingComplete,
    ValueChanged<DateTime?>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    double cursorWidth = 2.0,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    InputCounterWidgetBuilder? buildCounter,
  }) : super(
         builder: (field) {
           final _DateTimeFieldState state = field as _DateTimeFieldState;
           final InputDecoration effectiveDecoration =
               (decoration ?? InputDecoration()).applyDefaults(
                 Theme.of(field.context).inputDecorationTheme,
               );
           return TextField(
             controller: state._effectiveController,
             focusNode: state._effectiveFocusNode,
             decoration: effectiveDecoration.copyWith(
               errorText: field.errorText,
               suffixIcon: state.shouldShowClearIcon(effectiveDecoration)
                   ? IconButton(icon: resetIcon!, onPressed: state.clear)
                   : null,
             ),
             keyboardType: keyboardType,
             textInputAction: textInputAction,
             style: style,
             strutStyle: strutStyle,
             textAlign: textAlign,
             textDirection: textDirection,
             textCapitalization: textCapitalization,
             autofocus: autofocus,
             readOnly: readOnly,
             showCursor: showCursor,
             obscureText: obscureText,
             autocorrect: autocorrect,
             maxLengthEnforcement: maxLengthEnforcement,
             maxLines: maxLines,
             minLines: minLines,
             expands: expands,
             maxLength: maxLength,
             onChanged: (string) => field.didChange(tryParse(string, format)),
             onEditingComplete: onEditingComplete,
             onSubmitted: (string) => onFieldSubmitted == null
                 ? null
                 : onFieldSubmitted(tryParse(string, format)),
             inputFormatters: inputFormatters,
             enabled: enabled,
             cursorWidth: cursorWidth,
             cursorRadius: cursorRadius,
             cursorColor: cursorColor,
             scrollPadding: scrollPadding,
             keyboardAppearance: keyboardAppearance,
             enableInteractiveSelection: enableInteractiveSelection,
             buildCounter: buildCounter,
           );
         },
       );

  final DateFormat format;
  final Future<DateTime?> Function(BuildContext context, DateTime? currentValue)
  onShowPicker;
  final Icon? resetIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final void Function(DateTime? value)? onChanged;

  @override
  _DateTimeFieldState createState() => _DateTimeFieldState();

  static String tryFormat(DateTime? date, DateFormat format) {
    if (date != null) {
      try {
        return format.format(date);
      } catch (e) {
        // Handle formatting error
      }
    }
    return '';
  }

  static DateTime? tryParse(String string, DateFormat format) {
    if (string.isNotEmpty) {
      try {
        return format.parse(string);
      } catch (e) {
        // Handle parsing error
      }
    }
    return null;
  }

  static DateTime combine(DateTime date, TimeOfDay? time) => DateTime(
    date.year,
    date.month,
    date.day,
    time?.hour ?? 0,
    time?.minute ?? 0,
  );

  static DateTime? convert(TimeOfDay? time) => time == null
      ? null
      : DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          time.hour,
          time.minute,
        );
}

class _DateTimeFieldState extends FormFieldState<DateTime> {
  TextEditingController? _controller;
  FocusNode? _focusNode;
  bool isShowingDialog = false;
  bool hadFocus = false;

  @override
  DateTimeField get widget => super.widget as DateTimeField;

  TextEditingController? get _effectiveController =>
      widget.controller ?? _controller;

  FocusNode? get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  bool get hasFocus => _effectiveFocusNode!.hasFocus;

  bool get hasText => _effectiveController!.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: format(widget.initialValue));
      _controller!.addListener(_handleControllerChanged);
    }
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _focusNode!.addListener(_handleFocusChanged);
    }
    widget.controller?.addListener(_handleControllerChanged);
    widget.focusNode?.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(DateTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller = TextEditingController.fromValue(
          oldWidget.controller!.value,
        );
        _controller!.addListener(_handleControllerChanged);
      }
      if (widget.controller != null) {
        setValue(parse(widget.controller!.text));
        if (oldWidget.controller == null) {
          _controller?.dispose();
          _controller = null;
        }
      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      widget.focusNode?.addListener(_handleFocusChanged);

      if (oldWidget.focusNode != null && widget.focusNode == null) {
        _focusNode = FocusNode();
        _focusNode!.addListener(_handleFocusChanged);
      }
      if (widget.focusNode != null && oldWidget.focusNode == null) {
        _focusNode?.dispose();
        _focusNode = null;
      }
    }
  }

  @override
  void didChange(DateTime? value) {
    if (widget.onChanged != null) widget.onChanged!(value);
    super.didChange(value);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode?.dispose();
    widget.controller?.removeListener(_handleControllerChanged);
    widget.focusNode?.removeListener(_handleFocusChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    _effectiveController!.text = format(widget.initialValue);
    didChange(widget.initialValue);
  }

  void _handleControllerChanged() {
    if (_effectiveController!.text != format(value)) {
      didChange(parse(_effectiveController!.text));
    }
  }

  String format(DateTime? date) => DateTimeField.tryFormat(date, widget.format);

  DateTime? parse(String text) => DateTimeField.tryParse(text, widget.format);

  Future<void> requestUpdate() async {
    if (!isShowingDialog) {
      isShowingDialog = true;
      _hideKeyboard();
      final DateTime? newValue = await widget.onShowPicker(context, value);
      isShowingDialog = false;
      if (newValue != null) {
        _effectiveController!.text = format(newValue);
      }
    }
  }

  void _handleFocusChanged() {
    if (hasFocus && !hadFocus && (!hasText || widget.readOnly)) {
      hadFocus = hasFocus;
      _hideKeyboard();
      requestUpdate();
    } else {
      hadFocus = hasFocus;
    }
  }

  void _hideKeyboard() {
    Future.microtask(() {
      if (mounted) FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Future<void> clear() async {
    _hideKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _effectiveController!.clear());
    });
  }

  bool shouldShowClearIcon([InputDecoration? decoration]) =>
      widget.resetIcon != null &&
      (hasText || hasFocus) &&
      decoration?.suffixIcon == null;
}
