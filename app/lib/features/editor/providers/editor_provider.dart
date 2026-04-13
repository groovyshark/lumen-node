import 'dart:async';

import 'package:lumen_node_app/features/editor/data/node_factory.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lumen_node_app/core/providers/lumen_provider.dart';
import 'package:lumen_node_app/features/editor/data/editor_state.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/model/connection_model.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/painter_helper.dart';

part 'editor_provider.g.dart';

@riverpod
class Editor extends _$Editor {
  static const _rendererChannel = MethodChannel('lumen/renderer');

  Timer? _renderLoop;

  void _syncShaderCode() async {
    final engine = ref.read(lumenEngineProvider);
    final newCode = engine.compile();
    
    state = state.copyWith(shaderCode: newCode);
    
    try {
      await _rendererChannel.invokeMethod('updateShader', {'code': newCode});
    } catch (e) {
      rethrow;
    }

    _updateRenderLoop();
  }

  void _initRenderer() async {
    try {
      final id = await _rendererChannel.invokeMethod<int>('getTextureId');
      
      if (id != null) {
        state = state.copyWith(textureId: id);
        
        _syncShaderCode();
      }
    } catch (e) {
      rethrow;
    }
  }

  // @override
  // void dispose() {
  //   _renderLoop?.cancel();

  //   super.dispose();
  // }

  void _updateRenderLoop() {
    final hasTimeNode = state.nodes.any((node) => node.type == NodeType.time);

    if (hasTimeNode) {
      if (_renderLoop == null || !_renderLoop!.isActive) {
        _renderLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
          _rendererChannel.invokeMethod('requestFrame');
        });
      }
    } else {
      if (_renderLoop != null && _renderLoop!.isActive) {
        _renderLoop?.cancel();
        _renderLoop = null;
      }
    }
  }

  @override
  EditorState build() {
    ref.watch(lumenEngineProvider);

    Future.microtask(() => _initRenderer());

    return EditorState(
      nodes: [
        NodeFactory.create('master', NodeType.master, const Offset(600, 300))
      ]
    );
  }

  void spawnNode(NodeType type, Offset position) {
    final engine = ref.read(lumenEngineProvider);
    final id = "node_${state.nodes.length}";

    NodeModel newNode = NodeFactory.create(id, type, position);
    engine.addNode(id, type);

    state = state.copyWith(
      nodes: [...state.nodes, newNode],
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

    _syncShaderCode();
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

      _syncShaderCode();
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
      
      _syncShaderCode();
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
