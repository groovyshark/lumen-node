import 'package:flutter/material.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';

import 'base_properties_wrapper.dart';
import 'bodies/color_properties_body.dart';
import 'bodies/texture_properties_body.dart';

typedef PropertiesBuilder = Widget Function(BuildContext context, NodeModel node);

class PropertiesWidgetFactory {
  static final Map<NodeType, PropertiesBuilder> _registry = {
    NodeType.color: (context, node) => ColorPropertiesBody(node: node),
    NodeType.texture: (context, node) => TexturePropertiesBody(node: node),
    // NodeType.multiply: (context, node) => MultiplyPropertiesBody(node: node),
    // NodeType.add: (context, node) => AddPropertiesBody(node: node),
    // NodeType.master: (context, node) => MasterPropertiesBody(node: node),
  };

  static Widget build(BuildContext context, NodeModel node) {
    final builder = _registry[node.type];
    
    if (builder == null) {
      return BasePropertiesWrapper(
        node: node,
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("No properties available", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return BasePropertiesWrapper(
      node: node,
      child: builder(context, node),
    );
  }
}