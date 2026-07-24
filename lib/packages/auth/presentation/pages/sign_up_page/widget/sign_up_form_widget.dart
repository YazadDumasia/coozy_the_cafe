import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_button_widget.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_confirm_password_field.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_dob_field.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_gender_field.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_header_widget.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_password_field.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_phone_number_field.dart';
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/widget/sign_up_text_form_stream_widget.dart';

class SignUpFormWidget extends StatelessWidget {
  const SignUpFormWidget({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.userNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.genderController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.birthDateController,
    required this.firstNameFocusNode,
    required this.lastNameFocusNode,
    required this.userNameFocusNode,
    required this.emailFocusNode,
    required this.phoneNumberFocusNode,
    required this.genderFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.birthDateFocusNode,
    required this.onGenderChanged,
    required this.onDobTap,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController genderController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController birthDateController;

  final FocusNode firstNameFocusNode;
  final FocusNode lastNameFocusNode;
  final FocusNode userNameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode phoneNumberFocusNode;
  final FocusNode genderFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final FocusNode birthDateFocusNode;

  final Function(String) onGenderChanged;
  final VoidCallback onDobTap;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignUpCubit>();
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SignUpHeaderWidget()..inExpandedRow(),
          SignUpTextFormStreamWidget(
            controller: firstNameController,
            focusNode: firstNameFocusNode,
            hintText:
                context.tr(
                  shared.LocaleKeys.commonfirstNameFieldHint,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'First Name',
            labelText:
                context.tr(
                  shared.LocaleKeys.commonfirstNameFieldLabel,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'First Name',
            autofillHints: [AutofillHints.givenName],
            textInputType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) =>
                FocusScope.of(context).requestFocus(lastNameFocusNode),
            stream: cubit.firstNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ).inExpandedRow(),
          SignUpTextFormStreamWidget(
            controller: lastNameController,
            focusNode: lastNameFocusNode,
            hintText:
                context.tr(
                  shared.LocaleKeys.commonLastNameFieldHint,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Last Name',
            labelText:
                context.tr(
                  shared.LocaleKeys.commonLastNameFieldLabel,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Last Name',
            autofillHints: [AutofillHints.familyName],
            textInputType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) =>
                FocusScope.of(context).requestFocus(userNameFocusNode),
            stream: cubit.lastNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ).inExpandedRow(),
          SignUpTextFormStreamWidget(
            controller: userNameController,
            focusNode: userNameFocusNode,
            hintText:
                context.tr(
                  shared.LocaleKeys.commonUserNameFieldHint,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'User Name',
            labelText:
                context.tr(
                  shared.LocaleKeys.commonUserNameFieldLabel,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'User Name',
            autofillHints: [AutofillHints.username],
            textInputType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) =>
                FocusScope.of(context).requestFocus(emailFocusNode),
            stream: cubit.userNameController,
            onChanged: (value) => cubit.updateUserName(value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a user name';
              }
              if (value.trim().length < 4) {
                return 'User name must be at least 4 characters';
              }
              return null;
            },
            suffixIcon: StreamBuilder<bool?>(
              stream: cubit.isUserNameAvailableStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == true) {
                    return Icon(Icons.check_circle, color: Colors.green);
                  } else {
                    return Icon(Icons.cancel, color: Colors.red);
                  }
                }
                return SizedBox.shrink();
              },
            ),
          ),
          SignUpTextFormStreamWidget(
            controller: emailController,
            focusNode: emailFocusNode,
            hintText:
                context.tr(
                  shared.LocaleKeys.commonEmailHint,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Email Address',
            labelText:
                context.tr(
                  shared.LocaleKeys.commonEmailLabel,
                  track: shared.TrackConstants.signUpTrack,
                ) ??
                'Email Address',
            autofillHints: [AutofillHints.email],
            textInputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) =>
                FocusScope.of(context).requestFocus(passwordFocusNode),
            stream: cubit.emailController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email address';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          SignUpPasswordField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            nextFocusNode: confirmPasswordFocusNode,
          ),
          SignUpConfirmPasswordField(
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
          ),
          SignUpPhoneNumberField(
            controller: phoneNumberController,
            focusNode: phoneNumberFocusNode,
            onSubmitted: (value) =>
                FocusScope.of(context).requestFocus(birthDateFocusNode),
          ),
          SignUpDobField(
            controller: birthDateController,
            focusNode: birthDateFocusNode,
            onTap: onDobTap,
          ),
          SignUpGenderField(
            controller: genderController,
            focusNode: genderFocusNode,
            onGenderChanged: onGenderChanged,
          ),
          SignUpButtonWidget(onPressed: onSubmit),
        ],
      ),
    );
  }
}
