import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';

class BasePropertiesWrapper extends ConsumerWidget {
  final NodeModel node;
  final Widget child;

  const BasePropertiesWrapper({
    super.key,
    required this.node,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "PARAMETERS",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: Center(child: child)),
        ],
      ),
    );
  }
}
