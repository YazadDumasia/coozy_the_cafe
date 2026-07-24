import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;

import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';

class SignUpConfirmPasswordField extends StatelessWidget {
  const SignUpConfirmPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignUpCubit>();
    return StreamBuilder<bool>(
      stream: cubit.confirmPasswordObscureTextController,
      builder: (context, isConfirmPasswordVisibleSnapshot) {
        final isObscure = isConfirmPasswordVisibleSnapshot.data ?? true;
        return StreamBuilder<String>(
          stream: cubit.confirmPasswordController,
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.text,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) =>
                        FocusScope.of(context).requestFocus(FocusNode()),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (snapshot.hasError) {
                        return snapshot.error.toString();
                      }
                      return null;
                    },
                    obscureText: isObscure,
                    autofillHints: const <String>[AutofillHints.password],
                    onChanged: (value) {
                      cubit.updateConfirmPassword(value);
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText:
                          context.tr(
                            shared.LocaleKeys.commonComfirmPasswordHint,
                            track: shared.TrackConstants.signUpTrack,
                          ) ??
                          'Confirm Password',
                      labelText:
                          context.tr(
                            shared.LocaleKeys.commonComfirmPasswordLabel,
                            track: shared.TrackConstants.signUpTrack,
                          ) ??
                          'Confirm Password',
                      isDense: true,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          core.PlatformUtils.debugLog(
                            SignUpConfirmPasswordField,
                            'onPressed:$isObscure',
                          );

                          cubit.updateConfirmPasswordObscureText(isObscure);
                        },
                        icon: faf.FaIcon(
                          isObscure
                              ? faf.FontAwesomeIcons.eye
                              : faf.FontAwesomeIcons.eyeSlash,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).disabledColor,
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
                  ),
                ).inExpandedRow(),
              ],
            );
          },
        );
      },
    );
  }
}
