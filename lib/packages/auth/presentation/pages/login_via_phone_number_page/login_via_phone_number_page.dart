import 'dart:async';
import 'dart:convert';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_carousel_widget.dart';
import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sms_autofill/sms_autofill.dart' hide Orientation;

import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart'
    as assets_gen;

import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';
import 'cubit/login_with_phone_cubit.dart';

class LoginViaPhoneNumberPage extends StatefulWidget {
  const LoginViaPhoneNumberPage({required this.isUseForLogin, super.key});
  final bool isUseForLogin;

  @override
  State<LoginViaPhoneNumberPage> createState() =>
      _LoginViaPhoneNumberPageState();
}

class _LoginViaPhoneNumberPageState extends State<LoginViaPhoneNumberPage> {
  Orientation? orientation;
  GlobalKey<FormState>? _formKey;
  TextEditingController? _phoneNumberController;
  FocusNode? _phoneNumberFocusNode;
  bool? isButtonclick;
  AnimationController? controller;
  Position? currentPosition;

  Position? position;
  ScrollController? _scrollController;
  LoginWithPhoneCubit? _loginWithPhoneCubit;

  final List<String> images = <String>[
    assets_gen.Assets.images.signUp.path,
    assets_gen.Assets.images.signUp2.path,
    assets_gen.Assets.images.signUp3.path,
  ];

  late Image appLogoLight;

  /*TextEditingController? _otpController;
  FocusNode? _otpFocusNode;
  StreamController<ErrorAnimationType>? errorController;
  StreamController<ErrorAnimationType>? errorAnimationController;

  bool hasError = false;
  String currentText = "";*/

