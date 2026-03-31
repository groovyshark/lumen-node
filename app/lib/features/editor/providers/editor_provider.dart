import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

import 'package:lumen_node_app/core/providers/lumen_provider.dart';
import 'package:lumen_node_app/features/editor/data/editor_state.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/model/connection_model.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/painter_helper.dart';

part 'editor_provider.g.dart';

@riverpod
class Editor extends _$Editor {
  @override
  EditorState build() {
    ref.watch(lumenEngineProvider);
    return const EditorState();
  }

  void addColorNode(Offset position) {
    final engine = ref.read(lumenEngineProvider);
    final id = "node_${state.nodes.length}";

    engine.addColorNode(id);

    state = state.copyWith(
      nodes: [
        ...state.nodes,
        NodeModel(id: id, name: "Color Node", position: position),
      ],
      shaderCode: engine.compile(),
    );
  }

  void renameNode(String id, String newName) {
    state = state.copyWith(
      nodes: state.nodes
          .map((node) => node.id == id ? node.copyWith(name: newName) : node)
          .toList(),
    );
  }

  void updateNodePosition(String id, Offset delta) {
    state = state.copyWith(
      nodes: state.nodes
          .map(
            (node) => node.id == id
                ? node.copyWith(position: node.position + delta)
                : node,
          )
          .toList(),
    );
  }

  void startDraftingConnection(String nodeId, Offset startPos) {
    state = state.copyWith(draftingNodeId: nodeId, draftingPos: startPos);
  }

  void updateDraftingConnection(Offset pos) {
    if (state.draftingNodeId != null) {
      state = state.copyWith(draftingPos: pos);
    }
  }

  void endDraftingConnection() {
    if (state.draftingNodeId == null || state.draftingPos == null) {
      state = state.copyWith(clearDraft: true);
      return;
    }

    final dropPos = state.draftingPos!;

    final targetNode = state.nodes.where((n) {
      if (n.id == state.draftingNodeId) return false;

      final rect = Rect.fromLTWH(
        n.position.dx,
        n.position.dy,
        n.size.width,
        n.size.height,
      );
      return rect.contains(dropPos);
    }).firstOrNull;

    if (targetNode != null) {
      state = state.copyWith(
        connections: [
          ...state.connections,
          ConnectionModel(state.draftingNodeId!, targetNode.id),
        ],
        clearDraft: true,
      );
      // TODO: Call C++ for connecting nodes: engine.connectNodes(...)
    } else {
      state = state.copyWith(clearDraft: true);
    }
  }

  void tryDeleteConnectionAt(Offset clickPos) {
    const hitTolerance = 15.0;

    ConnectionModel? connectionToRemove;

    for (final c in state.connections) {
      final fromNode = state.nodes.firstWhere((n) => n.id == c.fromNodeId);
      final toNode = state.nodes.firstWhere((n) => n.id == c.toNodeId);

      final p1 = PainterHelper.getOffsetForSourceNode(fromNode);
      final p2 = Offset(toNode.position.dx, toNode.position.dy + 32);
      final path = PainterHelper.createBezierPath(p1, p2);

      if (_isPointNearPath(clickPos, path, hitTolerance)) {
        connectionToRemove = c;
        break;
      }
    }

    if (connectionToRemove != null) {
      state = state.copyWith(
        connections: state.connections
            .where((c) => c != connectionToRemove)
            .toList(),
      );

      // TODO: Call C++ to disconnect nodes if needed
      // engine.disconnectNodes(connectionToRemove.fromNodeId, connectionToRemove.toNodeId);
    }
  }

  bool _isPointNearPath(Offset point, Path path, double tolerance) {
    final metrics = path.computeMetrics();

    const step = 10.0;
    for (final metric in metrics) {
      for (double i = 0; i < metric.length; i += step) {
        final tangent = metric.getTangentForOffset(i);
        
        if (tangent != null) {
          final distance = (tangent.position - point).distance;

          if (distance <= tolerance) {
            return true; 
          }
        }
      }
    }
    return false;
  }
}
