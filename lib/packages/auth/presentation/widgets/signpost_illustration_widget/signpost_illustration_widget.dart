import 'package:flutter/material.dart';

/// A custom-painted hand-drawn signpost illustration matching the
/// "Forgot your password?" mockup design.
class SignpostIllustrationWidget extends StatelessWidget {
  const SignpostIllustrationWidget({
    super.key,
    this.width = 130,
    this.height = 110,
    this.strokeColor,
  });

  final double width;
  final double height;
  final Color? strokeColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        strokeColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withAlpha(220)
            : const Color(0xFF2D2D2D));

    return Center(
      child: CustomPaint(
        size: Size(width, height),
        painter: _SignpostPainter(color: effectiveColor),
      ),
    );
  }
}

class _SignpostPainter extends CustomPainter {
  final Color color;

  _SignpostPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shadowPaint = Paint()
      ..color = color.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // --- Sign Board (Arrow pointing right) ---
    // Sign coordinates
    final double signLeft = w * 0.46;
    final double signRight = w * 0.76;
    final double signTop = h * 0.16;
    final double signBottom = h * 0.38;
    final double arrowTipX = w * 0.84;
    final double arrowTipY = (signTop + signBottom) / 2;

    final Path signPath = Path()
      ..moveTo(signLeft, signTop)
      ..lineTo(signRight, signTop)
      ..lineTo(arrowTipX, arrowTipY)
      ..lineTo(signRight, signBottom)
      ..lineTo(signLeft, signBottom)
      ..close();

    canvas.drawPath(signPath, strokePaint);

    // Two horizontal lines inside the sign
    final double lineStart = signLeft + 8;
    final double lineEnd = signRight - 4;
    final double lineY1 = signTop + (signBottom - signTop) * 0.38;
    final double lineY2 = signTop + (signBottom - signTop) * 0.65;

    canvas.drawLine(
      Offset(lineStart + 2, lineY1),
      Offset(lineEnd - 6, lineY1),
      strokePaint..strokeWidth = 1.8,
    );
    canvas.drawLine(
      Offset(lineStart + 2, lineY2),
      Offset(lineEnd - 4, lineY2),
      strokePaint,
    );

    // Reset stroke width
    strokePaint.strokeWidth = 2.2;

    // --- Vertical Post ---
    final double postX1 = w * 0.50;
    final double postX2 = w * 0.54;
    final double postTop = h * 0.12;
    final double postBottom = h * 0.68;

    // Post top small cap
    canvas.drawLine(
      Offset(postX1, postTop),
      Offset(postX2, postTop),
      strokePaint,
    );
    canvas.drawLine(
      Offset(postX1, postTop),
      Offset(postX1, signTop),
      strokePaint,
    );
    canvas.drawLine(
      Offset(postX2, postTop),
      Offset(postX2, signTop),
      strokePaint,
    );

    // Post body below the sign
    canvas.drawLine(
      Offset(postX1, signBottom),
      Offset(postX1, postBottom),
      strokePaint,
    );
    canvas.drawLine(
      Offset(postX2, signBottom),
      Offset(postX2, postBottom),
      strokePaint,
    );

    // --- Ground Line & Shadow ---
    // Ground curve
    final Path groundPath = Path()
      ..moveTo(w * 0.32, h * 0.72)
      ..quadraticBezierTo(w * 0.42, h * 0.73, w * 0.52, h * 0.70)
      ..lineTo(w * 0.72, h * 0.69);
    canvas.drawPath(groundPath, strokePaint..strokeWidth = 2.0);

    // Shadow below post
    final Path shadowPath = Path()
      ..moveTo(w * 0.48, h * 0.69)
      ..lineTo(w * 0.68, h * 0.68);
    canvas.drawPath(shadowPath, shadowPaint);

    // --- Grass Tufts ---
    // Left grass blade
    final Path grassLeft = Path()
      ..moveTo(w * 0.38, h * 0.64)
      ..quadraticBezierTo(w * 0.40, h * 0.61, w * 0.39, h * 0.58);
    canvas.drawPath(grassLeft, strokePaint..strokeWidth = 1.6);

    final Path grassLeft2 = Path()
      ..moveTo(w * 0.40, h * 0.64)
      ..quadraticBezierTo(w * 0.42, h * 0.62, w * 0.43, h * 0.59);
    canvas.drawPath(grassLeft2, strokePaint);

    // Right grass blade
    final Path grassRight = Path()
      ..moveTo(w * 0.63, h * 0.62)
      ..quadraticBezierTo(w * 0.64, h * 0.59, w * 0.65, h * 0.57);
    canvas.drawPath(grassRight, strokePaint);

    final Path grassRight2 = Path()
      ..moveTo(w * 0.65, h * 0.62)
      ..quadraticBezierTo(w * 0.67, h * 0.60, w * 0.68, h * 0.58);
    canvas.drawPath(grassRight2, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SignpostPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
