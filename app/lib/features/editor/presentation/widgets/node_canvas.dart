import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';

import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/canvas_grid_painter.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/connection_painter.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/draft_connection_painter.dart';

final canvasKey = GlobalKey();

class NodeCanvas extends ConsumerWidget {
  const NodeCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    return MouseRegion(
      onHover: (e) {
        if (state.draftingNodeId != null) {
          notifier.updateDraftingConnection(e.localPosition);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(editorProvider.notifier).selectNode(null),
        onTertiaryTapDown: (d) {
          final RenderBox? box =
              canvasKey.currentContext?.findRenderObject() as RenderBox?;
          if (box == null) return;

          final localPos = box.globalToLocal(d.globalPosition);

          notifier.tryDeleteConnectionAt(localPos);
        },
        onPanUpdate: (d) {
          if (state.draftingNodeId != null) {
            notifier.updateDraftingConnection(d.localPosition);
          }
        },
        onPanEnd: (_) {
          if (state.draftingNodeId != null) {
            notifier.endDraftingConnection();
          }
        },
        child: Stack(
          key: canvasKey,
          children: [
            const RepaintBoundary(
              child: CustomPaint(
                painter: CanvasGridPainter(),
                child: SizedBox.expand(),
              ),
            ),

            RepaintBoundary(
              child: CustomPaint(
                painter: ConnectionPainter(state.nodes, state.connections),
                child: SizedBox.expand(),
              ),
            ),

            if (state.draftingNodeId != null &&
                state.draftingPos != null &&
                state.draftingPinName != null)
              RepaintBoundary(
                child: CustomPaint(
                  painter: DraftConnectionPainter(
                    state.nodes.firstWhere(
                      (n) => n.id == state.draftingNodeId!,
                    ),
                    state.draftingPinName!,
                    state.draftingPos!,
                  ),
                  child: SizedBox.expand(),
                ),
              ),

            ...state.nodes.map(
              (node) => Positioned(
                left: node.position.dx,
                top: node.position.dy,
                child: _NodeWidget(node: node),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeWidget extends ConsumerWidget {
  final NodeModel node;
  const _NodeWidget({required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerColor = node.type == NodeType.color
        ? const Color(0xFF004050)
        : node.type == NodeType.multiply
        ? const Color(0xFF4A195E)
        : const Color(0xFF8B0000); // Master node

    final accentColor = node.type == NodeType.color
        ? AppColors.primary
        : node.type == NodeType.multiply
        ? AppColors.tertiary
        : Colors.redAccent;
    final isSelected =
        ref.watch(editorProvider.select((s) => s.selectedNodeId)) == node.id;

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
            color: isSelected ? accentColor : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
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
                color: headerColor, // on-primary-container
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
                    color: accentColor,
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
                                  color: accentColor,
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

                    if (node.type == NodeType.color)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _staticProperty("R:", node.parameters["r"] ?? 1.0),
                          _staticProperty("G:", node.parameters["g"] ?? 1.0),
                          _staticProperty("B:", node.parameters["b"] ?? 1.0),
                          _staticProperty("A:", node.parameters["a"] ?? 1.0),
                        ],
                      ),
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
