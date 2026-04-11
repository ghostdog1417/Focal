import 'package:flutter/material.dart';

import '../theme/app_style.dart';

class FocusNestLogo extends StatelessWidget {
  const FocusNestLogo({
    super.key,
    this.size = 72,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    final Color outerColor = AppColors.primary;
    const Color innerColor = Colors.white;
    const Color strokeColor = Color(0xFF4C74DA);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [outerColor, outerColor.withAlpha(200)],
              ),
            ),
          ),
          Container(
            width: size * 0.68,
            height: size * 0.68,
            decoration: BoxDecoration(
              color: innerColor,
              shape: BoxShape.circle,
            ),
            child: CustomPaint(
              painter: _NestPainter(strokeColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _NestPainter extends CustomPainter {
  _NestPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // Nest arcs
    canvas.drawArc(
      Rect.fromLTWH(w * 0.14, h * 0.40, w * 0.72, h * 0.40),
      0.20,
      2.74,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.60, h * 0.32),
      0.24,
      2.58,
      false,
      paint,
    );

    // Focus check mark in the center
    final Path checkPath = Path()
      ..moveTo(w * 0.34, h * 0.45)
      ..lineTo(w * 0.46, h * 0.57)
      ..lineTo(w * 0.67, h * 0.35);
    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant _NestPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
