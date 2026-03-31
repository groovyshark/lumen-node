import 'package:flutter/material.dart';
import 'package:lumen_node_app/app/theme/app_theme.dart';

class CanvasGridPainter extends CustomPainter {
  const CanvasGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.surfaceContainerHighest;
    for (double x = 0; x < size.width; x += 32) {
      for (double y = 0; y < size.height; y += 32) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}