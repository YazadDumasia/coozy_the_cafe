import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({required this.onPressedRetryButton, super.key});
  final GestureTapCallback? onPressedRetryButton;

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final ValueNotifier<bool> _isVisible = ValueNotifier(true);
  final double _animationThreshold = 0.65;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(_handleAnimationProgressChanged);
  }

  void _handleAnimationProgressChanged() {
    if (_controller.value >= _animationThreshold) {
      _isVisible.value = false;
    } else {
      _isVisible.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 360,
                    maxHeight: 280,
                  ),
                  child: Lottie.asset(
                    Assets.lottie.lostConnection,
                    controller: _controller,
                    fit: BoxFit.contain,
                    onLoaded: (composition) {
                      // Configure the AnimationController with the duration of the
                      // Lottie file and start the animation.
                      _controller
                        ..duration = composition.duration
                        ..forward()
                        ..repeat();
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: _isVisible,
                  builder: (context, isVisible, child) {
                    return Visibility(
                      visible: isVisible,
                      child: Text(
                        context.tr(
                              shared.LocaleKeys.commonNoInternetConnection,
                              track: shared.TrackConstants.commonTrack,
                            ) ??
                            'No Internet Connection',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.onPressedRetryButton,
                  child: Text(
                    context.tr(
                          shared.LocaleKeys.commonRetry,
                          track: shared.TrackConstants.commonTrack,
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

  @override
  void dispose() {
    _controller.dispose();
    _isVisible.dispose();
    super.dispose();
  }
}
