import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

import 'package:coozy_the_cafe/packages/auth/presentation/pages/login_page/cubit/login_screen_cubit.dart';

class SignInButtonWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Future<void> Function() callLoginApi;
  const SignInButtonWidget({
    super.key,
    required this.formKey,
    required this.callLoginApi,
  });

  @override
  State<SignInButtonWidget> createState() => _SignInButtonWidgetState();
}

class _SignInButtonWidgetState extends State<SignInButtonWidget> {
  @override
  Widget build(final BuildContext context) {
    return StreamBuilder(
      stream: context.watch<LoginScreenCubit>().buttonLoadingStream,
      builder: (final context, final snapshot) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    context.read<LoginScreenCubit>().updateButtonLoading(true);
                    if (widget.formKey.currentState!.validate()) {
                      widget.formKey.currentState!.save();
                      await widget.callLoginApi();
                    } else {
                      await shared.LocalManager.instance.setBoolValue(
                        key: shared.PreferencesKeys.isLoggedIn,
                        value: false,
                      );

                      if (context.mounted) {
                        context.read<LoginScreenCubit>().updateButtonLoading(
                          false,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  child: (snapshot.data == null || snapshot.data == false)
                      ? Text(
                          context.tr(shared.LocaleKeys.loginInactiveBtn) ??
                              'Login',
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              context.tr(
                                    shared.LocaleKeys.loginLoadingInactiveBtn,
                                  ) ??
                                  'Please Wait...',
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
