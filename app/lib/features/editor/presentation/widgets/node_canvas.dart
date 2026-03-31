import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';

class NodeCanvas extends ConsumerWidget {
  const NodeCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    return GestureDetector(
      onDoubleTapDown: (d) => notifier.addColorNode(d.localPosition),
      child: Container(
        color: const Color(0xFF1A1A1A),
        child: Stack(
          children: [
            ...editorState.nodes.map((node) => Positioned(
              left: node.position.dx,
              top: node.position.dy,
              child: _NodeWidget(node: node),
            )),
          ],
        ),
      ),
    );
  }
}

class _NodeWidget extends ConsumerWidget {
  final NodeModel node;
  const _NodeWidget({required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onPanUpdate: (d) => ref.read(editorProvider.notifier)
          .updateNodePosition(node.id, d.delta),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blueAccent.withValues(alpha:  0.5)),
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withValues(alpha: 0.3))],
        ),
        child: Text(node.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}