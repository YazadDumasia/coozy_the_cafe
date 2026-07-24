import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef AutoCompleteOverlayItemBuilder<T> =
    Widget Function(BuildContext context, T suggestion);

typedef Filter<T> = bool Function(T suggestion, String query);

typedef InputEventCallback<T> = Function(T data);

typedef StringCallback = Function(String data);

class AutoCompleteTextField<T> extends StatefulWidget {
  const AutoCompleteTextField({
    required GlobalKey<AutoCompleteTextFieldState<T>> key,
    required this.suggestions,
    required this.itemBuilder,
    required this.itemSorter,
    required this.itemFilter,
    this.inputFormatters,
    this.style,
    this.decoration = const InputDecoration(),
    this.textChanged,
    this.textSubmitted,
    this.onFocusChanged,
    this.itemSubmitted,
    this.keyboardType = TextInputType.text,
    this.suggestionsAmount = 5,
    this.submitOnSuggestionTap = true,
    this.clearOnSubmit = true,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.sentences,
    this.minLength = 1,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.autoSelect = false,
    this.onSaved,
    this.validator,
  }) : super(key: key);
  final List<T> suggestions;
  final Filter<T> itemFilter;
  final Comparator<T> itemSorter;
  final StringCallback? textChanged, textSubmitted;
  final ValueSetter<bool>? onFocusChanged;
  final InputEventCallback<T>? itemSubmitted;
  final AutoCompleteOverlayItemBuilder<T> itemBuilder;
  final int suggestionsAmount;

  final bool submitOnSuggestionTap, clearOnSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final int minLength;

  final InputDecoration decoration;
  final TextStyle? style;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool autoSelect;

  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;

  @override
  AutoCompleteTextFieldState<T> createState() =>
      AutoCompleteTextFieldState<T>();
}

class AutoCompleteTextFieldState<T> extends State<AutoCompleteTextField<T>> {
  @override
  void initState() {
    super.initState();
    suggestions = widget.suggestions;
    textChanged = widget.textChanged;
    textSubmitted = widget.textSubmitted;
    onFocusChanged = widget.onFocusChanged;
    itemSubmitted = widget.itemSubmitted;
    itemBuilder = widget.itemBuilder;
    itemSorter = widget.itemSorter;
    itemFilter = widget.itemFilter;
    suggestionsAmount = widget.suggestionsAmount;
    submitOnSuggestionTap = widget.submitOnSuggestionTap;
    clearOnSubmit = widget.clearOnSubmit;
    minLength = widget.minLength;
    inputFormatters = widget.inputFormatters;
    textCapitalization = widget.textCapitalization;
    decoration = widget.decoration;
    style = widget.style;
    keyboardType = widget.keyboardType;
    textInputAction = widget.textInputAction;
    controller = widget.controller;
    focusNode = widget.focusNode;
    autofocus = widget.autofocus;
    autoSelect = widget.autoSelect;
    onSaved = widget.onSaved;
    validator = widget.validator;

    if (focusNode != null) {
      focusCreated = false;
    }
    focusNode = focusNode ?? FocusNode();
    textField = TextFormField(
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: decoration,
      style: style,
      keyboardType: keyboardType,
      focusNode: focusNode,
      autofocus: autofocus,
      controller: controller ?? TextEditingController(),
      textInputAction: textInputAction,
      onChanged: (newText) {
        currentText = newText;
        updateOverlay(newText);
        if (textChanged != null) textChanged!(newText);
      },
      onTap: () {
        updateOverlay(currentText);
      },
      onFieldSubmitted: (submittedText) =>
          triggerSubmitted(submittedText: submittedText),
      onSaved: onSaved,
      validator: validator,
    );

    if (controller != null) {
      currentText = controller!.text;
    }

    focusNode!.addListener(() {
      if (onFocusChanged != null) {
        onFocusChanged!(focusNode!.hasFocus);
      }

      if (!focusNode!.hasFocus) {
        filteredSuggestions = <T>[];
        updateOverlay();
      } else if (currentText != '') {
        updateOverlay(currentText);
        if (autoSelect) {
          controller!.value = controller!.value.copyWith(
            text: currentText,
            selection: TextSelection(
              baseOffset: 0,
              extentOffset: currentText.length,
            ),
            composing: TextRange.empty,
          );
        }
      }
    });
  }

