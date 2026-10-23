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
              final gradientColors = shared.AnimateGradientColors.of(context);
              final particleColors = shared.AnimateGradientColors.getCafeParticlePalette(context);
              final isDark = Theme.of(context).brightness == Brightness.dark;

              return shared.AnimateGradient(
                primaryBegin: Alignment.topLeft,
                primaryEnd: Alignment.bottomRight,
                secondaryBegin: Alignment.bottomLeft,
                secondaryEnd: Alignment.topRight,
                duration: const Duration(seconds: 4),
                primaryColors: gradientColors.primaryColors,
                secondaryColors: gradientColors.secondaryColors,
                child: Stack(
                  children: [
                    shared.CircularParticle(
                      width: size.width,
                      height: size.height,
                      awayRadius: 60,
                      numberOfParticles: 90,
                      speedOfParticles: 1.2,
                      maxParticleSize: 7,
                      particleColor: (isDark ? const Color(0xffffb59c) : const Color(0xff8c5338))
                          .withValues(alpha: 0.4),
                      isRandSize: true,
                      isRandomColor: true,
                      randColorList: particleColors,
                      awayAnimationDuration: const Duration(milliseconds: 600),
                      awayAnimationCurve: Curves.easeInOutBack,
                      enableHover: true,
                      hoverColor: const Color(0xffff8a5c),
                      hoverRadius: 80,
                      onTapAnimation: true,
                      connectDots: false,
                    ),
                    shared.ResponsiveLayout(
                      mobile: _buildMobileLayout(size),
                      tablet: _buildTabletLayout(size),
                      desktop: _buildDesktopLayout(size),
                    ),
                  ],
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
