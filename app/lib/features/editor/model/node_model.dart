import 'package:flutter/material.dart';

class NodeModel {
  const NodeModel({required this.id, required this.name, required this.position});

  final String id;
  final String name;
  final Offset position;
  final Size size = const Size(200, 110);

  NodeModel copyWith({String? name, Offset? position}) {
    return NodeModel(
      id: id,
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }
}
