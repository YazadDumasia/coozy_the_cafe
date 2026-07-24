import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart' as asts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/sign_up_cubit.dart';
import 'widget/sign_up_carousel_widget.dart';
import 'widget/sign_up_form_widget.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'sign_up_page_actions.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final List<String> images = <String>[
    asts.Assets.images.signUp.path,
    asts.Assets.images.signUp2.path,
    asts.Assets.images.signUp3.path,
  ];

  late Image appLogoLight;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameTextEditingController;
  late TextEditingController _lastNameTextEditingController;
  late TextEditingController _userNameTextEditingController;
  late TextEditingController _emailTextEditingController;
  late TextEditingController _phoneNumberTextEditingController;
  late TextEditingController _genderController;
  late TextEditingController _passwordTextEditingController;
  late TextEditingController _confirmPasswordTextEditingController;
  late TextEditingController _birthDateController;

  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _userNameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _phoneNumberFocusNode;
  late FocusNode _genderFocusNode;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;
  late FocusNode _birthDateFocusNode;

  DateTime? date;

  @override
  void initState() {
    super.initState();
    appLogoLight = Image.asset(
      asts.Assets.images.appLogoClearBg.path,
      fit: BoxFit.scaleDown,
      width: 120,
      height: 120,
    );

    _firstNameTextEditingController = TextEditingController(text: '');
    _lastNameTextEditingController = TextEditingController(text: '');
    _userNameTextEditingController = TextEditingController(text: '');
    _emailTextEditingController = TextEditingController(text: '');
    _passwordTextEditingController = TextEditingController(text: '');
    _confirmPasswordTextEditingController = TextEditingController(text: '');
    _phoneNumberTextEditingController = TextEditingController(text: '');
    _birthDateController = TextEditingController(text: '');
    _genderController = TextEditingController(text: ' ');

    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _userNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneNumberFocusNode = FocusNode();
    _genderFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    _birthDateFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _firstNameTextEditingController.dispose();
    _lastNameTextEditingController.dispose();
    _userNameTextEditingController.dispose();
    _emailTextEditingController.dispose();
    _phoneNumberTextEditingController.dispose();
    _genderController.dispose();
    _passwordTextEditingController.dispose();
    _confirmPasswordTextEditingController.dispose();
    _birthDateController.dispose();

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _userNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _genderFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _birthDateFocusNode.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    precacheImage(appLogoLight.image, context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        SignUpPageActions.onPopInvoked(context);
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: shared.AnimateGradient(
            primaryColors: const <Color>[
              Color.fromRGBO(225, 109, 245, 1),
              Color.fromRGBO(78, 248, 231, 1),
              // Color.fromRGBO(99, 251, 215, 1),
              // Color.fromRGBO(83, 138, 214, 1)
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
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Scrollbar(
          interactive: true,

          child: SingleChildScrollView(child: _buildForm()),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(Size size) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Expanded(
            child: SignUpCarouselWidget(
              size: Size(size.width / 2, size.height),
              images: images,
              appLogoLight: appLogoLight,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Scrollbar(
                interactive: true,
                child: SingleChildScrollView(child: _buildForm()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignUpCarouselWidget(
            size: Size(size.width / 2, size.height),
            images: images,
            appLogoLight: appLogoLight,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Scrollbar(
                interactive: true,
                child: SingleChildScrollView(child: _buildForm()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SignUpFormWidget(
      formKey: _formKey,
      firstNameController: _firstNameTextEditingController,
      lastNameController: _lastNameTextEditingController,
      userNameController: _userNameTextEditingController,
      emailController: _emailTextEditingController,
      phoneNumberController: _phoneNumberTextEditingController,
      genderController: _genderController,
      passwordController: _passwordTextEditingController,
      confirmPasswordController: _confirmPasswordTextEditingController,
      birthDateController: _birthDateController,
      firstNameFocusNode: _firstNameFocusNode,
      lastNameFocusNode: _lastNameFocusNode,
      userNameFocusNode: _userNameFocusNode,
      emailFocusNode: _emailFocusNode,
      phoneNumberFocusNode: _phoneNumberFocusNode,
      genderFocusNode: _genderFocusNode,
      passwordFocusNode: _passwordFocusNode,
      confirmPasswordFocusNode: _confirmPasswordFocusNode,
      birthDateFocusNode: _birthDateFocusNode,
      onGenderChanged: (value) {
        _genderController.text = ' ';
        context.read<SignUpCubit>().updateGender(value);
      },
      onDobTap: () async {
        date = await SignUpPageActions.selectDate(
          context,
          date,
          _birthDateController,
        );
      },
      onSubmit: () => SignUpPageActions.callSignUpApi(
        context: context,
        formKey: _formKey,
        firstNameController: _firstNameTextEditingController,
        lastNameController: _lastNameTextEditingController,
        userNameController: _userNameTextEditingController,
        emailController: _emailTextEditingController,
        passwordController: _passwordTextEditingController,
        phoneNumberController: _phoneNumberTextEditingController,
        birthDateController: _birthDateController,
      ),
    ).inMilkyBackgroundEffect();
  }
}
