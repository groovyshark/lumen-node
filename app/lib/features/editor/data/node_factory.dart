import 'package:flutter/material.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';

typedef NodeBuilder =
    NodeModel Function(String id, NodeType type, Offset position);

class NodeFactory {
  static final Map<NodeType, NodeBuilder> _registry = {
    NodeType.color: (id, type, position) => NodeModel.base(id, type, position).copyWith(
      name: "Color Node",
      inputs: [],
      outputs: ["output"],
      parameters: {"r": 1.0, "g": 1.0, "b": 1.0, "a": 1.0},
    ),
    NodeType.multiply: (id, type, position) => NodeModel.base(id, type, position).copyWith(
      name: "Multiply Node",
      inputs: ["a", "b"],
      outputs: ["output"],
    ),
    NodeType.add: (id, type, position) => NodeModel.base(id, type, position).copyWith(
      name: "Add Node",
      inputs: ["a", "b"],
      outputs: ["output"],
    ),
    NodeType.master: (id, type, position) => NodeModel.base(id, type, position).copyWith(
      name: "FRAGMENT OUTPUT",
      inputs: ["color"],
      outputs: [],
    ),
  };

  static NodeModel create(String id, NodeType type, Offset position) {
    final builder = _registry[type];

    if (builder == null) {
      throw Exception("No builder registered for node type: $type");
    }

    return builder(id, type, position);
  }
}
