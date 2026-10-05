import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_carousel_widget.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart' as asts;

import 'cubit/reset_password_cubit.dart';
import 'reset_password_page_actions.dart';
import 'widget/reset_password_card_widget.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.email = '', this.token = ''});

  final String email;
  final String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _mailPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  late FocusNode _mailPasswordFocusNode;
  late FocusNode _newPasswordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  final List<String> images = <String>[
    asts.Assets.images.signUp.path,
    asts.Assets.images.signUp2.path,
    asts.Assets.images.signUp3.path,
  ];

  late Image appLogoLight;

  @override
  void initState() {
    super.initState();
    _mailPasswordController = TextEditingController(text: '');
    _newPasswordController = TextEditingController(text: '');
    _confirmPasswordController = TextEditingController(text: '');

    _mailPasswordFocusNode = FocusNode();
    _newPasswordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();

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
    _mailPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _mailPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ResetPasswordPageActions.onBackToLoginPressed(context);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
            listener: (context, state) {
              if (state is ResetPasswordSuccess) {
                ResetPasswordPageActions.showSuccessResetDialog(context);
              } else if (state is ResetPasswordFailure) {
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

  Widget _buildCard() {
    return ResetPasswordCardWidget(
      formKey: _formKey,
      email: widget.email,
      mailPasswordController: _mailPasswordController,
      newPasswordController: _newPasswordController,
      confirmPasswordController: _confirmPasswordController,
      mailPasswordFocusNode: _mailPasswordFocusNode,
      newPasswordFocusNode: _newPasswordFocusNode,
      confirmPasswordFocusNode: _confirmPasswordFocusNode,
    );
  }

  Widget _buildMobileLayout(Size size) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: _buildCard(),
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
              child: _buildCard(),
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
              child: _buildCard(),
            ),
          ),
        ),
      ],
    );
  }
}
