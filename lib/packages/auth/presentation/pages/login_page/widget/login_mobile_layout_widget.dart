import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/cubit/login_screen_cubit.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/login_form_card_widget.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/login_background_widget.dart';

class LoginMobileLayoutWidget extends StatefulWidget {
  final List<Color>? listParticleColor;
  final bool? isFirstTime;
  final GlobalKey<FormState> formKey;
  final TextEditingController? emailTextEditingController,
      passwordTextEditingController;
  final FocusNode? emailFocusNode, passwordFocusNode;

  final Future<dynamic> Function() callLoginApi;
  final VoidCallback onGoToRegisterPage;
  const LoginMobileLayoutWidget({
    super.key,
    required this.listParticleColor,
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
  State<LoginMobileLayoutWidget> createState() =>
      _LoginMobileLayoutWidgetState();
}

class _LoginMobileLayoutWidgetState extends State<LoginMobileLayoutWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<LoginScreenCubit, LoginScreenState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoginScreenNoInternetState) {
          return shared.NoInternetPage(
            onPressedRetryButton: () {
              context.read<LoginScreenCubit>().fetchInitialInfo();
            },
          );
        }
        return LoginBackgroundWidget(
          listParticleColor: widget.listParticleColor,
          child: Center(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              children: <Widget>[
                Theme(
                  data: Theme.of(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            width: size.width * .85,
                            child: LoginFormCardWidget(
                              isFirstTime: widget.isFirstTime,
                              formKey: widget.formKey,
                              emailTextEditingController:
                                  widget.emailTextEditingController,
                              passwordTextEditingController:
                                  widget.passwordTextEditingController,
                              emailFocusNode: widget.emailFocusNode,
                              passwordFocusNode: widget.passwordFocusNode,
                              callLoginApi: widget.callLoginApi,
                              onGoToRegisterPage: widget.onGoToRegisterPage,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
