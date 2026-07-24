import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class SignUpHeaderWidget extends StatelessWidget {
  const SignUpHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text:
                    '${context.tr(shared.LocaleKeys.signUpWelcomeTitleMessage, track: shared.TrackConstants.signUpTrack) ?? 'Hey there,'}\n',
              ),
              TextSpan(
                text:
                    context.tr(
                      shared.LocaleKeys.createAnAccountMsg,
                      track: shared.TrackConstants.signUpTrack,
                    ) ??
                    'Create an Account',
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
