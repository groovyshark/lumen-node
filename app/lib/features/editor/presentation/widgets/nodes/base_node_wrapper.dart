import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';

import 'package:lumen_node_app/features/editor/providers/canvas_key_provider.dart';
import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';

class BaseNodeWrapper extends ConsumerWidget {
  final NodeModel node;
  final Widget child;

  const BaseNodeWrapper({super.key, required this.node, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected =
        ref.watch(editorProvider.select((s) => s.selectedNodeId)) == node.id;

    final canvasKey = ref.watch(canvasKeyProvider);

    return GestureDetector(
      onTapDown: (_) => ref.read(editorProvider.notifier).selectNode(node.id),
      onPanUpdate: (d) => ref
          .read(editorProvider.notifier)
          .updateNodePosition(node.id, d.delta),
      child: Container(
        width: node.size.width,
        height: node.size.height,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _getAccentColor(node.type) : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _getAccentColor(node.type).withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER NODE ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getHeaderColor(node.type),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(7),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    node.name,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    node.type == NodeType.color ? Icons.palette : Icons.close,
                    size: 14,
                    color: _getAccentColor(node.type),
                  ),
                ],
              ),
            ),
            // --- BODY NODE (Inputs & Properties) ---
            Expanded(
              child: Container(
                color: AppColors.surfaceContainerHigh,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ...node.inputs.map(
                      (pinName) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _getAccentColor(node.type),
                                  width: 2,
                                ),
                              ),
                            ),
                            Text(
                              pinName.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    child,
                  ],
                ),
              ),
            ),
            // --- FOOTER NODE WITH PIN (OUTPUT POINT) ---
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(7)),
              ),
              child: Column(
                children: node.outputs
                    .map(
                      (pinName) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              pinName.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            GestureDetector(
                              onPanStart: (d) {
                                final RenderBox? canvasBox =
                                    canvasKey.currentContext?.findRenderObject()
                                        as RenderBox?;
                                if (canvasBox == null) return;

                                final localPos = canvasBox.globalToLocal(
                                  d.globalPosition,
                                );
                                ref
                                    .read(editorProvider.notifier)
                                    .startDraftingConnection(
                                      node.id,
                                      pinName,
                                      localPos,
                                    );
                              },
                              onPanUpdate: (d) {
                                final RenderBox? canvasBox =
                                    canvasKey.currentContext?.findRenderObject()
                                        as RenderBox?;
                                if (canvasBox == null) return;

                                final localPos = canvasBox.globalToLocal(
                                  d.globalPosition,
                                );
                                ref
                                    .read(editorProvider.notifier)
                                    .updateDraftingConnection(localPos);
                              },
                              onPanEnd: (_) {
                                ref
                                    .read(editorProvider.notifier)
                                    .endDraftingConnection();
                              },
                              child: Container(
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(7),
                                  ),
                                ),
                                alignment: Alignment.centerRight,
                                child: Transform.translate(
                                  offset: const Offset(4, 0),
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeaderColor(NodeType type) {
    switch (type) {
      case NodeType.master:
        return Colors.red;
      case NodeType.color:
        return Colors.blue.shade800;
      case NodeType.add:
        return Colors.lime.shade800;
      case NodeType.uv:
        return Colors.orange.shade800;
      case NodeType.time:
        return Colors.teal.shade800;
      case NodeType.multiply:
        return Colors.deepPurple.shade800;
      // default: return Colors.grey.shade700;
    }
  }

  Color _getAccentColor(NodeType type) {
    switch (type) {
      case NodeType.master:
        return Colors.redAccent;
      case NodeType.color:
        return Color(0xFF69DAFF);
      case NodeType.add:
        return Colors.limeAccent.shade100;
      case NodeType.multiply:
        return Colors.deepPurpleAccent.shade100;
      case NodeType.uv:
        return Colors.orangeAccent.shade100;
      case NodeType.time:
        return Colors.tealAccent.shade100;
      // default: return Colors.grey.shade500;
    }
  }
}
