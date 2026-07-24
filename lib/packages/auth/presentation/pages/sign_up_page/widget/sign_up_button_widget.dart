import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpButtonWidget extends StatelessWidget {
  const SignUpButtonWidget({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignUpCubit>();
    return Padding(
      padding: EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 25.0),
      child: StreamBuilder<bool>(
        stream: cubit.buttonLoadingStream,
        builder: (context, snapshot) {
          final isLoading = snapshot.data ?? false;
          return ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.3),
            ),
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    context.tr(
                          shared.LocaleKeys.signUsSubmitBtn,
                          track: shared.TrackConstants.signUpTrack,
                        ) ??
                        'Sign Up',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
