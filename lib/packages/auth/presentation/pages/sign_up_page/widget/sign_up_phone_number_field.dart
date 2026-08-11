import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';

class SignUpPhoneNumberField extends StatelessWidget {
  const SignUpPhoneNumberField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<SignUpCubit>().phoneNumberIosCodeController,
      builder: (context, phoneIosCodeSnapshot) {
        return Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10, top: 15),
          child: shared.PhoneNumberTextFormField(
            controller: controller,
            focusNode: focusNode,
            showDropdownIcon: true,
            showCountryFlag: true,
            flagsButtonMargin: EdgeInsets.all(10),
            //show the selected country flag and name in the label text
            isCountryButtonPersistent: false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(20),
              labelText:
                  context.tr(
                    shared.LocaleKeys.commonPhoneNumberLabel,
                    track: shared.TrackConstants.signUpTrack,
                  ) ??
                  'Phone Number',
              hintText:
                  context.tr(
                    shared.LocaleKeys.commonCommonPhoneNumberHint,
                    track: shared.TrackConstants.signUpTrack,
                  ) ??
                  'Enter your phone number.',
            ),
            onCountryChanged: (shared.Country country) {
              controller.clear();
              context.read<SignUpCubit>().updatePhoneNumber('');
              core.PlatformUtils.debugLog(
                SignUpPhoneNumberField,
                'Country changed to:  + ${country.name}',
              );
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (phoneNumber) {
              if (phoneNumber == null ||
                  phoneNumber.number.trim().isEmpty ||
                  phoneNumber.number == '') {
                return context.tr(
                      shared
                          .LocaleKeys
                          .commonCommonPhoneNumberValidatorErrorEmptyMsg,
                      track: shared.TrackConstants.signUpTrack,
                    ) ??
                    'Please enter your phone number.';
              } else {
                try {
                  phoneNumber.isValidNumber();
                  return null;
                } catch (_) {
                  return context.tr(
                        shared.LocaleKeys.commonPhoneNumberValidatorErrorMsg,
                        track: shared.TrackConstants.signUpTrack,
                      ) ??
                      'Please enter a valid phone number.';
                }
              }
            },
            invalidNumberMessage:
                context.tr(
                  shared.LocaleKeys.commonPhoneNumberValidatorErrorMsg,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Please enter a valid phone number.',
            onChanged: (number) {
              context.read<SignUpCubit>().updatePhoneNumber(
                number.completeNumber,
              );
            },
            initialCountryCode: phoneIosCodeSnapshot.data?.isoCode ?? 'IN',
            priorityList: <shared.Country>[
              shared.CountryPickerUtils.getCountryByIsoCode('IN'),
              shared.CountryPickerUtils.getCountryByIsoCode('US'),
            ],
            onSubmitted: onSubmitted,
          ),
        ).inExpandedRow();
      },
    );
  }
}
