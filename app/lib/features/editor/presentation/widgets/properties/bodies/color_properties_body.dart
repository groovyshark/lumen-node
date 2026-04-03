import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';

class ColorPropertiesBody extends ConsumerWidget {
  final NodeModel node;

  const ColorPropertiesBody({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _inspectorSlider(ref, node.id, "R", "r", node.parameters["r"] ?? 1.0),
        _inspectorSlider(ref, node.id, "G", "g", node.parameters["g"] ?? 1.0),
        _inspectorSlider(ref, node.id, "B", "b", node.parameters["b"] ?? 1.0),
        _inspectorSlider(ref, node.id, "A", "a", node.parameters["a"] ?? 1.0),
      ],
    );
  }

  Widget _inspectorSlider(
    WidgetRef ref,
    String nodeId,
    String label,
    String paramKey,
    double value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onPanUpdate: (d) {
              double newValue = (value + (d.delta.dx * 0.05)).clamp(0.0, 1.0);
              ref
                  .read(editorProvider.notifier)
                  .updateNodeParameter(nodeId, paramKey, newValue);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  children: [
                    Container(
                      width:
                          280 *
                          value,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
