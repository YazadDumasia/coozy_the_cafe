import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/sign_in_button_widget.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/text_form_email_field_widget.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/text_form_password_field_widget.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/social_media_login_row_widget.dart';

class LoginFormCardWidget extends StatelessWidget {
  final bool? isFirstTime;
  final GlobalKey<FormState> formKey;
  final TextEditingController? emailTextEditingController;
  final TextEditingController? passwordTextEditingController;
  final FocusNode? emailFocusNode;
  final FocusNode? passwordFocusNode;
  final Future<dynamic> Function() callLoginApi;
  final VoidCallback onGoToRegisterPage;

  const LoginFormCardWidget({
    super.key,
    required this.isFirstTime,
    required this.formKey,
    required this.emailTextEditingController,
    required this.passwordTextEditingController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.callLoginApi,
    required this.onGoToRegisterPage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Theme(
        data: Theme.of(context),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              AutofillGroup(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                              child: Text(
                                isFirstTime == true
                                    ? context.tr(
                                            shared.LocaleKeys.loginWelcome,
                                            track: shared
                                                .TrackConstants
                                                .loginPageTrack,
                                          ) ??
                                          'Welcome'
                                    : context.tr(
                                            shared.LocaleKeys.loginWelcomeBack,
                                            track: shared
                                                .TrackConstants
                                                .loginPageTrack,
                                          ) ??
                                          'Welcome Back',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                              child: TextFormEmailFieldWidget(
                                emailTextEditingController:
                                    emailTextEditingController,
                                emailFocusNode: emailFocusNode,
                                nextFocusNode: passwordFocusNode,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: TextFormPasswordFieldWidget(
                                passwordTextEditingController:
                                    passwordTextEditingController,
                                passwordFocusNode: passwordFocusNode,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SignInButtonWidget(
                        formKey: formKey,
                        callLoginApi: callLoginApi,
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.loginDidAccount,
                              track: shared.TrackConstants.loginPageTrack,
                            ) ??
                            "Don't have an account ?",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge!,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: TextButton(
                        onPressed: onGoToRegisterPage,
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all<EdgeInsets>(
                            EdgeInsets.only(
                              left: 30,
                              right: 30,
                              bottom: 5,
                              top: 5,
                            ),
                          ),
                        ),
                        child: Text(
                          context.tr(
                                shared.LocaleKeys.loginSignUpBtn,
                                track: shared.TrackConstants.loginPageTrack,
                              ) ??
                              'Sign Up',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      height: 1,
                      endIndent: 25,
                      indent: 25,
                      thickness: 1,
                    ),
                  ),
                  shared.HoverUpDownWidget(
                    animationDuration: const Duration(milliseconds: 1500),
                    childWidget: Text(
                      context.tr(
                            shared.LocaleKeys.loginOr,
                            track: shared.TrackConstants.loginPageTrack,
                          ) ??
                          'Or',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      height: 1,
                      endIndent: 25,
                      indent: 25,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              const SocialMediaLoginRowWidget(),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
