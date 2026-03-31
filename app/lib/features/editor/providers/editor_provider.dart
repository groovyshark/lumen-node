import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';

import 'package:lumen_node_app/core/providers/lumen_provider.dart';
import 'package:lumen_node_app/features/editor/data/editor_state.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';

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
      nodes: [...state.nodes, NodeModel(id, position)],
      shaderCode: engine.compile(),
    );
  }

  void updateNodePosition(String id, Offset delta) {
    state = state.copyWith(
      nodes: [
        for (final node in state.nodes)
          if (node.id == id)
            NodeModel(node.id, node.position + delta)
          else
            node,
      ],
    );
  }
}

