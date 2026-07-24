import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../../gen/assets.gen.dart' as asts;

class ErrorPage extends StatefulWidget {
  const ErrorPage({required this.onPressedRetryButton, super.key});
  final GestureTapCallback? onPressedRetryButton;

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ErrorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: shared.ResponsiveLayout(
          mobile: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: lottie.Lottie.asset(
                    asts.Assets.lottie.errorLoader,

                    width: MediaQuery.sizeOf(context).width * 0.65,
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onPressedRetryButton,
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.commonRetry,
                          track: shared.TrackConstants.errorMsgTrack,
                        ) ??
                        'Retry',
                  ),
                ),
              ],
            ),
          ),
          tablet: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: lottie.Lottie.asset(
                    asts.Assets.lottie.errorLoader,
                    width: 250,
                    height: 300,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onPressedRetryButton,
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.commonRetry,
                          track: shared.TrackConstants.errorMsgTrack,
                        ) ??
                        'Retry',
                  ),
                ),
              ],
            ),
          ),
          desktop: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: lottie.Lottie.asset(
                    asts.Assets.lottie.errorLoader,
                    width: 250,
                    height: 300,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onPressedRetryButton,
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.commonRetry,
                          track: shared.TrackConstants.errorMsgTrack,
                        ) ??
                        'Retry',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
