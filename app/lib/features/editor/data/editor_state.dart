import 'package:flutter/material.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';

@immutable
class EditorState {
  final List<NodeModel> nodes;
  final String shaderCode;

  const EditorState({
    this.nodes = const [],
    this.shaderCode = '',
  });

  EditorState copyWith({
    List<NodeModel>? nodes,
    String? shaderCode,
  }) {
    return EditorState(
      nodes: nodes ?? this.nodes,
      shaderCode: shaderCode ?? this.shaderCode,
    );
  }
}