import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';

class PropertiesInspector extends ConsumerWidget {
  const PropertiesInspector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final selectedNode = state.nodes.where((n) => n.id == state.selectedNodeId).firstOrNull;

    return Container(
      width: 320,
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Preview ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text("REAL-TIME PREVIEW", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface, letterSpacing: 1)),
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 20)],
              ),
              child: Center(
                child: Text("Vulkan/OpenGL\nTexture Widget Here", textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(color: AppColors.primaryDim)),
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
                Text("NODE PROPERTIES", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface, letterSpacing: 1)),
              ],
            ),
          ),
          
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.outlineVariant))),
              child: selectedNode == null 
                ? Center(child: Text("Select a node to edit properties", style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 12)))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("NODE IDENTITY", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.outlineVariant)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("ID:", style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface)),
                          Text(selectedNode.id, style: GoogleFonts.firaCode(fontSize: 11, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (selectedNode.type == NodeType.color) ...[
                      Text("PARAMETERS", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      _inspectorSlider(ref, selectedNode.id, "R", "r", selectedNode.parameters["r"] ?? 1.0),
                      _inspectorSlider(ref, selectedNode.id, "G", "g", selectedNode.parameters["g"] ?? 1.0),
                      _inspectorSlider(ref, selectedNode.id, "B", "b", selectedNode.parameters["b"] ?? 1.0),
                      _inspectorSlider(ref, selectedNode.id, "A", "a", selectedNode.parameters["a"] ?? 1.0),
                    ]
                  ],
                ),
            ),
          )
        ],
      ),
    );
  }

  Widget _inspectorSlider(WidgetRef ref, String nodeId, String label, String paramKey, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              Text(value.toStringAsFixed(2), style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onPanUpdate: (d) {
              double newValue = (value + (d.delta.dx * 0.05)).clamp(0.0, 1.0);
              ref.read(editorProvider.notifier).updateNodeParameter(nodeId, paramKey, newValue);
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(2)),
                child: Stack(
                  children: [
                    Container(
                      width: 280 * value, // Закрашенная часть (ширина инспектора * значение)
                      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(2)),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}