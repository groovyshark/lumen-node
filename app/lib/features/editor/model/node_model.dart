import 'package:flutter/material.dart';

import 'package:lumen_node_app/generated_bindings.dart';

enum NodeType {
  color(ENodeType.NODE_TYPE_COLOR),
  multiply(ENodeType.NODE_TYPE_MULTIPLY),
  add(ENodeType.NODE_TYPE_ADD),
  uv(ENodeType.NODE_TYPE_UV),
  time(ENodeType.NODE_TYPE_TIME),
  normal(ENodeType.NODE_TYPE_NORMAL),

  master(ENodeType.NODE_TYPE_MASTER);

  final ENodeType nativeValue;
  const NodeType(this.nativeValue);
}

class NodeModel {
  const NodeModel({
    required this.id,
    required this.name,
    required this.position,
    required this.type,
    required this.inputs,
    required this.outputs,
    this.size = const Size(200, 140),
    this.parameters = const {},
  });

  NodeModel.base(
    String id,
    NodeType type,
    Offset position, {
    String? name,
    List<String>? inputs,
    List<String>? outputs,
    Map<String, double>? parameters,
  }) : this(
         id: id,
         type: type,
         position: position,
         name: name ?? "New Node",
         inputs: inputs ?? const [],
         outputs: outputs ?? const [],
         parameters: parameters ?? const {},
       );

  NodeModel copyWith({
    String? name,
    Offset? position,
    Size? size,
    List<String>? inputs,
    List<String>? outputs,

    Map<String, double>? parameters,
  }) {
    return NodeModel(
      id: id,
      name: name ?? this.name,
      position: position ?? this.position,
      type: type,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      size: size ?? this.size,
      parameters: parameters ?? this.parameters,
    );
  }

  final String id;
  final String name;

  final NodeType type;
  final Offset position;

  final List<String> inputs;
  final List<String> outputs;

  final Size size;

  final Map<String, double> parameters;
}
