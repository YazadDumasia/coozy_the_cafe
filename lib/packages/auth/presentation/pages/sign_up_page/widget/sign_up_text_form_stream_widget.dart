import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class SignUpTextFormStreamWidget extends StatefulWidget {
  const SignUpTextFormStreamWidget({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.autofillHints,
    this.textInputType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.stream,
    this.validator,
    this.onChanged,
    this.suffixIcon,
  });
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Iterable<String>? autofillHints;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Stream? stream;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  State<SignUpTextFormStreamWidget> createState() =>
      _SignUpTextFormStreamWidgetState();
}

class _SignUpTextFormStreamWidgetState
    extends State<SignUpTextFormStreamWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.textInputType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: widget.onChanged,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            validator: widget.validator,
            autofillHints: widget.autofillHints,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(20),
              hintText: widget.hintText,
              labelText: widget.labelText,
              isDense: true,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).disabledColor),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ).inExpandedRow();
      },
    );
  }
}
