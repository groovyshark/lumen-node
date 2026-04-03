import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/app/theme/app_theme.dart';


class ColorNodeBody extends ConsumerWidget {
  final NodeModel node;

  const ColorNodeBody({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _staticProperty("R:", node.parameters["r"] ?? 1.0),
          _staticProperty("G:", node.parameters["g"] ?? 1.0),
          _staticProperty("B:", node.parameters["b"] ?? 1.0),
          _staticProperty("A:", node.parameters["a"] ?? 1.0),
        ],
      ),
    );
  }

  Widget _staticProperty(String label, double value) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Занимает минимум места
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value.toStringAsFixed(2),
          style: GoogleFonts.firaCode(fontSize: 10, color: AppColors.primary),
        ),
      ],
    );
  }
}
