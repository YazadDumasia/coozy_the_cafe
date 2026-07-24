import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;

import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/cubit/login_screen_cubit.dart';

class TextFormPasswordFieldWidget extends StatefulWidget {
  final FocusNode? passwordFocusNode;
  final TextEditingController? passwordTextEditingController;
  const TextFormPasswordFieldWidget({
    super.key,
    required this.passwordFocusNode,
    required this.passwordTextEditingController,
  });

  @override
  State<TextFormPasswordFieldWidget> createState() =>
      _TextFormPasswordFieldWidgetState();
}

class _TextFormPasswordFieldWidgetState
    extends State<TextFormPasswordFieldWidget> {
  @override
  Widget build(final BuildContext context) {
    return StreamBuilder<bool>(
      stream: context.read<LoginScreenCubit>().passwordObscureTextStream,
      builder: (context, obscureSnapshot) {
        final isObscure = obscureSnapshot.data ?? true;
        return StreamBuilder(
          stream: context.read<LoginScreenCubit>().passwordStream,
          builder: (context, snapshot) {
            return TextFormField(
              controller: widget.passwordTextEditingController!,
              focusNode: widget.passwordFocusNode,
              textInputAction: core.PlatformUtils.isMobileApp()
                  ? TextInputAction.done
                  : TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autofillHints: const <String>[AutofillHints.password],
              obscureText: isObscure,
              decoration: InputDecoration(
                prefixIcon: Icon(faf.FontAwesomeIcons.userLock.data),
                suffixIcon: IconButton(
                  onPressed: () {
                    context.read<LoginScreenCubit>().updatePasswordObscureText(
                      isObscure,
                    );
                  },
                  icon: faf.FaIcon(
                    isObscure
                        ? faf.FontAwesomeIcons.eye
                        : faf.FontAwesomeIcons.eyeSlash,
                  ),
                ),
                label: Text(
                  context.tr(
                        shared.LocaleKeys.loginPasswordLabel,
                        track: shared.TrackConstants.loginPageTrack,
                      ) ??
                      'Password',
                ),
                hintText:
                    context.tr(
                      shared.LocaleKeys.loginPasswordHint,
                      track: shared.TrackConstants.loginPageTrack,
                    ) ??
                    'Enter your password.',
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
                disabledBorder: InputBorder.none,
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
                context.read<LoginScreenCubit>().updatePassword(text);
              },
              validator: (value) {
                // r'^
                //   (?=.*[A-Z])          // should contain at least one upper case
                //   (?=.*[a-z])          // should contain at least one lower case
                //   (?=.*?[0-9])         // should contain at least one digit
                //   (?=.*?[!@#\$&*~+-])    // should contain at least one Special character
                //     .{8,}             // Must be at least 8 characters in length
                // $
                final RegExp regex = RegExp(
                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~+-]).{8,}$',
                );
                if (value!.isEmpty) {
                  // return "Please enter password";
                  return context.tr(
                        shared.LocaleKeys.loginPasswordValidatorErrorEmptyMsg,
                        track: shared.TrackConstants.loginPageTrack,
                      ) ??
                      'Please enter password';
                } else if (!regex.hasMatch(value)) {
                  // return 'Enter valid password';
                  return context.tr(
                        shared.LocaleKeys.loginPasswordValidatorErrorMsg,
                        track: shared.TrackConstants.loginPageTrack,
                      ) ??
                      'Enter your password.';
                } else {
                  return null;
                }
              },
              onFieldSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
            ).inExpandedRow();
          },
        );
      },
    );
  }
}