  final LayerLink _layerLink = LayerLink();
  late TextFormField textField;
  late List<T> suggestions;
  late StringCallback? textChanged, textSubmitted;
  late ValueSetter<bool>? onFocusChanged;
  late InputEventCallback<T>? itemSubmitted;
  late AutoCompleteOverlayItemBuilder<T> itemBuilder;
  late Comparator<T> itemSorter;
  OverlayEntry? listSuggestionsEntry;
  late List<T> filteredSuggestions;
  late Filter<T> itemFilter;
  late int suggestionsAmount;
  late int minLength;
  late bool submitOnSuggestionTap, clearOnSubmit;
  late TextEditingController? controller;
  FocusNode? focusNode;
  bool focusCreated = true;
  late bool autofocus;
  late bool autoSelect;
  late FormFieldSetter<String>? onSaved;
  late FormFieldValidator<String>? validator;

  String currentText = '';

  late InputDecoration decoration;
  List<TextInputFormatter>? inputFormatters;
  late TextCapitalization textCapitalization;
  TextStyle? style;
  late TextInputType keyboardType;
  late TextInputAction textInputAction;
  final ScrollController _scrollController = ScrollController();

  void updateDecoration(
    InputDecoration decoration,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization,
    TextStyle? style,
    TextInputType keyboardType,
    TextInputAction textInputAction,
  ) {
    this.decoration = decoration;

    if (inputFormatters != null) {
      this.inputFormatters = inputFormatters;
    }

    if (style != null) {
      this.style = style;
    }

    this.keyboardType = keyboardType;

    this.textInputAction = textInputAction;

    setState(() {
      textField = TextFormField(
        inputFormatters: this.inputFormatters,
        textCapitalization: this.textCapitalization,
        decoration: this.decoration,
        style: this.style,
        keyboardType: this.keyboardType,
        focusNode: focusNode ?? FocusNode(),
        autofocus: autofocus,
        controller: controller ?? TextEditingController(),
        textInputAction: this.textInputAction,
        onChanged: (newText) {
          currentText = newText;
          updateOverlay(newText);

          if (textChanged != null) {
            textChanged!(newText);
          }
        },
        onTap: () {
          updateOverlay(currentText);
        },
        onFieldSubmitted: (submittedText) =>
            triggerSubmitted(submittedText: submittedText),
        onSaved: onSaved,
        validator: validator,
      );
    });
  }

  void triggerSubmitted({String? submittedText}) {
    submittedText == null
        ? textSubmitted!(currentText)
        : textSubmitted!(submittedText);

    if (clearOnSubmit) {
      clear();
    }
  }

  void clear() {
    textField.controller!.clear();
    currentText = '';
    updateOverlay();
  }

