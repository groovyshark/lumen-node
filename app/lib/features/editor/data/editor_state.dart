import 'package:flutter/material.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/model/connection_model.dart';

@immutable
class EditorState {
  final List<NodeModel> nodes;
  final List<ConnectionModel> connections;
  final String shaderCode;

  final String? selectedNodeId;

  final String? draftingNodeId;
  final String? draftingPinName;
  final Offset? draftingPos;

  const EditorState({
    this.nodes = const [],
    this.connections = const [],
    this.shaderCode = '',
    this.selectedNodeId,
    this.draftingNodeId,
    this.draftingPinName,
    this.draftingPos,
  });

  EditorState copyWith({
    List<NodeModel>? nodes,
    List<ConnectionModel>? connections,
    String? shaderCode,
    String? selectedNodeId,
    String? draftingNodeId,
    String? draftingPinName,
    Offset? draftingPos,
    bool clearDraft = false,
    bool clearSelection = false,
  }) {
    return EditorState(
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      shaderCode: shaderCode ?? this.shaderCode,
      selectedNodeId: clearSelection ? null : (selectedNodeId ?? this.selectedNodeId),
      draftingNodeId: clearDraft ? null : (draftingNodeId ?? this.draftingNodeId),
      draftingPinName: clearDraft ? null : (draftingPinName ?? this.draftingPinName),
      draftingPos: clearDraft ? null : (draftingPos ?? this.draftingPos),
    );
  }
}