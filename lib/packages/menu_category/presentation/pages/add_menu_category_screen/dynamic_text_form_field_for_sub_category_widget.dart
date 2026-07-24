import 'package:flutter/material.dart';

class DynamicTextFormFieldForSubCategoryWidget extends StatefulWidget {
  const DynamicTextFormFieldForSubCategoryWidget({
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
  State<DynamicTextFormFieldForSubCategoryWidget> createState() =>
      _DynamicTextFormFieldForSubCategoryWidgetState();
}

class _DynamicTextFormFieldForSubCategoryWidgetState
    extends State<DynamicTextFormFieldForSubCategoryWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
    _controller.text = widget.initialValue ?? '';
    _focusNode = FocusNode()..requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: UniqueKey(),
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: 'MenuSubcategory Name',
        hintText: 'Enter your subCategory name',

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
          return 'Enter your sub-category name';
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
