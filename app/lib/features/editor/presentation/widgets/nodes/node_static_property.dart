import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';

class NodeStaticProperty extends StatelessWidget {
  final String name;
  final String value;

  const NodeStaticProperty({super.key, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.firaCode(fontSize: 10, color: AppColors.primary),
        ),
      ],
    );
  }
}
