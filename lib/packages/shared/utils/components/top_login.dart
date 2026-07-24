import 'dart:ui' as ui;

import 'package:flutter/material.dart';

//Add this CustomPaint widget to the Widget Tree
// CustomPaint(
// size: Size(WIDTH, (WIDTH*1).toDouble()), //You can Replace [WIDTH] with your desired width for Custom Paint and height will be calculated automatically
// painter: TopLoginCustomPainter(),
// );

//Copy this CustomPainter code to the Bottom of the File
class TopLoginCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path_0 = Path();
    path_0.moveTo(size.width * 0.08500000, size.height * -0.1340000);
    path_0.cubicTo(
      size.width * 0.1270000,
      size.height * -0.1240000,
      size.width * 0.1890000,
      size.height * -0.1340000,
      size.width * 0.2430000,
      size.height * -0.1160000,
    );
    path_0.cubicTo(
      size.width * 0.2960000,
      size.height * -0.09700000,
      size.width * 0.3400000,
      size.height * -0.04800000,
      size.width * 0.3360000,
      size.height * -0.003000000,
    );
    path_0.cubicTo(
      size.width * 0.3310000,
      size.height * 0.04300000,
      size.width * 0.2780000,
      size.height * 0.08700000,
      size.width * 0.2420000,
      size.height * 0.1350000,
    );
    path_0.cubicTo(
      size.width * 0.2050000,
      size.height * 0.1830000,
      size.width * 0.1860000,
      size.height * 0.2350000,
      size.width * 0.1480000,
      size.height * 0.2790000,
    );
    path_0.cubicTo(
      size.width * 0.1110000,
      size.height * 0.3230000,
      size.width * 0.05500000,
      size.height * 0.3590000,
      size.width * 0.01800000,
      size.height * 0.3280000,
    );
    path_0.cubicTo(
      size.width * -0.02000000,
      size.height * 0.2970000,
      size.width * -0.04000000,
      size.height * 0.2000000,
      size.width * -0.05800000,
      size.height * 0.1450000,
    );
    path_0.cubicTo(
      size.width * -0.07600000,
      size.height * 0.08900000,
      size.width * -0.09200000,
      size.height * 0.07600000,
      size.width * -0.1050000,
      size.height * 0.05900000,
    );
    path_0.cubicTo(
      size.width * -0.1190000,
      size.height * 0.04100000,
      size.width * -0.1300000,
      size.height * 0.02100000,
      size.width * -0.1290000,
      size.height * 0.001000000,
    );
    path_0.cubicTo(
      size.width * -0.1280000,
      size.height * -0.01900000,
      size.width * -0.1150000,
      size.height * -0.03900000,
      size.width * -0.1060000,
      size.height * -0.06400000,
    );
    path_0.cubicTo(
      size.width * -0.09700000,
      size.height * -0.09000000,
      size.width * -0.09200000,
      size.height * -0.1210000,
      size.width * -0.07600000,
      size.height * -0.1460000,
    );
    path_0.cubicTo(
      size.width * -0.05900000,
      size.height * -0.1710000,
      size.width * -0.02900000,
      size.height * -0.1890000,
      size.width * -0.004000000,
      size.height * -0.1830000,
    );
    path_0.cubicTo(
      size.width * 0.02200000,
      size.height * -0.1760000,
      size.width * 0.04400000,
      size.height * -0.1450000,
      size.width * 0.08500000,
      size.height * -0.1340000,
    );
    path_0.close();

    final Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.shader = ui.Gradient.linear(
      Offset(0, size.height * 0.01000000),
      Offset(size.width * 0.01000000, 0),
      <ui.Color>[
        const Color.fromRGBO(248, 117, 55, 1),
        const Color.fromRGBO(251, 168, 31, 1),
      ],
      <double>[0, 1],
    );
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
