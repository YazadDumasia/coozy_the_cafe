import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/cubit/login_screen_cubit.dart';

class TextFormEmailFieldWidget extends StatefulWidget {
  final FocusNode? emailFocusNode, nextFocusNode;
  final TextEditingController? emailTextEditingController;

  const TextFormEmailFieldWidget({
    super.key,
    required this.emailFocusNode,
    required this.emailTextEditingController,
    required this.nextFocusNode,
  });

  @override
  State<TextFormEmailFieldWidget> createState() =>
      _TextFormEmailFieldWidgetState();
}

class _TextFormEmailFieldWidgetState extends State<TextFormEmailFieldWidget> {
  @override
  Widget build(final BuildContext context) {
    return StreamBuilder(
      stream: context.watch<LoginScreenCubit>().userNameStream,
      builder: (context, snapshot) {
        return TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: widget.emailTextEditingController,
          focusNode: widget.emailFocusNode,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[AutofillHints.email],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.mail_outline_outlined, size: 24),
            label: Text(
              context.tr(
                    shared.LocaleKeys.loginEmailLabel,
                    track: shared.TrackConstants.loginPageTrack,
                  ) ??
                  'Email',
            ),
            hintText:
                context.tr(shared.LocaleKeys.loginEmailHint, track: shared.TrackConstants.loginPageTrack) ??
                'Enter your Email address.',
            isDense: true,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
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
          onChanged: (text) {
            context.read<LoginScreenCubit>().updateUserName(text);
          },
          validator: (value) {
            const Pattern emailPattern =
                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            final RegExp regexEmail = RegExp(emailPattern.toString());
            if (value!.isNotEmpty) {
              if (regexEmail.hasMatch(value)) {
                return null;
              } else {
                return context.tr(
                      shared.LocaleKeys.loginEmailValidatorErrorMsg,
                      track: shared.TrackConstants.loginPageTrack,
                    ) ??
                    'Please enter a valid email.';
              }
            } else {
              return context.tr(
                    shared.LocaleKeys.loginEmailValidatorEmptyErrorMsg,
                    track: shared.TrackConstants.loginPageTrack,
                  ) ??
                  'Email is required.';
            }
          },
          onFieldSubmitted: (value) {
            FocusScope.of(
              context,
            ).requestFocus(widget.nextFocusNode ?? FocusNode());
          },
        ).inExpandedRow();
      },
    );
  }
}