  void addAndSelectSuggestion(T newSuggestion) {
    final existingSuggestion = suggestions.firstWhere(
      (suggestion) => suggestion.toString() == newSuggestion.toString(),
    );
    if (existingSuggestion != null) {
      suggestions.remove(existingSuggestion);
    }
    suggestions.add(newSuggestion);
    setState(() {
      currentText = newSuggestion.toString();
      textField.controller!.text = currentText;
      focusNode!.unfocus();
      itemSubmitted!(newSuggestion);
    });
    updateOverlay();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        focusNode!.unfocus();
        // Here you can write your code for open new view
      });
    });
  }

  void addSuggestion(T suggestion) {
    suggestions.add(suggestion);
    updateOverlay(currentText);
  }

  void removeSuggestion(T suggestion) {
    suggestions.contains(suggestion)
        ? suggestions.remove(suggestion)
        : throw 'List does not contain suggestion and therefore cannot be removed';
    updateOverlay(currentText);
  }

  void updateSuggestions(List<T> suggestions) {
    this.suggestions = suggestions;
    updateOverlay(currentText);
  }

  double max(double value1, double value2) {
    return value1 > value2 ? value1 : value2;
  }

  void updateOverlay([String? query]) {
    if (listSuggestionsEntry == null) {
      final RenderBox textfieldRenderObject =
          (context.findRenderObject() as RenderBox);
      final Size textFieldSize = textfieldRenderObject.size;
      final double width = textFieldSize.width;
      final double height = textFieldSize.height;
      final Offset position = textfieldRenderObject.localToGlobal(Offset.zero);
      listSuggestionsEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            width: width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, height),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: width,
                  maxWidth: width,
                  minHeight: 0,
                  maxHeight: max(
                    0,
                    MediaQuery.of(context).size.height -
                        MediaQuery.of(context).viewInsets.bottom -
                        position.dy -
                        height,
                  ),
                ),
                child: Card(
                  child: Scrollbar(
                    interactive: true,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const ClampingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      controller: _scrollController,
                      child: Column(
                        children: filteredSuggestions.map((suggestion) {
                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: InkWell(
                                  child: itemBuilder(context, suggestion),
                                  onTap: () {
                                    setState(() {
                                      if (submitOnSuggestionTap) {
                                        final String text = suggestion
                                            .toString();
                                        textField.controller!.text = text;
                                        focusNode!.unfocus();
                                        itemSubmitted!(suggestion);
                                        if (clearOnSubmit) {
                                          clear();
                                        }
                                      } else {
                                        final String text = suggestion
                                            .toString();
                                        textField.controller!.text = text;
                                        textChanged!(text);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      Overlay.of(context).insert(listSuggestionsEntry!);
    }

    filteredSuggestions = getSuggestions(
      suggestions,
      itemSorter,
      itemFilter,
      suggestionsAmount,
      query,
    );

    listSuggestionsEntry!.markNeedsBuild();
  }

  List<T> getSuggestions(
    List<T> suggestions,
    Comparator<T> sorter,
    Filter<T> filter,
    int maxAmount,
    String? query,
  ) {
    if (null == query || query.length < minLength) {
      return <T>[];
    }

    suggestions = suggestions.where((item) => filter(item, query)).toList();
    suggestions.sort(sorter);
    if (suggestions.length > maxAmount) {
      suggestions = suggestions.sublist(0, maxAmount);
    }
    return suggestions;
  }

  @override
  void dispose() {
    // if we created our own focus node and controller, dispose of them
    // otherwise, let the caller dispose of their own instances
    if (focusCreated) {
      focusNode!.dispose();
    }
    if (controller == null) {
      textField.controller!.dispose();
    }
    listSuggestionsEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(link: _layerLink, child: textField);
  }
}

class SimpleAutoCompleteTextField extends AutoCompleteTextField<String> {
  SimpleAutoCompleteTextField({
    required super.key,
    required super.suggestions,
    super.style,
    super.decoration,
    super.onFocusChanged,
    super.textChanged,
    super.textSubmitted,
    super.minLength,
    super.controller,
    super.focusNode,
    super.autofocus,
    super.keyboardType,
    super.suggestionsAmount,
    super.submitOnSuggestionTap,
    super.clearOnSubmit,
    super.textInputAction,
    super.textCapitalization,
  }) : super(
         itemBuilder: (context, item) {
           return Padding(padding: EdgeInsets.all(8.0), child: Text(item));
         },
         itemSorter: (a, b) {
           return a.compareTo(b);
         },
         itemFilter: (item, query) {
           return item.toLowerCase().startsWith(query.toLowerCase());
         },
       );
}
