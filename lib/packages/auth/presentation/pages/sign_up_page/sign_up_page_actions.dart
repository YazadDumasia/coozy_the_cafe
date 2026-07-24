import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as share;
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/sign_up_page.dart';

class SignUpPageActions {
  static Future<DateTime?> selectDate(
    BuildContext context,
    DateTime? currentDate,
    TextEditingController birthDateController,
  ) async {
    DateTime? datePick;
    DateTime dateValue = DateTime.now();

    if (core.PlatformUtils.isMobileApp() == true) {
      if (core.PlatformUtils.isIOS() == true) {
        await showModalBottomSheet(
          context: context,
          builder: (BuildContext builder) {
            return Container(
              width: MediaQuery.of(context).copyWith().size.width,
              height: MediaQuery.of(context).copyWith().size.height / 3,
              color: Theme.of(context).dialogTheme.backgroundColor,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime picker) {
                  dateValue = picker;
                },
                initialDateTime: DateTime.now(),
                minimumYear: 1900,
                maximumYear: DateTime.now().year + 150,
              ),
            );
          },
        ).then((value) {
          final String? pick = core.DateUtil.dateToString(
            dateValue,
            'dd-MM-yyyy',
          );
          core.PlatformUtils.debugLog(SignUpPage, 'DOB:Date:$pick');
          birthDateController.text = pick!;
          return dateValue;
        });
      } else {
        datePick = await showDatePicker(
          context: context,
          initialDate: currentDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2101),
        );
        if (datePick != null && datePick != currentDate) {
          final String? pick = core.DateUtil.dateToString(
            datePick,
            'dd-MM-yyyy',
          );
          core.PlatformUtils.debugLog(SignUpPage, 'DOB:Date:$pick');
          birthDateController.text = pick!;
          return datePick;
        }
      }
    } else {
      datePick = await showDatePicker(
        context: context,
        initialDate: currentDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101),
      );
      if (datePick != null && datePick != currentDate) {
        final String? pick = core.DateUtil.dateToString(datePick, 'dd-MM-yyyy');
        core.PlatformUtils.debugLog(SignUpPage, 'DOB:Date:$pick');
        birthDateController.text = pick!;
        return datePick;
      }
    }
    return currentDate;
  }

  static void callSignUpApi({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController userNameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController phoneNumberController,
    required TextEditingController birthDateController,
  }) {
    if (formKey.currentState!.validate()) {
      final signUpCubit = context.read<SignUpCubit>();
      final Map<String, dynamic> body = {
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'user_name': userNameController.text,
        'email_address': emailController.text,
        'password': passwordController.text,
        'phone_number': phoneNumberController.text,
        'gender': signUpCubit.genderController.valueOrNull ?? '',
        'birth_date': birthDateController.text,
      };

      core.PlatformUtils.debugLog(SignUpPage, 'Sign Up Body: $body');
      signUpCubit.submitSignUp(
        body: body,
        onSuccess: () {
          if (context.mounted) {
            share.DialogUtils.showAutoDismissDialog(
              context: context,
              title:
                  context.tr(
                    share.LocaleKeys.commonSuccess,
                    track: share.TrackConstants.commonTrack,
                  ) ??
                  'Success',
              descriptions:
                  context.tr(
                    share.LocaleKeys.signUpRegistrationCompletedSuccessfully,
                    track: share.TrackConstants.signUpTrack,
                  ) ??
                  'Registration completed successfully!',
              titleIcon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            );
          }
        },
        onError: (error) {
          if (context.mounted) {
            share.DialogUtils.showAutoDismissDialog(
              context: context,
              title:
                  context.tr(
                    share.LocaleKeys.commonError,
                    track: share.TrackConstants.commonTrack,
                  ) ??
                  'Error',
              descriptions: error.isNotEmpty
                  ? error
                  : (context.tr(
                          share.LocaleKeys.commonErrorMsg,
                          track: share.TrackConstants.commonTrack,
                        ) ??
                        'An error occurred.'),
              titleIcon: const Icon(Icons.error, color: Colors.red, size: 50),
            );
          }
        },
      );
    }
  }

  static void onPopInvoked(BuildContext context) {
    context.go(core.AppRoutePath.loginRoute);
  }
}
