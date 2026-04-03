import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';
import 'properties/properties_widget_factory.dart';

class PropertiesInspector extends ConsumerWidget {
  const PropertiesInspector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final selectedNode = state.nodes
        .where((n) => n.id == state.selectedNodeId)
        .firstOrNull;

    return Container(
      width: 320,
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Preview ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "REAL-TIME PREVIEW",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: state.textureId == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : Texture(textureId: state.textureId!),
              ),
            ),
          ),

          // --- Properties Section ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  "NODE PROPERTIES",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: selectedNode == null
                  ? Center(
                      child: Text(
                        "Select a node to edit properties",
                        style: GoogleFonts.inter(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NODE IDENTITY",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "ID:",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                selectedNode.id,
                                style: GoogleFonts.firaCode(
                                  fontSize: 11,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        PropertiesWidgetFactory.build(context, selectedNode),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
