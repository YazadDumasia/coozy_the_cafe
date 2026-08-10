import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart'
    hide AnimationType;

import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart' hide Orientation;

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    super.key,
    this.phoneNumber,
    required this.otpNumber,
    this.appSignature,
    this.customerID,
    this.isForgetPassword,
    this.isLoginScreen,
  });
  final String? phoneNumber;
  final String? otpNumber;
  final String? appSignature;

  final String? customerID;
  final bool? isForgetPassword;
  final bool? isLoginScreen;

  @override
  OtpVerificationPageState createState() => OtpVerificationPageState();
}

class OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin, CodeAutoFill {
  Size? size;
  Orientation? orientation;
  static const int kStartValue = 60;
  PinInputController? pinController;

  AnimationController? controller;
  bool hasError = false;
  String currentText = '';
  String? _currentOtpNumber;

  @override
  void initState() {
    _currentOtpNumber = widget.otpNumber;
    pinController = PinInputController();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: kStartValue),
    );
    controller!.forward(from: 0.0);
    super.initState();
    listenOtp();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    orientation = MediaQuery.of(context).orientation;
    return SafeArea(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          backPressHandle();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Theme(
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
                // Color.fromRGBO(99, 251, 215, 1),
                // Color.fromRGBO(83, 138, 214, 1)
              ],
              secondaryColors: const <Color>[
                Color.fromRGBO(5, 222, 250, 1),
                Color.fromRGBO(134, 231, 214, 1),
              ],
              child: SizedBox(
                width: size!.width,
                height: size!.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: InkWell(
                            customBorder: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            onTap: () async {
                              backPressHandle();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(
                                left: 0,
                                top: 5,
                                right: 5,
                                bottom: 5,
                              ),
                              child: Icon(Icons.chevron_left, size: 35),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 65,

                                      child: Padding(
                                        padding: const EdgeInsets.all(25.0),
                                        child: Icon(
                                          CustomIcon.openMessage,
                                          size: 80,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    15,
                                    10,
                                    0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          context.tr(
                                                LocaleKeys
                                                    .otpVerificationPageVerificationCodeTitle,
                                                track: TrackConstants
                                                    .otpVerificationPageTrack,
                                              ) ??
                                              'Verification Code',
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 28.0,
                                    top: 10,
                                    right: 28,
                                  ),
                                  child:
                                      Text(
                                        context.tr(
                                              LocaleKeys
                                                  .otpVerificationPageVerificationCodeSubtitle,
                                              track: TrackConstants
                                                  .otpVerificationPageTrack,
                                              params: {
                                                'phoneNumber':
                                                    widget.phoneNumber ?? "",
                                              },
                                            ) ??
                                            "Please enter verification code sent to your mobile number ${widget.phoneNumber ?? ""}",
                                        maxLines: 6,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ).inExpandedRow(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      ),
                                ),
                                otpPinCodeLayout(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          context.tr(
                                                LocaleKeys
                                                    .otpVerificationPageDidntReceiveCode,
                                                track: TrackConstants
                                                    .otpVerificationPageTrack,
                                              ) ??
                                              "Didn't receive code?",
                                          textAlign: TextAlign.start,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                      ),
                                      CountDownTimer(
                                        textStyle: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                        animation: StepTween(
                                          begin: kStartValue,
                                          end: 0,
                                        ).animate(controller!),
                                        onPressed: () async {
                                          await callApiForSendOtp();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).inMilkyBackgroundEffect(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> listenOtp() async {
    try {
      if (core.PlatformUtils.isMobileApp() == true) {
        await SmsAutoFill().unregisterListener();
        listenForCode();
        await SmsAutoFill().listenForCode();
        final Stream<String> data = SmsAutoFill().code;
        data.listen((event) {
          core.PlatformUtils.debugLog(OtpVerificationPage, event);
        });
        core.PlatformUtils.debugLog(
          OtpVerificationPage,
          'Otp listen is called',
        );
      }
    } on Exception catch (e) {
      core.PlatformUtils.debugLog(OtpVerificationPage, 'listenOtp:Error:$e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    pinController?.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Future<void> codeUpdated() async {
    core.PlatformUtils.debugLog(OtpVerificationPage, 'Otp code has updated');
    pinController!.setText(code!);
  }

  static String loadSmsSendParams(String? phoneNumber, String? messageBody) {
    final Map<String, dynamic> map = <String, dynamic>{
      'PhoneTo': phoneNumber.toString(),
      'smsMessage': messageBody.toString(),
    };
    return json.encode(map);
  }

  Future<void> callApiForSendOtp() async {
    controller!.forward(from: 0.0);
    // widget.appSignature = await SmsAutoFill().getAppSignature;
    _currentOtpNumber = (math.Random().nextInt(9000) + 1000).toString();

    if (core.PlatformUtils.isMobileApp() == true) {
      final String smsMessage =
          '<#> Your code is $_currentOtpNumber\t Code:${widget.appSignature}';
      core.PlatformUtils.debugLog(OtpVerificationPage, smsMessage);
      loadSmsSendParams(widget.phoneNumber, smsMessage);
      core.PlatformUtils.debugLog(
        OtpVerificationPage,
        'Otp Code:$_currentOtpNumber',
      );
      core.PlatformUtils.debugLog(OtpVerificationPage, 'Otp sent successfully');
    } else {
      final String smsMessage = 'Your code is $_currentOtpNumber.';
      core.PlatformUtils.debugLog(OtpVerificationPage, smsMessage);
      loadSmsSendParams(widget.phoneNumber, smsMessage);
      core.PlatformUtils.debugLog(
        OtpVerificationPage,
        'Otp Code:$_currentOtpNumber',
      );
      core.PlatformUtils.debugLog(OtpVerificationPage, 'Otp sent successfully');

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
                params: {'otpCode': _currentOtpNumber ?? ''},
                track: TrackConstants.commonTrack,
              ) ??
              'Web OTP: $_currentOtpNumber',
          titleIcon: const Icon(Icons.info, color: Colors.blue, size: 50),
        );
      }
    }
    await listenOtp();
  }

  Future<void> backPressHandle() {
    if (context.canPop()) {
      context.pop();
    }
    return Future.value();
  }

  GlobalKey<FormState>? formKey = GlobalKey<FormState>();

  Column otpPinCodeLayout() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            // height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            // color: Colors.green,
            child: ListView(
              primary: false,
              shrinkWrap: true,
              children: <Widget>[
                const SizedBox(height: 5),
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 25.0,
                      left: 25.0,
                      top: 5.0,
                      bottom: 5,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: MaterialPinFormField(
                            pinController: pinController,
                            length: 4,
                            obscureText: false,
                            theme: MaterialPinTheme(
                              obscuringCharacter: '*',
                              shape: MaterialPinShape.outlined,
                              borderRadius: BorderRadius.circular(10),
                              borderWidth: 3,
                              focusedBorderColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              filledBorderColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              borderColor: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(127),
                              fillColor: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(127),
                              focusedFillColor:
                                  MediaQuery.of(context).platformBrightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : Colors.white,
                              textStyle: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                              cursorColor: Theme.of(
                                context,
                              ).textSelectionTheme.cursorColor,
                              entryAnimation: MaterialPinAnimation.scale,
                              animationDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]'),
                              ),
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                try {
                                  final String text = newValue.text;
                                  if (text.isNotEmpty) double.parse(text);
                                  return newValue;
                                } catch (e) {
                                  return oldValue;
                                }
                              }),
                            ],
                            validator: (v) {
                              return null;
                            },
                            // onCompleted: (value) {
                            //   if (// widget.otpNumber == value) {
                            //     print(value);
                            //   } else {
                            //     pinController!.clear();
                            //   }
                            // },
                            onChanged: (value) {
                              currentText = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 25.0,
                    left: 25.0,
                    top: 0.0,
                  ),
                  child: Center(
                    child: Theme(
                      data: Theme.of(context),
                      child: ElevatedButton(
                        onPressed: () async {
                          onClickVerify();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                        ),
                        child: Text(
                          context.tr(
                                LocaleKeys.otpVerificationPageVerifyBtn,
                                track: TrackConstants.otpVerificationPageTrack,
                              ) ??
                              'Verify',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> onClickVerify() async {
    if (currentText == _currentOtpNumber) {
      core.PlatformUtils.debugLog(OtpVerificationPage, 'Otp verficated.....');
      await LocalManager.instance.setBoolValue(
        key: PreferencesKeys.isLoggedIn,
        value: true,
      );
      if (mounted) {
        context.go(
          AppRoutePath.successfullyScreenRoute,
          extra: {'redirectPath': AppRoutePath.homeRoute},
        );
      }
    } else {
      pinController!.triggerError();
    }
  }
}
