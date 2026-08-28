import 'package:coozy_the_cafe/packages/core/navigation/app_routes.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart' as faf;
import 'package:go_router/go_router.dart';

class SocialMediaLoginRowWidget extends StatelessWidget {
  const SocialMediaLoginRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Tooltip(
            message:
                // "Login Via Facebook",
                context.tr(
                  shared.LocaleKeys.loginViaFacebookTooltip,
                  track: shared.TrackConstants.loginPageTrack,
                ) ??
                'Login Via Facebook',
            waitDuration: const Duration(seconds: 1),
            showDuration: const Duration(seconds: 2),
            padding: EdgeInsets.all(10),
            preferBelow: true,
            child: shared.HoverUpDownWidget(
              animationDuration: const Duration(milliseconds: 1500),
              childWidget: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: EdgeInsets.only(left: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: Center(
                  child: Icon(
                    faf.FontAwesomeIcons.facebookF.data,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                label: Text(''),
              ),
            ),
          ),
          Tooltip(
            message:
                // "Login Via Google",
                context.tr(
                  shared.LocaleKeys.loginViaGoogleTooltip,
                  track: shared.TrackConstants.loginPageTrack,
                ) ??
                'Login Via Google',
            waitDuration: const Duration(seconds: 1),
            showDuration: const Duration(seconds: 2),
            padding: EdgeInsets.all(10),
            preferBelow: true,
            child: shared.HoverUpDownWidget(
              animationDuration: const Duration(milliseconds: 1800),
              childWidget: ElevatedButton.icon(
                onPressed: () => _handleGoogleSignIn(context),
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: EdgeInsets.only(left: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: Center(
                  child: Icon(
                    faf.FontAwesomeIcons.google.data,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                label: Text(''),
              ),
            ),
          ),
          Tooltip(
            message:
                // "Login Via Phone Number",
                context.tr(
                  shared.LocaleKeys.loginViaPhoneNumberTooltip,
                  track: shared.TrackConstants.loginPageTrack,
                ) ??
                'Login Via Phone Number',
            waitDuration: const Duration(seconds: 1),
            showDuration: const Duration(seconds: 2),
            padding: EdgeInsets.all(10),
            preferBelow: true,
            child: shared.HoverUpDownWidget(
              animationDuration: const Duration(milliseconds: 2000),
              childWidget: ElevatedButton.icon(
                onPressed: () async {
                  context.push(
                    AppRoutePath.loginViaPhoneNumberRoute,
                    extra: true,
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 3,
                  padding: EdgeInsets.only(left: 8),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: Center(
                  child: Icon(
                    Icons.smartphone_sharp,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                label: Text(''),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn(final BuildContext context) async {
    try {
      /*  GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        GoogleSignInAuthentication? googleAuth = await googleUser!.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );*/

      // Use the `credential` to sign in to your app.
      // For example, you can use FirebaseAuth to sign in the user:
      // final User user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    } catch (error) {
      ScaffoldMessenger.of(context)
        ..removeCurrentMaterialBanner()
        ..showMaterialBanner(
          MaterialBanner(
            content: Text(
              context.tr(
                    shared.LocaleKeys.loginGoogleLoginError,
                    track: shared.TrackConstants.loginPageTrack,
                  ) ??
                  'Unable to SignIn with google!',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                child: Text(
                  context.tr(
                        shared.LocaleKeys.commonDismiss,
                        track: shared.TrackConstants.commonTrack,
                      ) ??
                      'DISMISS',
                ),
              ),
            ],
          ),
        );
    }
  }
}
