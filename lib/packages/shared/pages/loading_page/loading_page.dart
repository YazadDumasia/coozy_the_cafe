import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatefulWidget {
  /// When `true`, renders only the Lottie animation centered without
  /// Scaffold/SafeArea, suitable for dialogs, sheets, and inline loading.
  /// When `false` (default), wraps in a full Scaffold for route-level usage.
  final bool isEmbedded;

  const LoadingPage({super.key, this.isEmbedded = false});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
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
  void didUpdateWidget(covariant LoadingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return _buildLoadingContent(
        context,
        maxWidth: MediaQuery.of(context).size.width * .65,
        maxHeight: 120,
      );
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: OrientationBuilder(
          builder: (context, orientation) {
            if (orientation == Orientation.portrait) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Lottie.asset(
                        Assets.lottie.loading,
                        fit: BoxFit.scaleDown,
                        width: MediaQuery.of(context).size.width * .65,
                        // height: MediaQuery.of(context).size.height * .5,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Lottie.asset(
                        Assets.lottie.loading,
                        fit: BoxFit.scaleDown,
                        width: MediaQuery.of(context).size.width * .65,
                        height: MediaQuery.of(context).size.height * .45,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingContent(
    BuildContext context, {
    double maxWidth = 120,
    double maxHeight = 120,
  }) {
    return Center(
      child: Lottie.asset(
        Assets.lottie.loading,
        fit: BoxFit.contain,
        width: maxWidth,
        height: maxHeight,
      ),
    );
  }
}