  @override
  void initState() {
    super.initState();
    appLogoLight = Image.asset(
      assets_gen.Assets.images.appLogoClearBg.path,
      fit: BoxFit.scaleDown,
      width: 120,
      height: 120,
    );

    _scrollController = ScrollController();
    _formKey = GlobalKey<FormState>();
    _phoneNumberController = TextEditingController(text: '');
    _phoneNumberFocusNode = FocusNode();
    /*_otpController = TextEditingController(text: "");
    _otpFocusNode = FocusNode();

    errorController = StreamController<ErrorAnimationType>();
    errorAnimationController = StreamController<ErrorAnimationType>();
    errorAnimationController!.add(ErrorAnimationType.shake);*/

    _loginWithPhoneCubit = BlocProvider.of<LoginWithPhoneCubit>(
      context,
      listen: false,
    );
    _loginWithPhoneCubit?.fetchInitialInfo();
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _loginWithPhoneCubit = BlocProvider.of<LoginWithPhoneCubit>(
    //     context,
    //     listen: false,
    //   );
    //   _loginWithPhoneCubit?.fetchInitialInfo();
    // });
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    orientation = MediaQuery.of(context).orientation;

    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          context.pop();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Theme(
            data: Theme.of(context),
            child: ResponsiveLayout(
              mobile: mobileWidget(),
              tablet: tabletWidget(),
              desktop: tabletWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileWidget() {
    return BlocConsumer<LoginWithPhoneCubit, LoginWithPhoneState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoginWithPhoneLoadingState ||
            state is LoginWithPhoneInitial) {
          _loginWithPhoneCubit?.updateCountryIosCode(null);
          return const LoadingPage();
        } else if (state is LoginWithPhoneLoadedState) {
          return Theme(
            data: Theme.of(context),
            child: AnimateGradient(
              primaryBegin: Alignment.topLeft,
              primaryEnd: Alignment.bottomLeft,
              secondaryBegin: Alignment.bottomLeft,
              secondaryEnd: Alignment.topRight,
              duration: const Duration(seconds: 2),
              primaryColors: const <Color>[
                Color.fromRGBO(225, 109, 245, 1),
                Color.fromRGBO(78, 248, 231, 1),
              ],
              secondaryColors: const <Color>[
                Color.fromRGBO(5, 222, 250, 1),
                Color.fromRGBO(134, 231, 214, 0.8117647058823529),
              ],
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 20,
                          top: 0,
                          right: 20,
                          child: CircleAvatar(
                            radius: 55.0,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 310 + 30,
                          right: 0,
                          child: CircleAvatar(
                            radius: 33.0,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(top: 60.0, bottom: 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                            side: BorderSide(
                              width: 5,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                            ),
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.only(top: 45, bottom: 10),
                            height: 310,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          context.tr(
                                                LocaleKeys
                                                    .loginViaPhoneNumberPageOtpVerificationTitle,
                                                track: TrackConstants
                                                    .loginViaPhoneNumberPageTrack,
                                              ) ??
                                              'OTP Verification',
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineSmall!,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            10,
                                            10,
                                            10,
                                            0,
                                          ),
                                          child: Text(
                                            textAlign: TextAlign.start,
                                            context.tr(
                                                  LocaleKeys
                                                      .loginViaPhoneNumberPageOtpVerificationSubtitle,
                                                  track: TrackConstants
                                                      .loginViaPhoneNumberPageTrack,
                                                ) ??
                                                'We will send you a One Time Password on your phone number.',
                                            softWrap: true,
                                            maxLines: 5,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleSmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  phoneNumberWidget(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5.0,
                          left: 5.0,
                          right: 5.0,
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              radius: 50.0,
                              child: Icon(
                                CustomIcon.password,
                                size: 65,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 310 + 30,
                          left: 5.0,
                          right: 5.0,
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              radius: 30.0,
                              child: StreamBuilder(
                                stream:
                                    _loginWithPhoneCubit?.buttonLoadingStream,
                                builder: (context, snapshot) {
                                  return ProgressButton(
                                    onPressed: (controller) async {
                                      this.controller = controller;
                                      submitData();
                                    },
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    strokeWidth: 4,
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: Icon(
                                        Icons.navigate_next_rounded,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else if (state is LoginWithPhoneNoInternetState) {
          return NoInternetPage(
            onPressedRetryButton: () async {
              _loginWithPhoneCubit?.fetchInitialInfo();
            },
          );
        } else if (state is LoginWithPhoneErrorState) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  Widget tabletWidget() {
    return BlocConsumer<LoginWithPhoneCubit, LoginWithPhoneState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is LoginWithPhoneLoadingState ||
            state is LoginWithPhoneInitial) {
          return const LoadingPage();
        } else if (state is LoginWithPhoneLoadedState) {
          return AnimateGradient(
            primaryBegin: Alignment.topLeft,
            primaryEnd: Alignment.bottomLeft,
            secondaryBegin: Alignment.bottomLeft,
            secondaryEnd: Alignment.topRight,
            duration: const Duration(seconds: 2),
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
            child: SizedBox(
              key: UniqueKey(),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: SignUpCarouselWidget(
                      size: Size(
                        MediaQuery.of(context).size.width / 2,
                        MediaQuery.of(context).size.height,
                      ),
                      images: images,
                      appLogoLight: appLogoLight,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 5.0,
                        top: 5,
                        bottom: 5,
                        right: 5.0,
                      ),
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              left: 20,
                              top: 0,
                              right: 20,
                              child: CircleAvatar(
                                radius: 55.0,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 310 + 30,
                              right: 0,
                              child: CircleAvatar(
                                radius: 33.0,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                              ),
                            ),
                            Card(
                              margin: const EdgeInsets.only(
                                top: 60.0,
                                bottom: 45,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                                side: BorderSide(
                                  width: 5,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.only(
                                  top: 45,
                                  bottom: 10,
                                ),
                                height: 310,
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              context.tr(
                                                    LocaleKeys
                                                        .loginViaPhoneNumberPageOtpVerificationTitle,
                                                    track: TrackConstants
                                                        .loginViaPhoneNumberPageTrack,
                                                  ) ??
                                                  'OTP Verification',
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.headlineSmall!,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    10,
                                                    10,
                                                    10,
                                                    0,
                                                  ),
                                              child: Text(
                                                textAlign: TextAlign.start,
                                                context.tr(
                                                      LocaleKeys
                                                          .loginViaPhoneNumberPageOtpVerificationSubtitle,
                                                      track: TrackConstants
                                                          .loginViaPhoneNumberPageTrack,
                                                    ) ??
                                                    'We will send you a One Time Password on your phone number.',
                                                softWrap: true,
                                                maxLines: 5,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleSmall,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      phoneNumberWidget(),
                                      /*     Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 5),
                                          child: PinCodeTextField(
                                            backgroundColor: Colors.transparent,
                                            appContext: context,
                                            pastedTextStyle: TextStyle(
                                              color: Colors.green.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            length: 6,
                                            blinkWhenObscuring: true,
                                            animationType: AnimationType.fade,
                                            validator: (v) {
                                              if (v!.length < 6) {
                                                return "Please Entered OTP Completely";
                                              } else {
                                                return null;
                                              }
                                            },
                                            errorTextSpace: 25,
                                            pinTheme: PinTheme(
                                              fieldOuterPadding: const EdgeInsets.all(5),
                                              shape: PinCodeFieldShape.underline,
                                              errorBorderColor: Colors.red,
                                              inactiveColor: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              selectedColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              activeColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            cursorColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            animationDuration:
                                                const Duration(milliseconds: 300),
                                            enableActiveFill: false,
                                            errorAnimationController:
                                                errorController,
                                            controller: _otpController,
                                            onChanged: (value) {
                                              currentText = value;
                                            },
                                            keyboardType: const TextInputType
                                                    .numberWithOptions(
                                                decimal: true, signed: false),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r"[0-9.]")),
                                              TextInputFormatter.withFunction(
                                                (oldValue, newValue) {
                                                  try {
                                                    final text = newValue.text;
                                                    if (text.isNotEmpty)
                                                      double.parse(text);
                                                    return newValue;
                                                  } catch (e) {
                                                    return oldValue;
                                                  }
                                                  return oldValue;
                                                },
                                              ),
                                            ],
                                            // textStyle: const TextStyle(color: Colors.black),
                                            beforeTextPaste: (text) {
                                              print("Allowing to paste $text");
                                              return true;
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),*/
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5.0,
                              left: 5.0,
                              right: 5.0,
                              child: Center(
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  radius: 50.0,
                                  child: Icon(
                                    CustomIcon.password,
                                    size: 65,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 310 + 30,
                              left: 5.0,
                              right: 5.0,
                              child: Center(
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  radius: 30.0,
                                  child: StreamBuilder(
                                    stream: _loginWithPhoneCubit
                                        ?.buttonLoadingStream,
                                    builder: (context, snapshot) {
                                      return ProgressButton(
                                        onPressed: (controller) async {
                                          this.controller = controller;
                                          submitData();
                                        },
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                        strokeWidth: 4,
                                        color: Colors.grey.shade300,
                                        child: const Center(
                                          child: Icon(
                                            Icons.navigate_next_rounded,
                                            color: Colors.white,
                                            size: 35,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
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
        } else if (state is LoginWithPhoneNoInternetState) {
          return NoInternetPage(
            onPressedRetryButton: () async {
              _loginWithPhoneCubit?.fetchInitialInfo();
            },
          );
        } else if (state is LoginWithPhoneErrorState) {
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  Widget phoneNumberWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 15),
            child: StreamBuilder(
              stream: _loginWithPhoneCubit?.phoneNumberIosCodeController,
              builder: (context, phoneIosCodeSnapshot) {
                return PhoneNumberTextFormField(
                  controller: _phoneNumberController,
                  focusNode: _phoneNumberFocusNode,
                  showDropdownIcon: true,
                  showCountryFlag: true,
                  isShowDialog: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(9),
                    isDense: true,
                    labelText:
                        context.tr(
                          LocaleKeys.commonPhoneNumberLabel,
                          track: TrackConstants.commonTrack,
                        ) ??
                        'Phone Number',
                    hintText:
                        context.tr(
                          LocaleKeys.commonCommonPhoneNumberHint,
                          track: TrackConstants.commonTrack,
                        ) ??
                        'Enter your phone number.',
                  ),
                  onCountryChanged: (Country country) =>
                      core.PlatformUtils.debugLog(
                        LoginViaPhoneNumberPage,
                        'Country changed to: ${country.name}',
                      ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  invalidNumberMessage:
                      context.tr(
                        LocaleKeys.commonPhoneNumberValidatorErrorMsg,
                        track: TrackConstants.commonTrack,
                      ) ??
                      'Please enter a valid phone number.',
                  validator: (phoneNumber) {
                    if (phoneNumber == null ||
                        phoneNumber.number.trim().isEmpty ||
                        phoneNumber.number == '') {
                      return context.tr(
                            LocaleKeys
                                .commonCommonPhoneNumberValidatorErrorEmptyMsg,
                            track: TrackConstants.signUpTrack,
                          ) ??
                          'Please enter your phone number.';
                    } else {
                      try {
                        phoneNumber.isValidNumber();
                        return null;
                      } catch (_) {
                        return context.tr(
                              LocaleKeys.commonPhoneNumberValidatorErrorMsg,
                              track: TrackConstants.signUpTrack,
                            ) ??
                            'Please enter a valid phone number.';
                      }
                    }
                  },
                  onChanged: (number) {
                    core.PlatformUtils.debugLog(
                      LoginViaPhoneNumberPage,
                      'number:$number',
                    );
                    _loginWithPhoneCubit!.updatePhoneNumber(
                      number.completeNumber,
                      context,
                    );
                  },
                  initialCountryCode:
                      phoneIosCodeSnapshot.data?.isoCode ?? 'IN',
                  priorityList: <Country>[
                    CountryPickerUtils.getCountryByIsoCode('IN'),
                    CountryPickerUtils.getCountryByIsoCode('US'),
                  ],
                  onSubmitted: (String value) {
                    final focusScope = FocusScope.of(context);
                    Future.microtask(
                      () => focusScope.requestFocus(FocusNode()),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller!.dispose();
    _phoneNumberController?.dispose();
    _phoneNumberFocusNode?.dispose();
    _scrollController?.dispose();
    // _otpController?.dispose();
    // _otpFocusNode?.dispose();
    super.dispose();
  }

  Future<void> verifySubmitPhoneNumber({String? phoneNumber}) async {
    core.PlatformUtils.debugLog(
      LoginViaPhoneNumberPage,
      'verifySubmit:phoneNumber:$phoneNumber',
    );
    if (core.PlatformUtils.isMobileApp() == true) {
      final String appSignatureId = await SmsAutoFill().getAppSignature;
      core.PlatformUtils.debugLog(
        LoginViaPhoneNumberPage,
        'appSignatureId:$appSignatureId',
      );

      final String otpCode = (math.Random().nextInt(9000) + 1000).toString();

      final String smsMessage = '<#> Your code is $otpCode\n$appSignatureId';

      core.PlatformUtils.debugLog(
        LoginViaPhoneNumberPage,
        'isMobileOS:$smsMessage',
      );

      await sendOtp(
        phoneNumber: phoneNumber,
        smsMessage: smsMessage,
        appSignatureId: appSignatureId,
        otpCode: otpCode,
      );
    } else {
      final String otpCode = (math.Random().nextInt(9000) + 1000).toString();
      final String smsMessage = 'Your code is $otpCode.';
      core.PlatformUtils.debugLog(LoginViaPhoneNumberPage, smsMessage);

      if (mounted) {
        DialogUtils.showAutoDismissDialog(
          showDuration: const Duration(seconds: 5),
          context: context,
          title:
              context.tr(
                LocaleKeys.commonInfo,
                track: TrackConstants.commonTrack,
              ) ??
              'Info',
          descriptions:
              context.tr(
                LocaleKeys.webOtpMsg,
                params: {'otpCode': otpCode},
                track: TrackConstants.commonTrack,
              ) ??
              'Web OTP: $otpCode',
          titleIcon: const Icon(Icons.info, color: Colors.blue, size: 50),
        );
      }

      await sendOtp(
        phoneNumber: phoneNumber,
        smsMessage: smsMessage,
        appSignatureId: null,
        otpCode: otpCode,
      );
    }
  }

  static String loadSmsSendParams(String? phoneNumber, String? messageBody) {
    final Map<String, dynamic> map = <String, dynamic>{
      'PhoneTo': phoneNumber.toString(),
      'smsMessage': messageBody.toString(),
    };
    return json.encode(map);
  }

  Future<void> sendOtp({
    String? phoneNumber,
    String? smsMessage,
    String? appSignatureId,
    String? otpCode,
  }) async {
    loadSmsSendParams(phoneNumber, smsMessage);

    // final String arg = OtpVerificationScreenArgument.addOtpVerfiy(
    //   phoneNumber: phoneNumber,
    //   isForgetPassword: false,
    //   otpNumber: otpCode,
    //   appSignature: appSignatureId ?? '',
    //   isLoginScreen: true,
    // );
    // core.PlatformUtils.debugLog(LoginViaPhoneNumberPage, 'arguments:$arg');

    final callback = await context.push<dynamic>(
      AppRoutePath.otpVerificationRoute,
      extra: {
        'phoneNumber':
            "${(_loginWithPhoneCubit!.phoneNumberIosCodeController.valueOrNull?.phoneCode ?? '')}${(_loginWithPhoneCubit!.phoneNumberController.valueOrNull ?? '')}",
        'otpNumber': otpCode,
        'appSignature': appSignatureId ?? '',
      },
    );

    if (callback == null || callback == true) {
      _phoneNumberController!.text = '';
      isButtonclick = false;
      controller!.reset();
    } else {
      _phoneNumberController!.text = '';
      isButtonclick = false;
      controller!.reset();
    }
  }

  Future<void> submitData() async {
    FocusScope.of(context).unfocus();
    if (_formKey != null &&
        _formKey!.currentState != null &&
        _formKey!.currentState!.validate()) {
      _formKey!.currentState!.save();
      if (!mounted) return;

      await verifySubmitPhoneNumber(
        phoneNumber:
            "${(_loginWithPhoneCubit!.phoneNumberIosCodeController.valueOrNull?.phoneCode ?? '')}${(_loginWithPhoneCubit!.phoneNumberController.valueOrNull ?? '')}",
      );
    } else {
      // controller?.error();
      Future.delayed(const Duration(seconds: 2), () {
        controller?.reset();
      });
    }
  }
}
