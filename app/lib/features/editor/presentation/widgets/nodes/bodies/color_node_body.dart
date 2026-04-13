import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumen_node_app/features/editor/presentation/widgets/nodes/node_static_property.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/app/theme/app_theme.dart';

class ColorNodeBody extends ConsumerWidget {
  final NodeModel node;

  const ColorNodeBody({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = node.parameters["r"] ?? 1.0;
    final g = node.parameters["g"] ?? 1.0;
    final b = node.parameters["b"] ?? 1.0;
    final a = node.parameters["a"] ?? 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NodeStaticProperty(name: "R:", value: r.toStringAsFixed(2)),
              NodeStaticProperty(name: "G:", value: g.toStringAsFixed(2)),
              NodeStaticProperty(name: "B:", value: b.toStringAsFixed(2)),
              NodeStaticProperty(name: "A:", value: a.toStringAsFixed(2)),
            ],
          ),

          Container(
            margin: const EdgeInsets.only(top: 6.0),
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                (r * 255).toInt(),
                (g * 255).toInt(),
                (b * 255).toInt(),
                a,
              ),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
