import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class DynamicTextFormFieldForEditSubCategoryWidget extends StatefulWidget {
  const DynamicTextFormFieldForEditSubCategoryWidget({
    required this.index,
    required this.onChanged,
    required this.onDelete,
    super.key,
    this.initialValue,
  });
  final String? initialValue;
  final void Function(String) onChanged;
  final VoidCallback onDelete;
  final int index;

  @override
  State<DynamicTextFormFieldForEditSubCategoryWidget> createState() =>
      _DynamicTextFormFieldForEditSubCategoryWidgetState();
}

class _DynamicTextFormFieldForEditSubCategoryWidgetState
    extends State<DynamicTextFormFieldForEditSubCategoryWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(
    covariant DynamicTextFormFieldForEditSubCategoryWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText:
            context.tr(
              shared.LocaleKeys.addNewMenuSubCategoryLabelText,
              track: shared.TrackConstants.menuSubCategoryPageTrack,
            ) ??
            'Sub-category Name',
        hintText:
            context.tr(
              shared.LocaleKeys.addNewMenuSubCategoryHintText,
              track: shared.TrackConstants.menuSubCategoryPageTrack,
            ) ??
            'Enter your subCategory name',

        suffixIcon: IconButton(
          onPressed: widget.onDelete,
          icon: const Icon(Icons.delete),
        ),
      ),
      onFieldSubmitted: (String value) {
        FocusScope.of(context).unfocus();
      },
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return context.tr(
                shared.LocaleKeys.addNewMenuSubCategoryErrorText,
                track: shared.TrackConstants.menuSubCategoryPageTrack,
              ) ??
              'Enter your sub-category name';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
