import 'package:flutter/material.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';

import 'base_node_wrapper.dart';
import 'node_bodies.dart';

typedef NodeBuilder = Widget Function(BuildContext context, NodeModel node);

class NodeWidgetFactory {
  static final Map<NodeType, NodeBuilder> _registry = {
    NodeType.color: (context, node) => ColorNodeBody(node: node),
    NodeType.multiply: (context, node) => MultiplyNodeBody(node: node),
    NodeType.add: (context, node) => AddNodeBody(node: node),
    NodeType.uv: (context, node) => UVNodeBody(node: node),
    NodeType.time: (context, node) => TimeNodeBody(node: node),
    NodeType.normal: (context, node) => NormalNodeBody(node: node),
    NodeType.texture: (context, node) => TextureNodeBody(node: node),

    NodeType.master: (context, node) => MasterNodeBody(node: node),
  };

  static Widget build(BuildContext context, NodeModel node) {
    final builder = _registry[node.type];
    
    if (builder == null) {
      return BaseNodeWrapper(
        node: node,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Unknown Node", style: TextStyle(color: Colors.red)),
        ),
      );
    }

    return BaseNodeWrapper(
      node: node,
      child: builder(context, node),
    );
  }
}