import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';

class SignUpPasswordField extends StatelessWidget {
  const SignUpPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.nextFocusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignUpCubit>();
    return StreamBuilder<bool>(
      stream: cubit.passwordObscureTextController,
      builder: (context, isPasswordVisibleSnapshot) {
        final isObscure = isPasswordVisibleSnapshot.data ?? true;
        return StreamBuilder<String>(
          stream: cubit.passwordController,
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.text,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(nextFocusNode);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a password';
                      }
                      if (snapshot.hasError) {
                        return snapshot.error.toString();
                      }
                      return null;
                    },
                    obscureText: isObscure,

                    autofillHints: const <String>[AutofillHints.password],
                    onChanged: (value) {
                      cubit.updatePassword(value);
                      cubit.checkPassword(value);
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText:
                          context.tr(
                            shared.LocaleKeys.commonPasswordLabel,
                            track: shared.TrackConstants.signUpTrack,
                          ) ??
                          'Password',
                      labelText:
                          context.tr(
                            shared.LocaleKeys.commonPasswordHint,
                            track: shared.TrackConstants.signUpTrack,
                          ) ??
                          'Password',
                      isDense: true,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          core.PlatformUtils.debugLog(
                            SignUpPasswordField,
                            'onPressed:$isObscure',
                          );
                          cubit.updatePasswordObscureText(isObscure);
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
                StreamBuilder<bool>(
                  stream: cubit.allPasswordRequirementsMet,
                  builder: (context, allMetSnapshot) {
                    final allMet = allMetSnapshot.data ?? false;
                    return ListenableBuilder(
                      listenable: Listenable.merge([focusNode, controller]),
                      builder: (context, child) {
                        return Visibility(
                          visible:
                              (focusNode.hasFocus ||
                                  controller.text.isNotEmpty) &&
                              !allMet,
                          replacement: SizedBox.shrink(),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 15.0,
                              right: 15.0,
                              top: 8.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _RequirementItem(
                                  stream: cubit.isPasswordSizeRequire,
                                  label:
                                      context.tr(
                                        shared
                                            .LocaleKeys
                                            .signUpPasswordSizeRequireText,
                                        track:
                                            shared.TrackConstants.signUpTrack,
                                      ) ??
                                      'Contains at least 8 characters',
                                ),
                                SizedBox(height: 5),
                                _RequirementItem(
                                  stream: cubit.isPasswordOneLowerCase,
                                  label:
                                      context.tr(
                                        shared
                                            .LocaleKeys
                                            .signUpPasswordOneLowerCaseText,
                                        track:
                                            shared.TrackConstants.signUpTrack,
                                      ) ??
                                      'Contains at least 1 LowerCase character',
                                ),
                                SizedBox(height: 5),
                                _RequirementItem(
                                  stream: cubit.isPasswordOneUpperCase,
                                  label:
                                      context.tr(
                                        shared
                                            .LocaleKeys
                                            .signUpPasswordOneUpperCaseText,
                                        track:
                                            shared.TrackConstants.signUpTrack,
                                      ) ??
                                      'Contains at least 1 Uppercase character',
                                ),
                                SizedBox(height: 5),
                                _RequirementItem(
                                  stream: cubit.isPasswordOneNumCase,
                                  label:
                                      context.tr(
                                        shared
                                            .LocaleKeys
                                            .signUpPasswordOneNumCaseText,
                                        track:
                                            shared.TrackConstants.signUpTrack,
                                      ) ??
                                      'Contains at least 1 number',
                                ),
                                SizedBox(height: 5),
                                _RequirementItem(
                                  stream: cubit.isPasswordOneSpecialChar,
                                  label:
                                      context.tr(
                                        shared
                                            .LocaleKeys
                                            .signUpPasswordOneSpecialCharText,
                                        track:
                                            shared.TrackConstants.signUpTrack,
                                      ) ??
                                      'Contains at least 1 special character like !@#\$&*~+-',
                                ),
                                SizedBox(height: 5),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RequirementItem extends StatelessWidget {
  const _RequirementItem({required this.stream, required this.label});

  final Stream stream;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: snapshot.data ?? false
                    ? Colors.green
                    : Colors.transparent,
                border: snapshot.data ?? false
                    ? Border.all(color: Colors.transparent)
                    : Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Icon(Icons.check, color: Colors.white, size: 15),
              ),
            );
          },
        ),
        SizedBox(width: 10),
        Flexible(child: Text(label)),
      ],
    );
  }
}
