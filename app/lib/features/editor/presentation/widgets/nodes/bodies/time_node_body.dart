import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/providers/utime_provider.dart';
import 'package:lumen_node_app/features/editor/presentation/widgets/nodes/node_static_property.dart';

class TimeNodeBody extends ConsumerWidget {
  final NodeModel node;
  const TimeNodeBody({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = ref.watch(uTimeProvider);

    final sinValue = math.sin(time) * 0.5 + 0.5;
    final cosValue = math.cos(time) * 0.5 + 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          NodeStaticProperty(
            name: "Sin:",
            value: sinValue.toStringAsFixed(2),
          ),
          NodeStaticProperty(
            name: "Cos:",
            value: cosValue.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }
}
