import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_carousel_widget.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart' as asts;

import 'cubit/forgot_password_cubit.dart';
import 'forgot_password_page_actions.dart';
import 'widget/forgot_password_card_widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late FocusNode _emailFocusNode;

  final List<String> images = <String>[
    asts.Assets.images.signUp.path,
    asts.Assets.images.signUp2.path,
    asts.Assets.images.signUp3.path,
  ];

  late Image appLogoLight;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: '');
    _emailFocusNode = FocusNode();

    const double logoSize = 120.0;
    appLogoLight = Image.asset(
      asts.Assets.images.appLogoClearBg.path,
      fit: BoxFit.scaleDown,
      width: logoSize,
      height: logoSize,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ForgotPasswordPageActions.onBackToLoginPressed(context);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordEmailSentSuccess) {
                ForgotPasswordPageActions.showSuccessSentDialog(
                  context: context,
                  email: state.email,
                  temporaryPassword: kDebugMode
                      ? state.temporaryPassword
                      : null,
                  otpCode: state.otpCode,
                );
              } else if (state is ForgotPasswordFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              return shared.AnimateGradient(
                primaryColors: const <Color>[
                  Color.fromRGBO(225, 109, 245, 1),
                  Color.fromRGBO(78, 248, 231, 1),
                ],
                secondaryColors: const <Color>[
                  Color.fromRGBO(5, 222, 250, 1),
                  Color.fromRGBO(134, 231, 214, 1),
                ],
                child: shared.ResponsiveLayout(
                  mobile: _buildMobileLayout(size),
                  tablet: _buildTabletLayout(size),
                  desktop: _buildDesktopLayout(size),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Size size) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ForgotPasswordCardWidget(
          formKey: _formKey,
          emailController: _emailController,
          emailFocusNode: _emailFocusNode,
        ),
      ),
    );
  }

  Widget _buildTabletLayout(Size size) {
    return Row(
      children: [
        Expanded(
          child: SignUpCarouselWidget(
            size: Size(size.width / 2, size.height),
            images: images,
            appLogoLight: appLogoLight,
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ForgotPasswordCardWidget(
                formKey: _formKey,
                emailController: _emailController,
                emailFocusNode: _emailFocusNode,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: SignUpCarouselWidget(
            size: Size(size.width * 0.45, size.height),
            images: images,
            appLogoLight: appLogoLight,
          ),
        ),
        Expanded(
          flex: 6,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ForgotPasswordCardWidget(
                formKey: _formKey,
                emailController: _emailController,
                emailFocusNode: _emailFocusNode,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
