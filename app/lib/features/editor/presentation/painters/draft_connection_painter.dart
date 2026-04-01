import 'package:flutter/material.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/painter_helper.dart';

class DraftConnectionPainter extends CustomPainter {
  final NodeModel fromNode;
  final String fromPin;
  final Offset draftingPos;

  const DraftConnectionPainter(this.fromNode, this.fromPin, this.draftingPos);

  @override
  void paint(Canvas canvas, Size size) {
    final outIndex = fromNode.outputs.indexOf(fromPin);
    final p1 = PainterHelper.getPinOffsetForSourceNode(fromNode, outIndex);

    final draftPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      PainterHelper.createBezierPath(p1, draftingPos),
      draftPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DraftConnectionPainter oldDelegate) {
    return oldDelegate.draftingPos != draftingPos ||
        oldDelegate.fromNode.position != fromNode.position ||
        oldDelegate.fromPin != fromPin;
  }
}
