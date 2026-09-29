import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart' hide Orientation;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart'
    as shared
    hide AnimationType;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart' as asts;
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_carousel_widget.dart';
import 'otp_verification_page_actions.dart';
import 'widget/otp_verification_card_widget.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    this.phoneNumber,
    required this.otpNumber,
    this.appSignature,
    this.customerID,
    this.isForgetPassword,
    this.isLoginScreen,
    this.email,
  });

  final String? phoneNumber;
  final String? otpNumber;
  final String? appSignature;
  final String? customerID;
  final bool? isForgetPassword;
  final bool? isLoginScreen;
  final String? email;

  @override
  OtpVerificationPageState createState() => OtpVerificationPageState();
}

class OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin, CodeAutoFill {
  static const int kStartValue = 60;

  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _pinEditingController;
  late final FocusNode _pinFocusNode;
  AnimationController? _countdownController;

  String currentText = '';
  String? _currentOtpNumber;

  final List<String> images = <String>[
    asts.Assets.images.signUp.path,
    asts.Assets.images.signUp2.path,
    asts.Assets.images.signUp3.path,
  ];
  late Image appLogoLight;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _pinEditingController = TextEditingController();
    _pinFocusNode = FocusNode();
    _currentOtpNumber = widget.otpNumber;

    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: kStartValue),
    );
    _countdownController?.forward(from: 0.0);

    const double logoSize = 120.0;
    appLogoLight = Image.asset(
      asts.Assets.images.appLogoClearBg.path,
      fit: BoxFit.scaleDown,
      width: logoSize,
      height: logoSize,
    );

    listenOtp();
  }

  @override
  void dispose() {
    _countdownController?.dispose();
    _pinEditingController.dispose();
    _pinFocusNode.dispose();
    if (core.PlatformUtils.isMobileApp() == true) {
      try {
        SmsAutoFill().unregisterListener();
      } catch (e) {
        core.PlatformUtils.debugLog(OtpVerificationPage, 'unregisterListener:Error:$e');
      }
    }
    super.dispose();
  }

  @override
  void codeUpdated() {
    // Only handle SMS autofill on mobile app.
    // For web, do not auto-fill until the user manually enters the code.
    if (core.PlatformUtils.isMobileApp() != true) return;

    core.PlatformUtils.debugLog(OtpVerificationPage, 'Otp code updated: $code');
    if (code != null && code!.isNotEmpty) {
      _pinEditingController.text = code!;
      currentText = code!;
    }
  }

  Future<void> listenOtp() async {
    // Only listen for incoming SMS on mobile platforms.
    if (core.PlatformUtils.isMobileApp() != true) return;

    try {
      await SmsAutoFill().unregisterListener();
      listenForCode();
      await SmsAutoFill().listenForCode();
      final Stream<String> data = SmsAutoFill().code;
      data.listen((event) {
        core.PlatformUtils.debugLog(OtpVerificationPage, event);
      });
    } on Exception catch (e) {
      core.PlatformUtils.debugLog(OtpVerificationPage, 'listenOtp:Error:$e');
    }
  }

  Future<void> callApiForSendOtp() async {
    _countdownController?.forward(from: 0.0);
    _currentOtpNumber = OtpVerificationPageActions.generateNewOtp();

    if (mounted) {
      setState(() {});
      await OtpVerificationPageActions.sendOtpMessage(
        context: context,
        phoneNumber: widget.phoneNumber,
        appSignature: widget.appSignature,
        newOtpNumber: _currentOtpNumber!,
      );
    }
    await listenOtp();
  }

  Future<void> onClickVerify() async {
    await OtpVerificationPageActions.handleVerify(
      context: context,
      currentText: currentText,
      expectedOtpNumber: _currentOtpNumber,
      pinController: _pinEditingController,
      isForgetPassword: widget.isForgetPassword,
      email: widget.email,
    );
  }

  void onAutoFillDemo() {
    if (_currentOtpNumber != null && _currentOtpNumber!.isNotEmpty) {
      _pinEditingController.text = _currentOtpNumber!;
      currentText = _currentOtpNumber!;
    }
  }

  void onBackPress() {
    OtpVerificationPageActions.handleBackPress(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          onBackPress();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: shared.AnimateGradient(
            primaryBegin: Alignment.topLeft,
            primaryEnd: Alignment.bottomLeft,
            secondaryBegin: Alignment.bottomLeft,
            secondaryEnd: Alignment.topRight,
            duration: const Duration(seconds: 3),
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
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return OtpVerificationCardWidget(
      formKey: _formKey,
      pinController: _pinEditingController,
      pinFocusNode: _pinFocusNode,
      phoneNumber: widget.phoneNumber,
      currentOtpNumber: _currentOtpNumber,
      countdownAnimation:
          StepTween(begin: kStartValue, end: 0).animate(_countdownController!),
      onChanged: (value) => currentText = value,
      onVerify: onClickVerify,
      onResend: callApiForSendOtp,
      onAutoFillDemo: onAutoFillDemo,
      onBack: onBackPress,
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
