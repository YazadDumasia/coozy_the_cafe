import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as share;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart'
    as assets_gen;
import 'cubit/login_screen_cubit.dart';
import 'widget/login_desktop_layout_widget.dart';
import 'widget/login_mobile_layout_widget.dart';
import 'widget/login_tablet_layout_widget.dart';
import 'login_page_actions.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.isFirstTime, super.key});

  final bool? isFirstTime;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController? emailTextEditingController,
      passwordTextEditingController;
  FocusNode? emailFocusNode, passwordFocusNode;

  bool? isButtonLoading = false;

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: ["email"],
  // );

  // late GoogleSignInAccount? _currentUser;

  List<Color> listParticleColor = <Color>[];
  final List<String> images = <String>[
    'assets/images/welcome.jpg',
    'assets/images/welcome1.jpg',
    'assets/images/welcome2.jpg',
  ];
  // late Image appLogoLight;

  Size? size;
  Orientation? orientation;

  // bool? isSignInLoading = false;

  @override
  void initState() {
    emailTextEditingController = TextEditingController(text: 'admin@coozy.com');
    passwordTextEditingController = TextEditingController(text: 'Admin@123456');
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    for (int i = 0; i < 30; i++) {
      listParticleColor.add(
        Color(math.Random().nextInt(0xffffffff)).withAlpha(0xff),
      );
    }
    // _googleSignIn.onCurrentUserChanged
    //     .listen((GoogleSignInAccount? account) async {
    //   _currentUser = account;
    //   navigationRoutes.navigateToHomePage();
    // });

    super.initState();

    // appLogoLight = Image.asset(
    //   assets_gen.Assets.images.appLogoClearBg.path,
    //   fit: BoxFit.scaleDown,
    // );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    orientation = MediaQuery.of(context).orientation;
    return SafeArea(
      child: AnimatedBuilder(
        animation:
            ModalRoute.of(context)!.secondaryAnimation ??
            const AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          final isCurrent =
              ModalRoute.of(context)?.secondaryAnimation?.status ==
              AnimationStatus.dismissed;
          return PopScope(
            canPop: !isCurrent,
            onPopInvokedWithResult: (didPop, result) async {
              await LoginPageActions.handlePopAction(
                context,
                didPop,
                isCurrent,
              );
            },
            child: child!,
          );
        },
        child: BlocListener<LoginScreenCubit, LoginScreenState>(
          listener: (context, state) {},
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: share.ResponsiveLayout(
                mobile: LoginMobileLayoutWidget(
                  formKey: _formKey,
                  isFirstTime: widget.isFirstTime,
                  listParticleColor: listParticleColor,
                  emailFocusNode: emailFocusNode,
                  passwordFocusNode: passwordFocusNode,
                  emailTextEditingController: emailTextEditingController,
                  passwordTextEditingController: passwordTextEditingController,
                  callLoginApi: () => LoginPageActions.callLoginApi(
                    context,
                    _formKey,
                    emailTextEditingController,
                    passwordTextEditingController,
                  ),
                  onGoToRegisterPage: () =>
                      LoginPageActions.onGoToRegisterPage(context),
                ),
                tablet: LoginTabletLayoutWidget(
                  formKey: _formKey,
                  isFirstTime: widget.isFirstTime,
                  listParticleColor: listParticleColor,
                  images: images,
                  appLogoLight: Image.asset(
                    assets_gen.Assets.images.appLogoClearBg.path,
                    fit: BoxFit.scaleDown,
                    width: MediaQuery.sizeOf(context).width * 0.1,
                    height: MediaQuery.sizeOf(context).width * 0.09,
                  ),
                  emailFocusNode: emailFocusNode,
                  passwordFocusNode: passwordFocusNode,
                  emailTextEditingController: emailTextEditingController,
                  passwordTextEditingController: passwordTextEditingController,
                  callLoginApi: () => LoginPageActions.callLoginApi(
                    context,
                    _formKey,
                    emailTextEditingController,
                    passwordTextEditingController,
                  ),
                  onGoToRegisterPage: () =>
                      LoginPageActions.onGoToRegisterPage(context),
                ),
                desktop: LoginDesktopLayoutWidget(
                  formKey: _formKey,
                  isFirstTime: widget.isFirstTime,
                  listParticleColor: listParticleColor,
                  images: images,
                  appLogoLight: Image.asset(
                    assets_gen.Assets.images.appLogoClearBg.path,
                    fit: BoxFit.scaleDown,
                    width: MediaQuery.sizeOf(context).width * 0.1,
                    height: MediaQuery.sizeOf(context).width * 0.09,
                  ),
                  emailFocusNode: emailFocusNode,
                  passwordFocusNode: passwordFocusNode,
                  emailTextEditingController: emailTextEditingController,
                  passwordTextEditingController: passwordTextEditingController,
                  callLoginApi: () => LoginPageActions.callLoginApi(
                    context,
                    _formKey,
                    emailTextEditingController,
                    passwordTextEditingController,
                  ),
                  onGoToRegisterPage: () =>
                      LoginPageActions.onGoToRegisterPage(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // precacheImage(appLogoLight.image, context);
  }

  void clearTextData() {
    emailTextEditingController!.clear();
    passwordTextEditingController!.clear();
  }

  @override
  void dispose() {
    emailTextEditingController?.dispose();
    passwordTextEditingController?.dispose();
    emailFocusNode?.dispose();
    passwordFocusNode?.dispose();

    super.dispose();
  }
}
