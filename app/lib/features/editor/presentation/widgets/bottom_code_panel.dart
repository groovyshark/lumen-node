import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';

class BottomCodePanel extends ConsumerWidget {
  const BottomCodePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(editorProvider.select((s) => s.shaderCode));

    return Container(
      height: 200,
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceContainerHigh,
            child: Row(
              children: [
                Text("GLSL GENERATED SOURCE", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.onSurface)),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                  child: Text("FRAGMENT", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF004A5D))),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                code.isEmpty ? "// Add nodes to generate code..." : code,
                style: GoogleFonts.firaCode(fontSize: 12, color: AppColors.secondary, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}