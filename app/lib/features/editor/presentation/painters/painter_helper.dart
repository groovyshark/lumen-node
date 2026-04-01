import 'package:flutter/material.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';

abstract class PainterHelper {
  static Path createBezierPath(Offset p1, Offset p2) {
    final path = Path();
    path.moveTo(p1.dx, p1.dy);

    final controlPointOffset = (p2.dx - p1.dx).abs() * 0.5;
    path.cubicTo(
      p1.dx + controlPointOffset, p1.dy,
      p2.dx - controlPointOffset, p2.dy,
      p2.dx, p2.dy,
    );
    return path;
  }

  static Offset getPinOffsetForSourceNode(NodeModel node, int outputIndex) {
    return Offset(
      node.position.dx + node.size.width - 12,
      node.position.dy + node.size.height - 18 - (outputIndex * 24),
    );
  }

  static Offset getPinOffsetForTargetNode(NodeModel node, int inputIndex) {
    return Offset(
      node.position.dx + 16,
      node.position.dy + 46 + (inputIndex * 20),
    );
  }
}