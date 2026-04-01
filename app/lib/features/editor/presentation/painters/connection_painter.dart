import 'package:flutter/material.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/model/connection_model.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/painter_helper.dart';

class ConnectionPainter extends CustomPainter {
  final List<NodeModel> nodes;
  final List<ConnectionModel> connections;

  const ConnectionPainter(this.nodes, this.connections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final conn in connections) {
      final fromNode = nodes.firstWhere((n) => n.id == conn.fromNodeId);
      final toNode = nodes.firstWhere((n) => n.id == conn.toNodeId);

      final outIndex = fromNode.outputs.indexOf(conn.fromPin);
      final p1 = PainterHelper.getPinOffsetForSourceNode(fromNode, outIndex);

      final inIndex = toNode.inputs.indexOf(conn.toPin);
      final p2 = PainterHelper.getPinOffsetForTargetNode(toNode, inIndex);

      canvas.drawPath(PainterHelper.createBezierPath(p1, p2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    if (oldDelegate.connections.length != connections.length) return true;

    return _areConnectionsChanged(oldDelegate.nodes, nodes);
  }

  bool _areConnectionsChanged(
    List<NodeModel> oldNodes,
    List<NodeModel> newNodes,
  ) {
    for (int i = 0; i < oldNodes.length; i++) {
      if (oldNodes[i].position != newNodes[i].position) return true;
    }

    return false;
  }
}
