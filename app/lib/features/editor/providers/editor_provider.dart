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
    return EditorState(
      nodes: [
        NodeModel(
          id: "master", 
          name: "FRAGMENT OUTPUT", 
          type: NodeType.master, 
          position: const Offset(600, 300), // Справа по умолчанию
          inputs: ["color"], 
          outputs: [] // Выходов нет
        )
      ]
    );
  }

  NodeModel _initNode(
    String id,
    String name,
    NodeType type,
    Offset position,
    List<String> inputs,
    List<String> outputs, {
    Map<String, double> parameters = const {},
  }) {
    return NodeModel(
      id: id,
      name: name,
      position: position,
      type: type,
      inputs: inputs,
      outputs: outputs,
      parameters: parameters,
    );
  }

  void spawnNode(NodeType type, Offset position) {
    final engine = ref.read(lumenEngineProvider);
    final id = "node_${state.nodes.length}";

    NodeModel? newNode;
    switch (type) {
      case NodeType.color:
        newNode = _initNode(
          id,
          "Color Node",
          type,
          position,
          [],
          ["output"],
          parameters: {"r": 1.0, "g": 1.0, "b": 1.0, "a": 1.0},
        );
        engine.addColorNode(id);
        break;
      case NodeType.multiply:
        newNode = _initNode(
          id,
          "Multiply Node",
          type,
          position,
          ["a", "b"],
          ["output"],
        );
        engine.addMultiplyNode(id);
        break;
      case NodeType.master:
        break;
    }

    state = state.copyWith(
      nodes: [...state.nodes, newNode!],
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

  void selectNode(String? id) {
    state = state.copyWith(selectedNodeId: id, clearSelection: id == null);
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

  void updateNodeParameter(String nodeId, String paramName, double value) {
    state = state.copyWith(
      nodes: state.nodes.map((n) {
        if (n.id == nodeId) {
          final newParams = Map<String, double>.from(n.parameters);
          newParams[paramName] = value;
          return n.copyWith(parameters: newParams);
        }
        return n;
      }).toList(),
    );

    final engine = ref.read(lumenEngineProvider);
    engine.setNodeParameter(nodeId, paramName, value);

    state = state.copyWith(shaderCode: engine.compile());
  }

  void startDraftingConnection(String nodeId, String pinName, Offset startPos) {
    state = state.copyWith(
      draftingNodeId: nodeId,
      draftingPinName: pinName,
      draftingPos: startPos,
    );
  }

  void updateDraftingConnection(Offset pos) {
    if (state.draftingNodeId != null) {
      state = state.copyWith(draftingPos: pos);
    }
  }

  void endDraftingConnection() {
    final fromNodeId = state.draftingNodeId;
    final fromPinName = state.draftingPinName;
    final dropPos = state.draftingPos;

    if (fromNodeId == null || fromPinName == null || dropPos == null) {
      state = state.copyWith(clearDraft: true);
      return;
    }

    final targetNode = state.nodes.where((n) {
      if (n.id == fromNodeId) return false;
      final rect = Rect.fromLTWH(
        n.position.dx,
        n.position.dy,
        n.size.width,
        n.size.height,
      );
      return rect.contains(dropPos);
    }).firstOrNull;


    if (targetNode != null && targetNode.inputs.isNotEmpty) {
      final relativeY = dropPos.dy - targetNode.position.dy;
      final pinIndex =
          (relativeY / (targetNode.size.height / targetNode.inputs.length))
              .floor()
              .clamp(0, targetNode.inputs.length - 1);

      final targetPinName = targetNode.inputs[pinIndex];

      state = state.copyWith(
        connections: [
          ...state.connections,
          ConnectionModel(
            fromNodeId,
            fromPinName,
            targetNode.id,
            targetPinName,
          ),
        ],
        clearDraft: true,
      );

      final engine = ref.read(lumenEngineProvider);
      engine.connect(fromNodeId, fromPinName, targetNode.id, targetPinName);

      state = state.copyWith(shaderCode: engine.compile());
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

      final outIndex = fromNode.outputs.indexOf(c.fromPin);
      final p1 = PainterHelper.getPinOffsetForSourceNode(fromNode, outIndex);

      final inIndex = toNode.inputs.indexOf(c.toPin);
      final p2 = PainterHelper.getPinOffsetForTargetNode(toNode, inIndex);
      
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

      final engine = ref.read(lumenEngineProvider);
      engine.disconnect(connectionToRemove.toNodeId, connectionToRemove.toPin);
      state = state.copyWith(shaderCode: engine.compile());
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
