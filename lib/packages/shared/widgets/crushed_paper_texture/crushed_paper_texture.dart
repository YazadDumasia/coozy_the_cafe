import 'package:flutter/material.dart';

class CrushedPaperTexture extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final Path path = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.8, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.8,
        size.width * 0.2,
        size.height,
      )
      ..lineTo(0, size.height)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/*
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 5,
        spreadRadius: 1,
      ),
    ],
  ),
  child: CustomPaint(
    size: Size.infinite,
    painter: CrushedPaperTexture(),
  ),
);
* */
