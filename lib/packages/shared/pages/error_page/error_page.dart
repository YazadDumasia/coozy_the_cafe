import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../../gen/assets.gen.dart' as asts;

class ErrorPage extends StatefulWidget {
  const ErrorPage({
    required this.onPressedRetryButton,
    this.errorMsg,
    super.key,
  });
  final GestureTapCallback? onPressedRetryButton;
  final String? errorMsg;

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 320,
                      maxHeight: 260,
                    ),
                    child: lottie.Lottie.asset(
                      asts.Assets.lottie.errorLoader,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.errorMsg?.isNotEmpty ?? false
                        ? widget.errorMsg ?? ''
                        : (context.tr(
                                shared.LocaleKeys.commonErrorMsg,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Something went wrong. Please try again.'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ).inExpandedRow(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  const SizedBox(height: 10),
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
          tablet: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 320,
                      maxHeight: 260,
                    ),
                    child: lottie.Lottie.asset(
                      asts.Assets.lottie.errorLoader,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.errorMsg?.isNotEmpty ?? false
                        ? widget.errorMsg ?? ''
                        : (context.tr(
                                shared.LocaleKeys.commonErrorMsg,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Something went wrong. Please try again.'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ).inExpandedRow(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  const SizedBox(height: 10),
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
          desktop: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 320,
                      maxHeight: 260,
                    ),
                    child: lottie.Lottie.asset(
                      asts.Assets.lottie.errorLoader,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.errorMsg?.isNotEmpty ?? false
                        ? widget.errorMsg ?? ''
                        : (context.tr(
                                shared.LocaleKeys.commonErrorMsg,
                                track: shared.TrackConstants.commonTrack,
                              ) ??
                              'Something went wrong. Please try again.'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ).inExpandedRow(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  const SizedBox(height: 10),
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
      ),
    );
  }
}
