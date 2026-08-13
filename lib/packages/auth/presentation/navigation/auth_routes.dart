import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../pages/login_page/cubit/login_screen_cubit.dart';
import '../pages/login_page/login_page.dart';
import '../pages/splash_page/splash_page.dart';
import '../pages/sign_up_page/cubit/sign_up_cubit.dart';
import '../pages/sign_up_page/sign_up_page.dart';
import '../pages/login_via_phone_number_page/login_via_phone_number_page.dart';
import '../pages/login_via_phone_number_page/cubit/login_with_phone_cubit.dart';
import '../pages/otp_verification_page/otp_verification_page.dart';
import '../pages/successfully_screen/successfully_screen.dart';

class AuthRoutes {
  static List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.splashRoute,
      name: AppRouteName.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutePath.loginRoute,
      name: AppRouteName.login,
      builder: (context, state) => BlocProvider<LoginScreenCubit>(
        create: (context) =>
            GetIt.instance<LoginScreenCubit>()..fetchInitialInfo(),
        child: LoginPage(isFirstTime: state.extra as bool? ?? false),
      ),
    ),
    GoRoute(
      path: AppRoutePath.registrationRoute,
      name: AppRouteName.registration,
      builder: (context, state) => BlocProvider<SignUpCubit>(
        create: (context) => GetIt.instance<SignUpCubit>()..fetchInitialInfo(),
        child: const SignUpPage(),
      ),
    ),
    GoRoute(
      path: AppRoutePath.loginViaPhoneNumberRoute,
      name: AppRouteName.loginViaPhone,
      builder: (context, state) => BlocProvider<LoginWithPhoneCubit>(
        create: (context) => GetIt.instance<LoginWithPhoneCubit>(),
        child: const LoginViaPhoneNumberPage(isUseForLogin: true),
      ),
    ),
    GoRoute(
      path: AppRoutePath.otpVerificationRoute,
      name: AppRouteName.otpVerification,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OtpVerificationPage(
          phoneNumber: extra['phoneNumber'] as String? ?? '',
          otpNumber: extra['otpNumber'] as String? ?? '',
          isLoginScreen: extra['isLoginScreen'] as bool? ?? true,
          isForgetPassword: extra['isForgetPassword'] as bool? ?? false,
          appSignature: extra['appSignature'] as String? ?? '',
        );
      },
    ),
    GoRoute(
      path: AppRoutePath.successfullyScreenRoute,
      name: AppRouteName.successfully,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final redirectPath =
            extra['redirectPath'] as String? ?? AppRoutePath.homeRoute;
        return SuccessfullyScreen(redirectPath: redirectPath);
      },
    ),
  ];
}
