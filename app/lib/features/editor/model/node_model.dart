import 'package:flutter/material.dart';

enum NodeType { color, add, multiply, master }

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

  final String id;
  final String name;

  final NodeType type;
  final Offset position;

  final List<String> inputs;
  final List<String> outputs;

  final Size size;

  final Map<String, double> parameters;

  NodeModel copyWith({String? name, Offset? position, Map<String, double>? parameters}) {
    return NodeModel(
      id: id,
      name: name ?? this.name,
      position: position ?? this.position,
      type: type,
      inputs: inputs,
      outputs: outputs,
      size: size,
      parameters: parameters ?? this.parameters,
    );
  }
}
