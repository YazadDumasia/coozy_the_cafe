import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart';

class SuccessfullyScreen extends StatefulWidget {
  final String redirectPath;

  const SuccessfullyScreen({super.key, required this.redirectPath});

  @override
  State<SuccessfullyScreen> createState() => _SuccessfullyScreenState();
}

class _SuccessfullyScreenState extends State<SuccessfullyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double lottieDimension = 200.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lottieAsset = isDark
        ? Assets.lottie.successDark
        : Assets.lottie.successLight;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        body: AnimateGradient(
          primaryBegin: Alignment.topLeft,
          primaryEnd: Alignment.bottomLeft,
          secondaryBegin: Alignment.bottomLeft,
          secondaryEnd: Alignment.topRight,
          duration: const Duration(seconds: 2),
          primaryColors: const <Color>[
            Color.fromRGBO(225, 109, 245, 1),
            Color.fromRGBO(78, 248, 231, 1),
            // Color.fromRGBO(99, 251, 215, 1),
            // Color.fromRGBO(83, 138, 214, 1)
          ],
          secondaryColors: const <Color>[
            Color.fromRGBO(5, 222, 250, 1),
            Color.fromRGBO(134, 231, 214, 1),
          ],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  lottieAsset,
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward().whenComplete(() {
                        // Navigate to home screen after animation completes
                        if (mounted) {
                          context.go(widget.redirectPath);
                        }
                      });
                  },
                  width: lottieDimension,
                  height: lottieDimension,
                  repeat: false,
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr(
                        LocaleKeys.successfullyScreenSuccessfullyVerified,
                        track: TrackConstants.successfullyScreenTrack,
                      ) ??
                      'Successfully Verified!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
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
