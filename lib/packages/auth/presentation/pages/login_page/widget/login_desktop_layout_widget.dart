import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/cubit/login_screen_cubit.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/login_form_card_widget.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/login_background_widget.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/widget/login_carousel_widget.dart';

class LoginDesktopLayoutWidget extends StatefulWidget {
  final List<String> images;
  final Widget appLogoLight;
  final List<Color>? listParticleColor;
  final bool? isFirstTime;
  final GlobalKey<FormState> formKey;
  final TextEditingController? emailTextEditingController,
      passwordTextEditingController;
  final FocusNode? emailFocusNode, passwordFocusNode;
  final Future<dynamic> Function() callLoginApi;
  final VoidCallback onGoToRegisterPage;

  const LoginDesktopLayoutWidget({
    super.key,
    required this.images,
    required this.appLogoLight,
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
  State<LoginDesktopLayoutWidget> createState() =>
      _LoginDesktopLayoutWidgetState();
}

class _LoginDesktopLayoutWidgetState extends State<LoginDesktopLayoutWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<LoginScreenCubit, LoginScreenState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoginScreenNoInternetState) {
          return shared.NoInternetPage(
            onPressedRetryButton: () async {
              await context.read<LoginScreenCubit>().fetchInitialInfo();
            },
          );
        }
        return LoginBackgroundWidget(
          listParticleColor: widget.listParticleColor,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      top: 10,
                      bottom: 10,
                      right: 20,
                    ),
                    child: LoginCarouselWidget(
                      size: Size(size.width / 2, size.height),
                      images: widget.images,
                      appLogoLight: widget.appLogoLight,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 0.0,
                        top: 5,
                        bottom: 5,
                        right: 5.0,
                      ),
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
                                        passwordTextEditingController: widget
                                            .passwordTextEditingController,
                                        emailFocusNode: widget.emailFocusNode,
                                        passwordFocusNode:
                                            widget.passwordFocusNode,
                                        callLoginApi: widget.callLoginApi,
                                        onGoToRegisterPage:
                                            widget.onGoToRegisterPage,
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
