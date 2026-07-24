import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sign_up_cubit.dart';

class SignUpDobField extends StatelessWidget {
  const SignUpDobField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<SignUpCubit>().dobController,
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: true,
            onTap: onTap,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.tr(
                      shared.LocaleKeys.commonDobFieldValidatorEmptyErrorMsg,
                      track: shared.TrackConstants.signUpTrack,
                    ) ??
                    'Please select your date of birth.';
              }
              return null;
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(20),
              labelText:
                  context.tr(
                    shared.LocaleKeys.commonDobFieldLabel,
                    track: shared.TrackConstants.signUpTrack,
                  ) ??
                  'Date of Birth',
              hintText:
                  context.tr(
                    shared.LocaleKeys.commonDobFieldHint,
                    track: shared.TrackConstants.signUpTrack,
                  ) ??
                  'Select your date of birth',
              isDense: true,
              suffixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).disabledColor),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ).inExpandedRow(),
        );
      },
    );
  }
}
