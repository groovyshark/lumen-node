import 'package:flutter/material.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/model/connection_model.dart';

@immutable
class EditorState {
  final List<NodeModel> nodes;
  final List<ConnectionModel> connections;
  final String shaderCode;

  final String? draftingNodeId;
  final Offset? draftingPos;

  const EditorState({
    this.nodes = const [],
    this.connections = const [],
    this.shaderCode = '',
    this.draftingNodeId,
    this.draftingPos,
  });

  EditorState copyWith({
    List<NodeModel>? nodes,
    List<ConnectionModel>? connections,
    String? shaderCode,
    String? draftingNodeId,
    Offset? draftingPos,
    bool clearDraft = false,
  }) {
    return EditorState(
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      shaderCode: shaderCode ?? this.shaderCode,
      draftingNodeId: clearDraft ? null : (draftingNodeId ?? this.draftingNodeId),
      draftingPos: clearDraft ? null : (draftingPos ?? this.draftingPos),
    );
  }
}